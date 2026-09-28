import 'package:flutter/material.dart';

import '../features/games/engine/game_engine.dart';
import '../features/games/presentation/crossword_game.dart';
import '../features/games/presentation/phase2b_games.dart';
import '../features/games/presentation/thumal_kawp_game.dart';
import '../features/learning/domain/learning_state.dart';
import '../features/learning/presentation/learning_screens.dart';
import '../features/journey/domain/journey_content.dart';
import '../features/journey/presentation/journey_screens.dart';
import '../features/onboarding/domain/learner_profile.dart';
import 'content_widgets.dart';
import 'controller.dart';
import 'data.dart';
import 'game_text.dart';
import 'games.dart';
import 'theme.dart';
import 'widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(
      {super.key, required this.controller, required this.openGames});
  final QuestController controller;
  final VoidCallback openGames;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => QuestTabPage(children: [
          _BrandHeader(controller: controller),
          const SizedBox(height: 20),
          _DailyHero(controller: controller),
          const SizedBox(height: 28),
          _HomeHighlights(controller: controller),
          const SizedBox(height: 28),
          SectionTitle('Popular Games',
              trailing: TextButton(
                  onPressed: openGames, child: const Text('View All'))),
          const SizedBox(height: 12),
          _GameGrid(
              controller: controller,
              games: _gameCatalog(controller),
              maxRows: 2,
              maxRowsWide: 1),
        ]),
      );
}

class _HomeHighlights extends StatelessWidget {
  const _HomeHighlights({required this.controller});
  final QuestController controller;

  @override
  Widget build(BuildContext context) {
    final journeyVisible =
        !JourneyContentPolicy.isProduction || JourneyContentPolicy.releaseReady;
    final journey =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle(
        'Mizo Journey',
        trailing: TextButton(
          onPressed: () =>
              _open(context, JourneyScreen(controller: controller)),
          child: const Text('View Map'),
        ),
      ),
      const SizedBox(height: 8),
      _FeatureCard(
        icon: Icons.route_rounded,
        colors: const [Color(0xFF7569E8), Color(0xFF5B4FD0)],
        eyebrow: 'STORY PATH',
        title: controller.nextJourneyNode?.titleEnglish ??
            (controller.journeyState.completedNodeIds.length ==
                    journeyNodes.length
                ? 'Journey Complete'
                : 'Continue Your Journey'),
        subtitle: controller.nextJourneyNode?.subtitleMizo ??
            '${controller.journeyState.completedNodeIds.length}/${journeyNodes.length} story stops • Daily quests',
        onTap: () => _open(context, JourneyScreen(controller: controller)),
      ),
    ]);
    final challenge =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(
          height: 48,
          child: Align(
              alignment: Alignment.centerLeft,
              child: SectionTitle('Daily Challenge'))),
      const SizedBox(height: 8),
      _FeatureCard(
        icon: Icons.auto_awesome_rounded,
        colors: const [Color(0xFFFF8A6B), Color(0xFFF0566A)],
        eyebrow: 'TAWNG UPA • 10 ZAWHNA',
        title: 'Tawng Upa Challenge',
        subtitle: 'Thumal awmzia hriatna',
        trailingLabel: (controller.bestScores['tawng_upa'] ?? 0) > 0
            ? 'BEST ${controller.bestScores['tawng_upa']}'
            : null,
        onTap: () => _open(context, OldWordQuizGame(controller: controller)),
      ),
    ]);
    return LayoutBuilder(builder: (context, constraints) {
      if (!journeyVisible) return challenge;
      if (constraints.maxWidth >= 720) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: journey),
          const SizedBox(width: 16),
          Expanded(child: challenge),
        ]);
      }
      return Column(children: [journey, const SizedBox(height: 20), challenge]);
    });
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.controller});
  final QuestController controller;
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: QuestShadows.card),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset('assets/branding/hnahsin_icon.png',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                    width: 52,
                    height: 52,
                    child: ColoredBox(color: QuestColors.indigo))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Chibai! 👋',
              style: TextStyle(
                  color: QuestColors.slate,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5)),
          Text('Hnahsin',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall),
        ])),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
              boxShadow: QuestShadows.card),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  gradient: QuestGradients.gold, shape: BoxShape.circle),
              child: const Icon(Icons.bolt_rounded,
                  size: 17, color: QuestColors.midnight),
            ),
            const SizedBox(width: 7),
            Text('Lv ${controller.level}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: QuestColors.navy)),
          ]),
        ),
      ]);
}

