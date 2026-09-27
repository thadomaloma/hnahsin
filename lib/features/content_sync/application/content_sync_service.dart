import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../data/offline_pack_store.dart';
import '../domain/delivery_models.dart';
import 'content_transport.dart';

class ContentSyncService {
  ContentSyncService({required ContentTransport transport, required OfflinePackStore store})
      : _transport = transport,
        _store = store;

  final ContentTransport _transport;
  final OfflinePackStore _store;
  ContentSyncState state = const ContentSyncState();
  List<DeliveredWord> activeWords = const <DeliveredWord>[];
  List<DeliveredQuestion> activeQuestions = const <DeliveredQuestion>[];
  List<DeliveredSentence> activeSentences = const <DeliveredSentence>[];
  Map<String, DeliveredGameCopy> activeGameCopy = const <String, DeliveredGameCopy>{};

  /// Verified picture bytes by SHA-256, for words that have an uploaded picture.
  Map<String, Uint8List> activeImages = const <String, Uint8List>{};

  Future<void> initialize() async {
    final content = await _store.loadActive(DeliveryPackKind.content);
    await _load(content);
    state = ContentSyncState(
      contentVersion: content?.envelope.version,
      message: content == null
          ? 'Built-in learning content is ready offline.'
          : 'Verified offline packs are ready.',
    );
  }

  Future<ContentSyncState> synchronize() async {
    final previous = state;
    final attemptedAt = DateTime.now().toUtc();
    state = previous.copyWith(
      outcome: ContentSyncOutcome.checking,
      lastAttemptAt: attemptedAt,
      message: 'Checking reviewed content packs…',
    );
    try {
      final updated = await _syncContentPack();
      final content = await _store.loadActive(DeliveryPackKind.content);
      await _load(content);
      await _fetchMissingImages();
      state = ContentSyncState(
        outcome: updated ? ContentSyncOutcome.updated : ContentSyncOutcome.upToDate,
        contentVersion: content?.envelope.version,
        lastAttemptAt: attemptedAt,
        lastSuccessAt: attemptedAt,
        message: updated ? 'Reviewed offline packs updated safely.' : 'Offline packs are up to date.',
      );
    } on FormatException catch (error) {
      await _restorePreservedState(
        outcome: ContentSyncOutcome.invalidRejected,
        attemptedAt: attemptedAt,
        message: 'Unsafe update rejected. Verified compatible offline content remains available. ${error.message}',
      );
    } catch (_) {
      await _restorePreservedState(
        outcome: ContentSyncOutcome.offlinePreserved,
        attemptedAt: attemptedAt,
        message: 'Update unavailable. Verified compatible offline content remains available.',
      );
    }
    return state;
  }

  Future<void> _load(StoredPack? content) async {
    final items = content?.envelope.manifest['items'];
    activeWords = content == null ? const <DeliveredWord>[] : DeliveredWord.parseAll(items);
    activeQuestions = DeliveredQuestion.parseAll(items);
    activeSentences = DeliveredSentence.parseAll(items);
    activeGameCopy = DeliveredGameCopy.parseAll(items);
    final images = <String, Uint8List>{};
    for (final image in activeWords.map((word) => word.image).whereType<DeliveredImage>()) {
      final bytes = await _store.readImage(image.checksum);
      if (bytes != null && _validImage(bytes, image)) images[image.checksum] = Uint8List.fromList(bytes);
    }
    activeImages = Map<String, Uint8List>.unmodifiable(images);
  }

  /// Downloads pictures the active pack references but the device lacks.
  /// A missing or corrupt picture never blocks the reviewed text content:
  /// the word simply falls back to its emoji until the next sync.
  Future<void> _fetchMissingImages() async {
    final images = {...activeImages};
    for (final image in activeWords.map((word) => word.image).whereType<DeliveredImage>()) {
      if (images.containsKey(image.checksum)) continue;
      try {
        final bytes = await _transport.download(image.downloadPath, maximumBytes: image.byteSize);
        if (!_validImage(bytes, image)) continue;
        await _store.writeImage(image.checksum, bytes);
        images[image.checksum] = Uint8List.fromList(bytes);
      } catch (_) {
        continue;
      }
    }
    activeImages = Map<String, Uint8List>.unmodifiable(images);
  }

  bool _validImage(List<int> bytes, DeliveredImage image) =>
      bytes.length == image.byteSize && sha256.convert(bytes).toString() == image.checksum;

  Future<bool> _syncContentPack() async {
    final current = await _store.loadActive(DeliveryPackKind.content);
    final response = await _transport.fetchLatest(
      '/api/v1/content_packs/latest',
      etag: current?.etag,
    );
    if (response.notModified) return false;
    final envelope = PackEnvelope.parse(
      response.body ?? const <String, Object?>{},
      kind: DeliveryPackKind.content,
    );
    if (current?.envelope.checksum == envelope.checksum) return false;
    await _store.activate(DeliveryPackKind.content, envelope: envelope, etag: response.etag);
    return true;
  }

  Future<void> _restorePreservedState({
    required ContentSyncOutcome outcome,
    required DateTime attemptedAt,
    required String message,
  }) async {
    final content = await _store.loadActive(DeliveryPackKind.content);
    await _load(content);
    state = ContentSyncState(
      outcome: outcome,
      contentVersion: content?.envelope.version,
      lastAttemptAt: attemptedAt,
      lastSuccessAt: state.lastSuccessAt,
      message: message,
    );
  }

  void close() => _transport.close();
}
