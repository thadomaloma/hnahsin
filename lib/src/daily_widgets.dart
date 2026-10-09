import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../features/games/application/daily_puzzle.dart';
import '../features/games/engine/game_engine.dart';
import '../features/games/presentation/crossword_game.dart';
import 'app_text.dart';
import 'celebration.dart';
import 'controller.dart';
import 'game_session.dart';
import 'game_sounds.dart';
import 'game_text.dart';
import 'games.dart';
import 'theme.dart';
import 'widgets.dart';

/// The games with a daily puzzle.
const dailyGameIds = <String>[MiniCrosswordGame.gameId, 'word_search'];

/// [puzzle]'s game, relaxed (no hearts) and timed by a clock that counts up.
Widget dailyGameFor(QuestController controller, DailyPuzzle puzzle) =>
    puzzle.gameId == MiniCrosswordGame.gameId
        ? MiniCrosswordGame(
            controller: controller, mode: GameMode.relaxed, daily: puzzle)
        : WordSearchGame(
            controller: controller, mode: GameMode.relaxed, daily: puzzle);

/// “Crossword #12”.
String dailyTitle(DailyPuzzle puzzle) => AppText.of('daily.puzzle',
    {'game': GameText.of(puzzle.gameId).title, 'n': puzzle.number});

/// What a player shares: the puzzle, a mark per word, time and hints. No
/// words, so it spoils nothing for friends who haven't played yet.
String dailyShareText(DailyPuzzle puzzle, DailyResult result) =>
    AppText.of('daily.shareText', {
      'puzzle': dailyTitle(puzzle),
      'marks': result.marks.join(),
      'time': result.time,
      'hints': result.hints,
    });

/// Banks a finished daily puzzle (XP and today's rounds, not the game's
/// level, since everyone plays the same one) and shows how it went.
Future<void> finishDaily(
  BuildContext context,
  QuestController controller,
  DailyPuzzle puzzle,
  GameResult result,
  DailyResult daily,
) async {
  await controller.reward(puzzle.gameId, result, adaptive: false);
  await controller.clearSession(result.sessionId);
  final first = controller.dailyResult(puzzle) == null;
  await controller.recordDaily(puzzle, daily);
  if (!context.mounted) return;
  GameSounds.play(GameSound.complete);
  await showDailyResult(
      context, puzzle, controller.dailyResult(puzzle) ?? daily,
      celebrate: first, closeGame: true);
}

/// The result sheet: marks, time, hints and Share. [closeGame] also leaves
/// the game screen when the sheet closes.
Future<void> showDailyResult(
    BuildContext context, DailyPuzzle puzzle, DailyResult result,
    {bool celebrate = false, bool closeGame = false}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 560),
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Stack(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            decoration: const BoxDecoration(
              gradient: QuestGradients.hero,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(children: [
              Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                      color: const Color(0x55FFFFFF),
                      borderRadius: BorderRadius.circular(99))),
              const SizedBox(height: 18),
              Text(AppText.of('daily.eyebrow'),
                  style: const TextStyle(
                      color: QuestColors.gold,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      fontSize: 12)),
              const SizedBox(height: 4),
              Text(dailyTitle(puzzle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Text(result.marks.join(' '),
                  semanticsLabel: AppText.of('daily.marksSpoken', {
                    'clean': result.marks
                        .where((mark) => mark == DailyResult.clean)
                        .length,
                    'total': result.marks.length,
                  }),
                  style: const TextStyle(fontSize: 30, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(AppText.of('daily.comeBack'),
                  style: const TextStyle(color: Color(0xFFDDF3FF))),
            ]),
          ),
          if (celebrate)
            const Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                child: ConfettiBurst(),
              ),
            ),
        ]),
        Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, 20 + MediaQuery.of(sheetContext).padding.bottom),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: _Stat(
                      icon: Icons.timer_rounded,
                      label: AppText.of('daily.time'),
                      value: result.time)),
              const SizedBox(width: 10),
              Expanded(
                  child: _Stat(
                      icon: Icons.lightbulb_rounded,
                      label: AppText.of('daily.hints'),
                      value: '${result.hints}')),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    if (closeGame) Navigator.of(context).pop();
                  },
                  child: Text(AppText.of('common.continue')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Builder(
                  builder: (buttonContext) => FilledButton.icon(
                    onPressed: () =>
                        _share(buttonContext, dailyShareText(puzzle, result)),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(AppText.of('daily.share')),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    ),
  );
}

/// Opens the phone's share sheet, or copies the text where there is none.
Future<void> _share(BuildContext context, String text) async {
  final box = context.findRenderObject() as RenderBox?;
  try {
    await SharePlus.instance.share(ShareParams(
      text: text,
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ));
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(AppText.of('daily.copied'))));
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: QuestColors.mist, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          Icon(icon, color: QuestColors.indigo),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: QuestColors.ink)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: QuestColors.slate,
                  letterSpacing: .8)),
        ]),
      );
}

/// Home's daily puzzles: one tile per game, showing today's number, or the
/// time it took once done.
class DailyPuzzlesCard extends StatelessWidget {
  const DailyPuzzlesCard({super.key, required this.controller});
  final QuestController controller;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(AppText.of('daily.title')),
        const SizedBox(height: 4),
        Text(AppText.of('daily.subtitle'),
            style: const TextStyle(color: QuestColors.slate, fontSize: 13)),
        const SizedBox(height: 12),
        Row(children: [
          for (final (index, gameId) in dailyGameIds.indexed) ...[
            if (index > 0) const SizedBox(width: 12),
            Expanded(
                child: _DailyTile(
                    controller: controller,
                    puzzle: controller.dailyPuzzle(gameId))),
          ],
        ]),
      ]);
}

class _DailyTile extends StatelessWidget {
  const _DailyTile({required this.controller, required this.puzzle});
  final QuestController controller;
  final DailyPuzzle puzzle;

  @override
  Widget build(BuildContext context) {
    final result = controller.dailyResult(puzzle);
    final done = result != null;
    final icon = puzzle.gameId == MiniCrosswordGame.gameId
        ? Icons.grid_on_rounded
        : Icons.search_rounded;
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        if (result != null) {
          showDailyResult(context, puzzle, result);
        } else {
          Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => dailyGameFor(controller, puzzle)));
        }
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: done ? null : QuestGradients.hero,
              color: done ? const Color(0xFFE6F5E2) : null,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(done ? Icons.check_rounded : icon,
                color: done ? QuestColors.successInk : Colors.white, size: 22),
          ),
          const Spacer(),
          Text('#${puzzle.number}',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: QuestColors.slate)),
        ]),
        const SizedBox(height: 10),
        Text(GameText.of(puzzle.gameId).title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
        const SizedBox(height: 2),
        Text(
          done
              ? AppText.of('daily.done', {'time': result.time})
              : AppText.of('daily.play'),
          style: TextStyle(
              color: done ? QuestColors.successInk : QuestColors.indigo,
              fontWeight: FontWeight.w700,
              fontSize: 13),
        ),
      ]),
    );
  }
}
