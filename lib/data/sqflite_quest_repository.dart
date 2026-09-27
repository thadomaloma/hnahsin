import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../features/games/engine/game_engine.dart';
import '../features/journey/domain/journey_state.dart';
import '../features/learning/domain/learning_state.dart';
import '../features/onboarding/domain/learner_profile.dart';
import '../features/progress/domain/quest_progress.dart';
import 'quest_repository.dart';

class SqfliteQuestRepository implements QuestRepository {
  SqfliteQuestRepository._(this._database);

  final Database _database;

  static Future<SqfliteQuestRepository> open() async {
    final databasePath = path.join(
      await getDatabasesPath(),
      'thumal_quest.sqlite',
    );
    final database = await openDatabase(
      databasePath,
      version: 3,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE learner_profiles (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE quest_progress (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE reward_ledger (
            transaction_id TEXT PRIMARY KEY,
            game_id TEXT NOT NULL,
            committed_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE game_sessions (
            session_id TEXT PRIMARY KEY,
            game_id TEXT NOT NULL UNIQUE,
            payload TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE learning_state (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE journey_state (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS learning_state (
              id TEXT PRIMARY KEY,
              payload TEXT NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS journey_state (
              id TEXT PRIMARY KEY,
              payload TEXT NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
        }
      },
    );
    return SqfliteQuestRepository._(database);
  }

  int get _now => DateTime.now().toUtc().millisecondsSinceEpoch;

  @override
  Future<LearnerProfile> loadProfile() async {
    final rows = await _database.query(
      'learner_profiles',
      where: 'id = ?',
      whereArgs: const <Object?>['guest'],
      limit: 1,
    );
    if (rows.isEmpty) return LearnerProfile.fresh();
    return LearnerProfile.fromJson(
      Map<String, Object?>.from(
        jsonDecode(rows.first['payload']! as String) as Map,
      ),
    );
  }

  @override
  Future<void> saveProfile(LearnerProfile profile) async {
    await _database.insert(
      'learner_profiles',
      <String, Object?>{
        'id': profile.id,
        'payload': jsonEncode(profile.toJson()),
        'updated_at': _now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<QuestProgress> loadProgress() async {
    final rows = await _database.query(
      'quest_progress',
      where: 'id = ?',
      whereArgs: const <Object?>['guest'],
      limit: 1,
    );
    if (rows.isEmpty) return QuestProgress.empty();
    return QuestProgress.fromJson(
      Map<String, Object?>.from(
        jsonDecode(rows.first['payload']! as String) as Map,
      ),
    );
  }

  @override
  Future<void> saveProgress(QuestProgress progress) async {
    await _writeProgress(_database, progress);
  }

  @override
  Future<LearningState> loadLearningState() async {
    final rows = await _database.query(
      'learning_state',
      where: 'id = ?',
      whereArgs: const <Object?>['guest'],
      limit: 1,
    );
    if (rows.isEmpty) return LearningState.fresh();
    return LearningState.fromJson(
      Map<String, Object?>.from(
        jsonDecode(rows.first['payload']! as String) as Map,
      ),
    );
  }

  @override
  Future<void> saveLearningState(LearningState state) async {
    await _database.insert(
      'learning_state',
      <String, Object?>{
        'id': 'guest',
        'payload': jsonEncode(state.toJson()),
        'updated_at': _now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<JourneyState> loadJourneyState() async {
    final rows = await _database.query(
      'journey_state',
      where: 'id = ?',
      whereArgs: const <Object?>['guest'],
      limit: 1,
    );
    if (rows.isEmpty) return JourneyState.fresh();
    return JourneyState.fromJson(
      Map<String, Object?>.from(
        jsonDecode(rows.first['payload']! as String) as Map,
      ),
    );
  }

  @override
  Future<void> saveJourneyState(JourneyState state) async {
    await _database.insert(
      'journey_state',
      <String, Object?>{
        'id': 'guest',
        'payload': jsonEncode(state.toJson()),
        'updated_at': _now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _writeProgress(
    DatabaseExecutor executor,
    QuestProgress progress,
  ) async {
    await executor.insert(
      'quest_progress',
      <String, Object?>{
        'id': 'guest',
        'payload': jsonEncode(progress.toJson()),
        'updated_at': _now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> commitReward({
    required String transactionId,
    required String gameId,
    required QuestProgress progress,
  }) async {
    return _database.transaction((transaction) async {
      final count = Sqflite.firstIntValue(
            await transaction.rawQuery(
              'SELECT COUNT(*) FROM reward_ledger WHERE transaction_id = ?',
              <Object?>[transactionId],
            ),
          ) ??
          0;
      if (count > 0) return false;
      await transaction.insert('reward_ledger', <String, Object?>{
        'transaction_id': transactionId,
        'game_id': gameId,
        'committed_at': _now,
      });
      await _writeProgress(transaction, progress);
      return true;
    });
  }

  @override
  Future<void> saveSession(GameSessionSnapshot snapshot) async {
    await _database.insert(
      'game_sessions',
      <String, Object?>{
        'session_id': snapshot.sessionId,
        'game_id': snapshot.gameId,
        'payload': jsonEncode(snapshot.toJson()),
        'updated_at': _now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<GameSessionSnapshot?> loadSession(String gameId) async {
    final rows = await _database.query(
      'game_sessions',
      where: 'game_id = ?',
      whereArgs: <Object?>[gameId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return GameSessionSnapshot.fromJson(
      Map<String, Object?>.from(
        jsonDecode(rows.first['payload']! as String) as Map,
      ),
    );
  }

  @override
  Future<void> clearSession(String sessionId) async {
    await _database.delete(
      'game_sessions',
      where: 'session_id = ?',
      whereArgs: <Object?>[sessionId],
    );
  }

  @override
  Future<void> resetAll() async {
    await _database.transaction((transaction) async {
      await transaction.delete('game_sessions');
      await transaction.delete('reward_ledger');
      await transaction.delete('learning_state');
      await transaction.delete('journey_state');
      await transaction.delete('quest_progress');
      await transaction.delete('learner_profiles');
    });
  }

  @override
  Future<void> close() => _database.close();
}