class _DailyHero extends StatelessWidget {
  const _DailyHero({required this.controller});
  final QuestController controller;

  @override
  Widget build(BuildContext context) {
    final placed = controller.learningState.placementCompleted;
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Container(
      decoration: BoxDecoration(
        gradient: QuestGradients.hero,
        borderRadius: BorderRadius.circular(QuestRadius.hero),
        boxShadow: QuestShadows.raised,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(QuestRadius.hero),
        child: Stack(children: [
          const Positioned(
              right: -40,
              top: -50,
              child: _Glow(size: 190, color: Color(0x3339D6C4))),
          const Positioned(
              left: -30,
              bottom: -70,
              child: _Glow(size: 170, color: Color(0x264A6BE0))),
          Padding(
            padding: EdgeInsets.all(compact ? 18 : 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: const Color(0x228FD0FA),
                            borderRadius: BorderRadius.circular(99)),
                        child: Text(
                          '${controller.learningState.level.code} • ${controller.track.title.toUpperCase()}',
                          style: const TextStyle(
                              color: QuestColors.teal,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vawiin thumal 5\nzir ila.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 24 : 28,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${controller.dailyPlan.total} items • Daily learning plan',
                          style: const TextStyle(
                              color: Color(0xFFDDF3FF),
                              fontWeight: FontWeight.w500,
                              fontSize: 13)),
                    ])),
                const SizedBox(width: 12),
                ProgressRing(
                    size: compact ? 74 : 88,
                    value: controller.dailyGoalProgress,
                    label: '${controller.dailyProgress}/5\nDONE'),
              ]),
              const SizedBox(height: 18),
              Wrap(spacing: 8, runSpacing: 8, children: [
                Pill(
                    icon: Icons.local_fire_department_rounded,
                    label: controller.profile.gentleMode
                        ? 'Learning rhythm'
                        : '${controller.streak} day streak',
                    color: const Color(0x26FFC94A),
                    foreground: QuestColors.gold),
                Pill(
                    icon: Icons.bolt_rounded,
                    label: '${controller.xp} XP',
                    color: const Color(0x228FD0FA),
                    foreground: QuestColors.teal),
              ]),
              const SizedBox(height: 18),
              _GoldButton(
                icon: Icons.play_arrow_rounded,
                label: placed ? 'Start Daily Lesson' : 'Find My Mizo Level',
                onPressed: () => _open(
                  context,
                  placed
                      ? DailyReviewScreen(controller: controller)
                      : PlacementScreen(controller: controller),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  RadialGradient(colors: [color, color.withValues(alpha: 0)])),
        ),
      );
}

class _GoldButton extends StatelessWidget {
  const _GoldButton(
      {required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: QuestLayout.of(context) == QuestWidth.compact
                  ? double.infinity
                  : 380),
          child: SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: QuestGradients.gold,
                borderRadius: BorderRadius.circular(18),
                boxShadow: QuestShadows.glow(QuestColors.goldDeep),
              ),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: QuestColors.midnight),
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
              ),
            ),
          ),
        ),
      );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard(
      {required this.icon,
      required this.colors,
      required this.eyebrow,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.trailingLabel});
  final IconData icon;
  final List<Color> colors;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String? trailingLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors),
              borderRadius: BorderRadius.circular(19),
              boxShadow: QuestShadows.glow(colors.last),
            ),
            child: Icon(icon, color: Colors.white, size: 29),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(eyebrow,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: colors.last,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .9)),
                const SizedBox(height: 3),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16.5)),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: QuestColors.slate, fontSize: 13)),
              ])),
          const SizedBox(width: 8),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: colors.first.withValues(alpha: .12),
                  shape: BoxShape.circle),
              child: Icon(Icons.arrow_forward_rounded,
                  color: colors.last, size: 20),
            ),
            if (trailingLabel != null) ...[
              const SizedBox(height: 4),
              Text(trailingLabel!,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: QuestColors.tealDark)),
            ],
          ]),
        ]),
      );
}

