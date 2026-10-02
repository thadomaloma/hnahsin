import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/content_sync/application/content_sync_service.dart';
import 'package:hnahsin/features/content_sync/application/content_transport.dart';
import 'package:hnahsin/features/content_sync/data/offline_pack_store.dart';
import 'package:hnahsin/features/content_sync/domain/delivery_models.dart';

void main() {
  test('a verified content pack activates and feeds the word catalog', () async {
    final store = MemoryOfflinePackStore();
    final service = ContentSyncService(
      transport: FakeContentTransport(content: _contentEnvelope(version: '1.0.0')),
      store: store,
    );

    final state = await service.synchronize();

    expect(state.outcome, ContentSyncOutcome.updated);
    expect(state.contentVersion, '1.0.0');
    expect(service.activeWords.single.englishGloss, 'House');
  });

  test('a tampered pack is rejected and the last valid pack stays active', () async {
    final store = MemoryOfflinePackStore();
    await ContentSyncService(
      transport: FakeContentTransport(content: _contentEnvelope(version: '1.0.0')),
      store: store,
    ).synchronize();

    final tampered = _contentEnvelope(version: '2.0.0')..['checksum'] = '0' * 64;
    final service = ContentSyncService(
      transport: FakeContentTransport(content: tampered),
      store: store,
    );
    final state = await service.synchronize();

    expect(state.outcome, ContentSyncOutcome.invalidRejected);
    expect(state.contentVersion, '1.0.0');
    expect(service.activeWords, hasLength(1));
  });

  test('network failure retains verified offline packs', () async {
    final store = MemoryOfflinePackStore();
    await ContentSyncService(
      transport: FakeContentTransport(content: _contentEnvelope(version: '2.0.0')),
      store: store,
    ).synchronize();

    final offline = ContentSyncService(
      transport: FakeContentTransport.offline(),
      store: store,
    );
    await offline.initialize();
    final state = await offline.synchronize();

    expect(state.outcome, ContentSyncOutcome.offlinePreserved);
    expect(state.contentVersion, '2.0.0');
    expect(offline.activeWords, hasLength(1));
  });

  test('an unchanged pack (ETag 304) is reported as up to date', () async {
    final store = MemoryOfflinePackStore();
    await ContentSyncService(
      transport: FakeContentTransport(content: _contentEnvelope(version: '3.0.0')),
      store: store,
    ).synchronize();

    final service = ContentSyncService(
      transport: FakeContentTransport(
        content: _contentEnvelope(version: '3.0.0'),
        honorEtags: true,
      ),
      store: store,
    );
    await service.initialize();
    final state = await service.synchronize();

    expect(state.outcome, ContentSyncOutcome.upToDate);
    expect(state.contentVersion, '3.0.0');
  });

  test('Studio pictures download, verify and cache; a corrupt one is skipped', () async {
    final good = utf8.encode('png-bytes-for-sickle');
    final goodSum = sha256.convert(good).toString();
    final bad = utf8.encode('declared-bytes');
    final badSum = sha256.convert(bad).toString();
    final pack = _packWith('6.0.0', [
      _word('word.favah', 'Favah', image: {'checksum': goodSum, 'content_type': 'image/png', 'byte_size': good.length}),
      _word('word.chem', 'Chem', image: {'checksum': badSum, 'content_type': 'image/png', 'byte_size': bad.length}),
    ]);
    final store = MemoryOfflinePackStore();
    final transport = FakeContentTransport(content: pack, files: {
      '/api/v1/word_images/$goodSum': good,
      '/api/v1/word_images/$badSum': utf8.encode('tampered-bytes'),
    });
    final service = ContentSyncService(transport: transport, store: store);

    final state = await service.synchronize();

    expect(state.outcome, ContentSyncOutcome.updated);
    expect(service.activeWords, hasLength(2), reason: 'text content never waits on pictures');
    expect(service.activeImages.keys, [goodSum]);
    expect(store.images[goodSum], good);

    final offline = ContentSyncService(transport: FakeContentTransport.offline(), store: store);
    await offline.initialize();
    expect(offline.activeImages[goodSum], good, reason: 'cached pictures work offline');
  });

  test('Studio questions, game text and sentences are read from the pack', () async {
    final pack = _packWith('7.0.0', [
      _word('word.in', 'In'),
      _item('question.tawng-upa.001', 'question', {
        'prompt_mizo': '“Hnial” tih awmzia eng nge?',
        'options': ['Thu sawi inpersan', 'Hla sak', 'Tlan chak', 'Chaw ei'],
        'answer': 'Thu sawi inpersan', 'explanation_mizo': 'Inpersan a ni.', 'difficulty': 2,
      }),
      _item('question.broken', 'question', {'prompt_mizo': 'x', 'options': ['a', 'b'], 'answer': 'a'}),
      _item('game.picture_match', 'game_copy', {
        'game_id': 'picture_match', 'prompt': 'He thlalak hming hi eng nge?', 'instructions': ['Picture en rawh.'],
      }),
      _item('sentence.200', 'sentence', {
        'content': {'text_mizo': 'Ka nu a hlim.', 'english_support': 'My mother is happy.'},
        'learning': {'tq_level': 'TQ1'},
      }),
    ]);
    final service = ContentSyncService(
      transport: FakeContentTransport(content: pack),
      store: MemoryOfflinePackStore(),
    );

    await service.synchronize();

    expect(service.activeQuestions.single.difficulty, 2);
    expect(service.activeGameCopy['picture_match']!.fields['prompt'], 'He thlalak hming hi eng nge?');
    expect(service.activeGameCopy['picture_match']!.instructions, ['Picture en rawh.']);
    expect(service.activeSentences.single.difficulty, 2);
  });
}

