import 'package:flutter/foundation.dart';

import 'preferences_quest_repository.dart';
import 'quest_repository.dart';
import 'sqflite_quest_repository.dart';

Future<QuestRepository> createQuestRepository() async {
  final supportsSqflite = !kIsWeb &&
      <TargetPlatform>{
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }.contains(defaultTargetPlatform);

  if (supportsSqflite) {
    try {
      return await SqfliteQuestRepository.open();
    } catch (error, stackTrace) {
      debugPrint('SQLite unavailable; using preference fallback: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
  return PreferencesQuestRepository();
}