class _IconTile extends StatelessWidget {
  const _IconTile(
      {required this.icon, required this.color, required this.foreground});
  final IconData icon;
  final Color color;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(17)),
      child: Icon(icon, color: foreground, size: 27));
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key, required this.controller});
  final QuestController controller;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => QuestTabPage(children: [
          PageIntro(
            eyebrow: 'Your course',
            title: 'Learn',
            subtitle:
                '${controller.learningState.level.code} ${controller.learningState.level.title} • Mahni chak zawngin zir chhunzawm rawh.',
          ),
          const SizedBox(height: 20),
          LearningOverviewCard(controller: controller),
          const SizedBox(height: 26),
          const SectionTitle('Word Library'),
          const SizedBox(height: 12),
          PremiumCard(
            onTap: () => _open(context, WordBankScreen(controller: controller)),
            gradient: const LinearGradient(
                colors: [Color(0xFFDDF3FF), Color(0xFFF5FBFA)]),
            child: Row(children: [
              const _IconTile(
                  icon: Icons.menu_book_rounded,
                  color: Colors.white,
                  foreground: QuestColors.tealDark),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Word Library',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 17)),
                    const SizedBox(height: 3),
                    Text(
                        '${controller.wordCatalog.where((entry) => ContentPolicy.playable(entry.review)).length} words • ${WordCategory.values.length} categories',
                        style: const TextStyle(color: QuestColors.slate)),
                  ])),
              const Icon(Icons.arrow_forward_rounded,
                  color: QuestColors.tealDark),
            ]),
          ),
          const SizedBox(height: 26),
          _LessonStep(
              number: 1,
              icon: Icons.image_rounded,
              color: const Color(0xFFFFF0BD),
              foreground: const Color(0xFF9A6800),
              title: 'Picture & Words',
              subtitle: 'Thumal bul leh a awmzia',
              state: controller.completedGames.contains('picture_match')
                  ? _LessonState.done
                  : _LessonState.current,
              onTap: () =>
                  _open(context, PictureMatchGame(controller: controller))),
          _LessonStep(
              number: 2,
              icon: Icons.spellcheck_rounded,
              color: const Color(0xFFDDF3FF),
              foreground: QuestColors.tealDark,
              title: 'Spelling',
              subtitle: 'Hawrawp ruak dah khat',
              state: controller.completedGames.contains('spelling')
                  ? _LessonState.done
                  : _LessonState.open,
              onTap: () =>
                  _open(context, SpellingGame(controller: controller))),
          _LessonStep(
              number: 3,
              icon: Icons.search_rounded,
              color: const Color(0xFFE9E4FF),
              foreground: QuestColors.violet,
              title: 'Word Search',
              subtitle: 'Grid chhunga thumal zawn',
              state: controller.completedGames.contains('word_search')
                  ? _LessonState.done
                  : _LessonState.open,
              onTap: () =>
                  _open(context, WordSearchGame(controller: controller))),
          _LessonStep(
              number: 4,
              icon: Icons.forum_rounded,
              color: const Color(0xFFDCF0FF),
              foreground: QuestColors.indigo,
              title: 'Tawng Upa',
              subtitle: 'Awmzia leh hman dân',
              state: controller.completedGames.contains('tawng_upa')
                  ? _LessonState.done
                  : _LessonState.open,
              onTap: () =>
                  _open(context, OldWordQuizGame(controller: controller))),
          _LessonStep(
              number: 5,
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFFE6F4D9),
              foreground: QuestColors.success,
              title: 'Final Quest',
              subtitle: 'Crossword challenge',
              state: controller.completedGames.contains('crossword')
                  ? _LessonState.done
                  : _LessonState.open,
              onTap: () =>
                  _open(context, MiniCrosswordGame(controller: controller))),
          _LessonStep(
              number: 6,
              icon: Icons.style_rounded,
              color: const Color(0xFFFFE6F0),
              foreground: const Color(0xFFD6457A),
              title: 'Thumal Kawp',
              subtitle: 'Card let la, thumal leh a kawp zawng rawh',
              state: controller.completedGames.contains(ThumalKawpGame.gameId)
                  ? _LessonState.done
                  : _LessonState.open,
              onTap: () =>
                  _open(context, ThumalKawpGame(controller: controller))),
          _LessonStep(
              number: 7,
              icon: Icons.view_stream_rounded,
              color: const Color(0xFFE9E4FF),
              foreground: QuestColors.violet,
              title: 'Sentence Builder',
              subtitle: 'Thumal tiles rem khâwm la, sentence siam rawh',
              state: controller.completedGames.contains('sentence_builder')
                  ? _LessonState.done
                  : _LessonState.open,
              onTap: () =>
                  _open(context, SentenceBuilderGame(controller: controller))),
        ]),
      );
}

