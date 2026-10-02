import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/games/application/game_runtime.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';
import 'package:hnahsin/src/controller.dart';

void main() {
  testWidgets('timed runtime expires once and awards no idle XP', (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    var expirations = 0;
    int? idleXp;
    late GameRuntime runtime;
    runtime = GameRuntime(
      controller: controller,
      gameId: 'spelling',
      mode: GameMode.timed,
      timedSeconds: 2,
      onChanged: () {},
      onTimedOut: () async {
        expirations += 1;
        final result = await runtime.finish(baseXp: 40);
        idleXp = result.xp;
      },
    );
    addTearDown(runtime.dispose);
    await runtime.initialize(
      currentIndex: () => 0,
      readPayload: () => const <String, Object?>{},
      restorePayload: (_) {},
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(expirations, 1);
    expect(idleXp, 0);
    expect(runtime.remainingSeconds, 0);
  });

  testWidgets('pause snapshot restores presentation and hint state',
      (tester) async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    var index = 2;
    var selected = 'A';
    final first = GameRuntime(
      controller: controller,
      gameId: 'spelling',
      mode: GameMode.standard,
      onChanged: () {},
      onTimedOut: () async {},
    );
    await first.initialize(
      currentIndex: () => index,
      readPayload: () => <String, Object?>{'selected': selected},
      restorePayload: (_) {},
    );
    await first.revealHint();
    first.didChangeAppLifecycleState(AppLifecycleState.paused);
    await tester.pump();
    first.dispose();

    index = 0;
    selected = '';
    final restored = GameRuntime(
      controller: controller,
      gameId: 'spelling',
      mode: GameMode.relaxed,
      onChanged: () {},
      onTimedOut: () async {},
    );
    await restored.initialize(
      currentIndex: () => index,
      readPayload: () => <String, Object?>{'selected': selected},
      restorePayload: (snapshot) {
        index = snapshot.currentIndex;
        selected = snapshot.payload['selected'] as String? ?? '';
      },
    );

    expect(restored.restoredSession, isTrue);
    expect(restored.session.status, GameSessionStatus.active);
    expect(restored.session.mode, GameMode.standard);
    expect(restored.hintRevealed, isTrue);
    expect(index, 2);
    expect(selected, 'A');
    restored.dispose();
  });

  testWidgets('hint-assisted runtime answer uses reduced score', (tester) async {
    final runtime = GameRuntime(
      controller: QuestController(repository: InMemoryQuestRepository()),
      gameId: 'picture_match',
      mode: GameMode.relaxed,
      onChanged: () {},
      onTimedOut: () async {},
    );
    await runtime.initialize(
      currentIndex: () => 0,
      readPayload: () => const <String, Object?>{},
      restorePayload: (_) {},
    );
    await runtime.revealHint();

    runtime.answer(true);

    expect(runtime.session.score, 60);
    expect(runtime.hintRevealed, isFalse);
    runtime.dispose();
  });
}
