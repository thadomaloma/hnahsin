import 'dart:async';

import 'package:flutter/material.dart';

import 'data/quest_repository_factory.dart';
import 'features/content_sync/content_sync_factory.dart';
import 'src/app.dart';
import 'src/controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await createQuestRepository();
  final contentSyncService = await createContentSyncService();
  final controller = QuestController(
    repository: repository,
    contentSyncService: contentSyncService,
  );
  // Progress storage must never prevent the learning app from opening. This
  // also keeps first-run development builds usable while plugins initialise.
  try {
    await controller.load();
  } catch (error, stackTrace) {
    debugPrint('Progress could not be loaded: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
  runApp(ThumalQuestApp(controller: controller));
  unawaited(controller.refreshContent());
}