enum _LessonState { done, current, open }

class _LessonStep extends StatelessWidget {
  const _LessonStep(
      {required this.number,
      required this.icon,
      required this.color,
      required this.foreground,
      required this.title,
      required this.subtitle,
      required this.state,
      required this.onTap});
  final int number;
  final IconData icon;
  final Color color;
  final Color foreground;
  final String title;
  final String subtitle;
  final _LessonState state;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final active = state == _LessonState.current;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: PremiumCard(
        onTap: onTap,
        gradient: active
            ? const LinearGradient(
                colors: [QuestColors.navy, QuestColors.indigo])
            : null,
        child: Row(children: [
          _IconTile(
              icon: icon,
              color: active ? const Color(0xFFDDF3FF) : color,
              foreground: active ? QuestColors.tealDark : foreground),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('$number. $title',
                    style: TextStyle(
                        color: active ? Colors.white : QuestColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 17)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        color: active
                            ? const Color(0xFFDDF3FF)
                            : QuestColors.slate)),
              ])),
          Icon(
              state == _LessonState.done
                  ? Icons.check_circle_rounded
                  : Icons.play_circle_fill_rounded,
              color: state == _LessonState.done
                  ? QuestColors.success
                  : (active ? QuestColors.gold : QuestColors.indigo)),
        ]),
      ),
    );
  }
}

