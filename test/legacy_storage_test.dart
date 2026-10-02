import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:hnahsin/data/sqflite_quest_repository.dart';
import 'package:hnahsin/features/content_sync/data/offline_pack_store.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('hnahsin_legacy_');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  String at(String name) => path.join(directory.path, name);

  test('database saved as Thumal Quest moves with its journal files', () async {
    await File(at('thumal_quest.sqlite')).writeAsString('db');
    await File(at('thumal_quest.sqlite-wal')).writeAsString('wal');
    await File(at('thumal_quest.sqlite-shm')).writeAsString('shm');

    await moveLegacyDatabase(directory.path, at('hnahsin.sqlite'));

    expect(await File(at('hnahsin.sqlite')).readAsString(), 'db');
    expect(await File(at('hnahsin.sqlite-wal')).readAsString(), 'wal');
    expect(await File(at('hnahsin.sqlite-shm')).readAsString(), 'shm');
    expect(await File(at('hnahsin.sqlite-journal')).exists(), isFalse);
    expect(await File(at('thumal_quest.sqlite')).exists(), isFalse);
  });

  test('an existing Hnahsin database is never overwritten', () async {
    await File(at('thumal_quest.sqlite')).writeAsString('old');
    await File(at('hnahsin.sqlite')).writeAsString('new');

    await moveLegacyDatabase(directory.path, at('hnahsin.sqlite'));

    expect(await File(at('hnahsin.sqlite')).readAsString(), 'new');
    expect(await File(at('thumal_quest.sqlite')).readAsString(), 'old');
  });

  test('nothing happens on a fresh install', () async {
    await moveLegacyDatabase(directory.path, at('hnahsin.sqlite'));

    expect(await File(at('hnahsin.sqlite')).exists(), isFalse);
  });

  test('offline packs saved as Thumal Quest move to the hnahsin folder',
      () async {
    final legacyPack =
        File(at(path.join('thumal_quest', 'delivery_v1', 'p.json')));
    await legacyPack.create(recursive: true);
    await legacyPack.writeAsString('pack');

    await moveLegacyPackFolder(directory.path);

    expect(
      await File(at(path.join('hnahsin', 'delivery_v1', 'p.json')))
          .readAsString(),
      'pack',
    );
    expect(await Directory(at('thumal_quest')).exists(), isFalse);
  });

  test('an existing hnahsin pack folder is left alone', () async {
    await Directory(at('thumal_quest')).create();
    final current = File(at(path.join('hnahsin', 'p.json')));
    await current.create(recursive: true);
    await current.writeAsString('new');

    await moveLegacyPackFolder(directory.path);

    expect(await current.readAsString(), 'new');
    expect(await Directory(at('thumal_quest')).exists(), isTrue);
  });
}
