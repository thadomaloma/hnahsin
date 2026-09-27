import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/delivery_models.dart';

class StoredPack {
  const StoredPack({required this.envelope, required this.etag});
  final PackEnvelope envelope;
  final String? etag;
}

abstract interface class OfflinePackStore {
  Future<StoredPack?> loadActive(DeliveryPackKind kind);

  Future<void> activate(
    DeliveryPackKind kind, {
    required PackEnvelope envelope,
    required String? etag,
  });

  /// Verified picture bytes cached by SHA-256 (null when not cached yet).
  Future<List<int>?> readImage(String checksum);

  Future<void> writeImage(String checksum, List<int> bytes);
}

class FileOfflinePackStore implements OfflinePackStore {
  FileOfflinePackStore._(this._root, this._preferences);

  final Directory _root;
  final SharedPreferencesAsync _preferences;

  static Future<FileOfflinePackStore> open(
      {SharedPreferencesAsync? preferences}) async {
    final support = await getApplicationSupportDirectory();
    final root =
        Directory(path.join(support.path, 'thumal_quest', 'delivery_v1'));
    await root.create(recursive: true);
    return FileOfflinePackStore._(
        root, preferences ?? SharedPreferencesAsync());
  }

  String _activeKey(DeliveryPackKind kind) =>
      'phase4b.active_pack.${kind.name}';
  String _etagKey(DeliveryPackKind kind) => 'phase4b.active_etag.${kind.name}';

  @override
  Future<StoredPack?> loadActive(DeliveryPackKind kind) async {
    final checksum = await _preferences.getString(_activeKey(kind));
    if (checksum == null || !_safeChecksum(checksum)) return null;
    final file =
        File(path.join(_root.path, 'packs', kind.name, '$checksum.json'));
    if (!await file.exists()) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;
      final envelope = PackEnvelope.parse(
        Map<String, Object?>.from(decoded),
        kind: kind,
      );
      if (envelope.checksum != checksum) return null;
      return StoredPack(
        envelope: envelope,
        etag: await _preferences.getString(_etagKey(kind)),
      );
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> activate(
    DeliveryPackKind kind, {
    required PackEnvelope envelope,
    required String? etag,
  }) async {
    final directory = Directory(path.join(_root.path, 'packs', kind.name));
    await directory.create(recursive: true);
    final target = File(path.join(directory.path, '${envelope.checksum}.json'));
    final temporary = File('${target.path}.part');
    await temporary.writeAsString(jsonEncode(envelope.toJson()), flush: true);
    if (await target.exists()) await target.delete();
    await temporary.rename(target.path);
    await _preferences.setString(_activeKey(kind), envelope.checksum);
    if (etag == null) {
      await _preferences.remove(_etagKey(kind));
    } else {
      await _preferences.setString(_etagKey(kind), etag);
    }
  }

  @override
  Future<List<int>?> readImage(String checksum) async {
    if (!_safeChecksum(checksum)) return null;
    final file = File(path.join(_root.path, 'images', checksum));
    return await file.exists() ? file.readAsBytes() : null;
  }

  @override
  Future<void> writeImage(String checksum, List<int> bytes) async {
    if (!_safeChecksum(checksum)) throw const FormatException('Unsafe image checksum.');
    final directory = Directory(path.join(_root.path, 'images'));
    await directory.create(recursive: true);
    final target = File(path.join(directory.path, checksum));
    final temporary = File('${target.path}.part');
    await temporary.writeAsBytes(bytes, flush: true);
    if (await target.exists()) await target.delete();
    await temporary.rename(target.path);
  }

  bool _safeChecksum(String value) => RegExp(r'^[0-9a-f]{64}$').hasMatch(value);
}

class MemoryOfflinePackStore implements OfflinePackStore {
  final Map<DeliveryPackKind, StoredPack> packs =
      <DeliveryPackKind, StoredPack>{};

  @override
  Future<StoredPack?> loadActive(DeliveryPackKind kind) async => packs[kind];

  @override
  Future<void> activate(
    DeliveryPackKind kind, {
    required PackEnvelope envelope,
    required String? etag,
  }) async {
    packs[kind] = StoredPack(envelope: envelope, etag: etag);
  }

  final Map<String, List<int>> images = <String, List<int>>{};

  @override
  Future<List<int>?> readImage(String checksum) async => images[checksum];

  @override
  Future<void> writeImage(String checksum, List<int> bytes) async {
    images[checksum] = List<int>.unmodifiable(bytes);
  }
}