List<_GameInfo> _gameCatalog(QuestController controller) {
  return <_GameInfo>[
    _GameInfo(
        'picture_match',
        GameText.of('picture_match').title,
        Icons.image_rounded,
        GameText.of('picture_match').subtitle,
        const Color(0xFFFFF0BD),
        const Color(0xFF9A6800),
        GameText.of('picture_match').instructions,
        (mode) => PictureMatchGame(controller: controller, mode: mode)),
    _GameInfo(
        'spelling',
        GameText.of('spelling').title,
        Icons.spellcheck_rounded,
        GameText.of('spelling').subtitle,
        const Color(0xFFDDF3FF),
        QuestColors.tealDark,
        GameText.of('spelling').instructions,
        (mode) => SpellingGame(controller: controller, mode: mode)),
    _GameInfo(
        'word_search',
        GameText.of('word_search').title,
        Icons.search_rounded,
        GameText.of('word_search').subtitle,
        const Color(0xFFE9E4FF),
        QuestColors.violet,
        GameText.of('word_search').instructions,
        (mode) => WordSearchGame(controller: controller, mode: mode)),
    _GameInfo(
        'word_chain',
        GameText.of('word_chain').title,
        Icons.link_rounded,
        GameText.of('word_chain').subtitle,
        const Color(0xFFFFE6E3),
        QuestColors.coral,
        GameText.of('word_chain').instructions,
        (mode) => WordChainGame(controller: controller, mode: mode)),
    _GameInfo(
        'tawng_upa',
        GameText.of('tawng_upa').title,
        Icons.forum_rounded,
        GameText.of('tawng_upa').subtitle,
        const Color(0xFFDCF0FF),
        QuestColors.indigo,
        GameText.of('tawng_upa').instructions,
        (mode) => OldWordQuizGame(controller: controller, mode: mode)),
    _GameInfo(
        'crossword',
        GameText.of('crossword').title,
        Icons.grid_on_rounded,
        GameText.of('crossword').subtitle,
        const Color(0xFFE6F4D9),
        QuestColors.success,
        GameText.of('crossword').instructions,
        (mode) => MiniCrosswordGame(controller: controller, mode: mode)),
    _GameInfo(
        ThumalKawpGame.gameId,
        GameText.of(ThumalKawpGame.gameId).title,
        Icons.style_rounded,
        GameText.of(ThumalKawpGame.gameId).subtitle,
        const Color(0xFFFFE6F0),
        const Color(0xFFD6457A),
        GameText.of(ThumalKawpGame.gameId).instructions,
        (mode) => ThumalKawpGame(controller: controller, mode: mode)),
    _GameInfo(
        'sentence_builder',
        GameText.of('sentence_builder').title,
        Icons.view_stream_rounded,
        GameText.of('sentence_builder').subtitle,
        const Color(0xFFE9E4FF),
        QuestColors.violet,
        GameText.of('sentence_builder').instructions,
        (mode) => SentenceBuilderGame(controller: controller, mode: mode)),
  ];
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key, required this.controller});
  final QuestController controller;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final games = _gameCatalog(controller);
          final completed = games
              .where((game) => controller.completedGames.contains(game.id))
              .length;
          return QuestTabPage(children: [
            PageIntro(
              eyebrow: 'Practice arena',
              title: 'Games',
              subtitle: 'I duh zawng thlang la, i score sang ber siam rawh.',
              trailing: _CompletionBadge(done: completed, total: games.length),
            ),
            const SizedBox(height: 22),
            _GameGrid(controller: controller, games: games),
          ]);
        },
      );
}

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.done, required this.total});
  final int done;
  final int total;
  @override
  Widget build(BuildContext context) => Container(
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            gradient: QuestGradients.hero,
            borderRadius: BorderRadius.circular(20),
            boxShadow: QuestShadows.card),
        child: Column(children: [
          const Icon(Icons.emoji_events_rounded,
              color: QuestColors.gold, size: 22),
          const SizedBox(height: 2),
          Text('$done/$total',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          const Text('PLAYED',
              style: TextStyle(
                  color: Color(0xFF8FD0FA),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8)),
        ]),
      );
}

class _GameGrid extends StatelessWidget {
  const _GameGrid(
      {required this.controller,
      required this.games,
      this.maxRows,
      this.maxRowsWide});
  final QuestController controller;
  final List<_GameInfo> games;

  /// Limits a preview grid to whole rows (phones / wider layouts).
  final int? maxRows;
  final int? maxRowsWide;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 840
            ? 4
            : constraints.maxWidth >= 560
                ? 3
                : 2;
        const spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final rows = columns == 2 ? maxRows : maxRowsWide ?? maxRows;
        final shown = rows == null ? games : games.take(rows * columns);
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final game in shown)
              SizedBox(
                width: width,
                child: _GameCard(
                  game: game,
                  level: controller.gameLevel(game.id),
                  completed: controller.completedGames.contains(game.id),
                  best: controller.bestScores[game.id] ?? 0,
                  onTap: () => _open(
                    context,
                    GameLaunchScreen(
                        controller: controller,
                        gameId: game.id,
                        title: game.title,
                        subtitle: game.subtitle,
                        instructions: game.instructions,
                        builder: game.builder),
                  ),
                ),
              ),
          ],
        );
      });
}

