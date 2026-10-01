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
  runApp(HnahsinApp(controller: controller));
  unawaited(controller.refreshContent());
  WidgetsBinding.instance.addObserver(ContentRefresher(controller));
}

/// Picks up content published from the Sheet without the learner having to
/// restart the app: every [QuestController.contentRecheckAfter] while the app
/// is in front, and when it comes back from the background.
class ContentRefresher with WidgetsBindingObserver {
  ContentRefresher(this.controller) {
    _start();
  }

  final QuestController controller;
  Timer? _timer;

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(QuestController.contentRecheckAfter,
        (_) => unawaited(controller.refreshContentIfStale()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(controller.refreshContentIfStale());
      _start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _timer?.cancel(); // no network use in the background
    }
  }
}