class FakeContentTransport implements ContentTransport {
  FakeContentTransport({required this.content, this.honorEtags = false, this.files = const {}})
      : offline = false;

  FakeContentTransport.offline()
      : content = const <String, Object?>{},
        honorEtags = false,
        files = const {},
        offline = true;

  final Map<String, Object?> content;
  final bool offline;
  final bool honorEtags;
  final Map<String, List<int>> files;
  final List<String> downloads = <String>[];

  @override
  Future<List<int>> download(String path, {required int maximumBytes}) async {
    downloads.add(path);
    final bytes = files[path];
    if (bytes == null) throw const ContentDeliveryException('missing');
    return bytes;
  }

  @override
  Future<PackResponse> fetchLatest(String path, {String? etag}) async {
    if (offline) throw const ContentDeliveryException('offline');
    if (honorEtags && etag != null) {
      return PackResponse(notModified: true, etag: etag);
    }
    return PackResponse(notModified: false, body: content, etag: 'content-etag');
  }

  @override
  void close() {}
}

Map<String, Object?> _contentEnvelope({required String version}) {
  final body = <String, Object?>{
    'word': 'In',
    'meaning_mizo': 'Mihring chenna hmun',
    'english_gloss': 'House',
    'example_mizo': 'Kan inah lo kal rawh.',
    'emoji': '🏠',
    'category': 'chhungkua',
    'difficulty': 1,
  };
  final manifest = <String, Object?>{
    'schema_version': '1.0',
    'language': 'lus',
    'pack_version': version,
    'generated_at': '2026-09-13T00:00:00Z',
    'items': <Object?>[
      <String, Object?>{
        'stable_id': 'word.in',
        'content_type': 'word',
        'revision': 1,
        'checksum': sha256.convert(utf8.encode(canonicalJson(body))).toString(),
        'body': body,
      },
    ],
  };
  return _envelope('content-pack', version, manifest);
}

Map<String, Object?> _envelope(
  String id,
  String version,
  Map<String, Object?> manifest,
) =>
    <String, Object?>{
      'id': id,
      'version': version,
      'checksum': sha256.convert(utf8.encode(canonicalJson(manifest))).toString(),
      'manifest': manifest,
    };

Map<String, Object?> _word(String id, String word, {Map<String, Object?>? image}) => _item(id, 'word', {
      'word': word,
      'meaning_mizo': 'Awmzia',
      'english_gloss': word,
      'example_mizo': '$word hi a tha.',
      'emoji': '',
      'category': 'khawvel',
      'difficulty': 1,
      if (image != null) 'image': image,
    });

Map<String, Object?> _item(String id, String type, Map<String, Object?> body) => <String, Object?>{
      'stable_id': id,
      'content_type': type,
      'revision': 1,
      'checksum': sha256.convert(utf8.encode(canonicalJson(body))).toString(),
      'body': body,
    };

Map<String, Object?> _packWith(String version, List<Map<String, Object?>> items) => _envelope(
      'content-pack',
      version,
      <String, Object?>{
        'schema_version': '1.0',
        'language': 'lus',
        'pack_version': version,
        'generated_at': '2026-09-27T00:00:00Z',
        'items': items,
      },
    );