class _GameInfo {
  const _GameInfo(this.id, this.title, this.icon, this.subtitle, this.color,
      this.foreground, this.instructions, this.builder);
  final String id;
  final String title;
  final IconData icon;
  final String subtitle;
  final Color color;
  final Color foreground;
  final List<String> instructions;
  final Widget Function(GameMode mode) builder;
}

class _GameCard extends StatelessWidget {
  const _GameCard(
      {required this.game,
      required this.level,
      required this.completed,
      required this.best,
      required this.onTap});
  final _GameInfo game;
  final int level;
  final bool completed;
  final int best;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 92,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    game.color,
                    Color.lerp(game.color, Colors.white, .55)!
                  ]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(children: [
              Positioned(
                right: -14,
                bottom: -18,
                child: Icon(game.icon,
                    size: 92, color: game.foreground.withValues(alpha: .12)),
              ),
              Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: QuestShadows.glow(game.foreground)),
                  child: Icon(game.icon, color: game.foreground, size: 28),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .85),
                      borderRadius: BorderRadius.circular(99)),
                  child: Text('Lv $level',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: game.foreground)),
                ),
              ),
              if (completed)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.verified_rounded,
                      color: QuestColors.success, size: 22),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(game.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15.5)),
              const SizedBox(height: 2),
              Text(game.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: QuestColors.slate, fontSize: 12)),
              const SizedBox(height: 10),
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: best > 0
                          ? const Color(0xFFFFF4CA)
                          : const Color(0xFFEAF6FF),
                      borderRadius: BorderRadius.circular(99)),
                  child: Text(
                    best > 0 ? '★ $best' : 'PLAY',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: .4,
                        color: best > 0
                            ? const Color(0xFF9A6800)
                            : QuestColors.indigo),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                      gradient: QuestGradients.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 19),
                ),
              ]),
            ]),
          ),
        ]),
      );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});
  final QuestController controller;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (context, _) => QuestTabPage(children: [
            const PageIntro(
              eyebrow: 'Your journey',
              title: 'Profile',
              subtitle: 'I zirna progress leh level-te hetah en rawh.',
            ),
            const SizedBox(height: 20),
            PremiumCard(
                gradient: const LinearGradient(
                    colors: [QuestColors.midnight, QuestColors.indigo]),
                child: Column(children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: QuestColors.gold,
                    child: Text(
                      controller.selectedAvatar.emoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Thumal ${controller.profile.experienceLabel}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                      '${controller.profile.ageBand.label} • ${controller.learningState.level.code} • ${controller.selectedAvatar.labelFor(isChild: controller.profile.isChild)}',
                      style: const TextStyle(
                          color: QuestColors.teal,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                      value: controller.levelProgress,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(99),
                      backgroundColor: const Color(0xFF32486E),
                      valueColor:
                          const AlwaysStoppedAnimation(QuestColors.gold)),
                  const SizedBox(height: 8),
                  Text('${controller.xp % 250}/250 XP level thar atan',
                      style: const TextStyle(color: Color(0xFFDDF3FF))),
                ])),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _StatCard(
                      value: controller.profile.gentleMode
                          ? 'Calm'
                          : '${controller.streak}',
                      label: controller.profile.gentleMode
                          ? 'My Pace'
                          : 'Day Streak',
                      icon: Icons.local_fire_department_rounded,
                      color: QuestColors.coral)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      value: '${controller.completedGames.length}',
                      label: 'Games',
                      icon: Icons.emoji_events_rounded,
                      color: const Color(0xFFB47A00))),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      value: '${controller.completedLessons}',
                      label: 'Lessons',
                      icon: Icons.auto_stories_rounded,
                      color: QuestColors.tealDark)),
            ]),
            if (!JourneyContentPolicy.isProduction ||
                JourneyContentPolicy.releaseReady) ...[
              const SizedBox(height: 14),
              PremiumCard(
                onTap: () =>
                    _open(context, JourneyScreen(controller: controller)),
                child: Row(children: [
                  const Icon(Icons.route_rounded, color: QuestColors.violet),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('Mizo Journey Collection',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        Text(
                          '${controller.journeyState.completedNodeIds.length}/${journeyNodes.length} stories • ${controller.journeyState.unlockedRewardIds.length} rewards',
                          style: const TextStyle(
                              color: QuestColors.slate, fontSize: 12),
                        ),
                      ])),
                  const Icon(Icons.arrow_forward_rounded,
                      color: QuestColors.indigo),
                ]),
              ),
            ],
            const SizedBox(height: 28),
            const SectionTitle('Learning Level'),
            const SizedBox(height: 12),
            ...LearningTrack.values.map((track) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AnswerButton(
                    label:
                        '${track.symbol}  ${track.title} — ${track.audience}',
                    selected: controller.track == track,
                    onTap: () => controller.selectTrack(track)))),
            const SizedBox(height: 14),
            const PremiumCard(
                child: Row(children: [
              Icon(Icons.verified_user_rounded, color: QuestColors.tealDark),
              SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Family-friendly',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('No public chat • Progress saved on this device',
                        style:
                            TextStyle(color: QuestColors.slate, fontSize: 12))
                  ]))
            ])),
            const SizedBox(height: 14),
            ContentDeliveryStatusCard(controller: controller),
            const SizedBox(height: 14),
            PremiumCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                SwitchListTile(
                  title: const Text('Reduce motion',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('Use fewer interface animations'),
                  secondary: const Icon(Icons.motion_photos_off_rounded,
                      color: QuestColors.indigo),
                  value: controller.profile.reducedMotion,
                  onChanged: (value) => controller.updateProfile(
                      controller.profile.copyWith(reducedMotion: value)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Gentle engagement',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text(
                      'Keep quests optional and hide streak pressure'),
                  secondary: const Icon(Icons.self_improvement_rounded,
                      color: QuestColors.indigo),
                  value: controller.profile.gentleMode,
                  onChanged: (value) => controller.updateProfile(
                      controller.profile.copyWith(gentleMode: value)),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Reset Local Progress'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Reset local progress?'),
                      content: const Text(
                          'Your XP, scores, settings and saved game sessions on this device will be deleted. This cannot be undone.'),
                      actions: [
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('Reset')),
                      ],
                    ),
                  );
                  if (confirmed == true) await controller.resetAll();
                },
              ),
            ),
          ]));
}

class WordBankScreen extends StatefulWidget {
  const WordBankScreen({super.key, required this.controller});
  final QuestController controller;
  @override
  State<WordBankScreen> createState() => _WordBankScreenState();
}

class _WordBankScreenState extends State<WordBankScreen> {
  WordCategory? category;

  @override
  Widget build(BuildContext context) {
    final playableEntries = widget.controller.wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .toList();
    final entries = category == null
        ? playableEntries
        : playableEntries.where((entry) => entry.category == category).toList();
    return QuestPage(
      title: 'Word Library',
      subtitle: '${entries.length} words',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            height: 42,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                      label: const Text('All'),
                      selected: category == null,
                      onSelected: (_) => setState(() => category = null))),
              ...WordCategory.values.map((item) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                      label: Text(item.englishLabel),
                      selected: category == item,
                      onSelected: (_) => setState(() => category = item)))),
            ])),
        const SizedBox(height: 18),
        ...entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PremiumCard(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                        width: 54,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: QuestColors.mist,
                            borderRadius: BorderRadius.circular(17)),
                        child: WordPicture(entry: entry, size: 30)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(children: [
                            Expanded(
                                child: Text(entry.word,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18))),
                            Text(entry.englishGloss,
                                style: const TextStyle(
                                    color: QuestColors.tealDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12))
                          ]),
                          const SizedBox(height: 4),
                          Text(entry.meaningMizo,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 5),
                          Text('“${entry.exampleMizo}”',
                              style: const TextStyle(
                                  color: QuestColors.slate,
                                  fontStyle: FontStyle.italic)),
                        ])),
                  ])),
            )),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      child: Column(children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 7),
        Text(value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10,
                color: QuestColors.slate,
                fontWeight: FontWeight.w600))
      ]));
}

void _open(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
