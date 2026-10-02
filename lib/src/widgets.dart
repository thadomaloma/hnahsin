import 'package:flutter/material.dart';

import '../features/games/engine/game_engine.dart';
import 'controller.dart';
import 'data.dart';
import 'game_session.dart';
import 'game_text.dart';
import 'theme.dart';
import 'app_text.dart';

class QuestPage extends StatelessWidget {
  const QuestPage({super.key, required this.title, required this.child, this.subtitle, this.hud});
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? hud;

  @override
  Widget build(BuildContext context) {
    final gutter = QuestLayout.gutter(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(gutter - 4, 8, gutter, 6),
            child: ScreenFrame(
              maxWidth: 760,
              child: Row(children: [
                _BackButton(onPressed: () => Navigator.of(context).maybePop()),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, color: QuestColors.slate, fontWeight: FontWeight.w600),
                      ),
                  ]),
                ),
              ]),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 32 + MediaQuery.paddingOf(context).bottom),
              child: ScreenFrame(
                maxWidth: 720,
                child: Column(children: [if (hud != null) ...[hud!, const SizedBox(height: 16)], child]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: AppText.of('common.back'),
        child: ExcludeSemantics(
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(side: BorderSide(color: QuestColors.line)),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(Icons.arrow_back_rounded, color: QuestColors.ink, size: 22),
              ),
            ),
          ),
        ),
      );
}

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({super.key, required this.child, this.maxWidth = QuestLayout.contentMaxWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Scrollable body for the four main tabs: responsive gutters, a centred
/// content column on wide screens and room for the floating navigation.
class QuestTabPage extends StatelessWidget {
  const QuestTabPage({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final gutter = QuestLayout.gutter(context);
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(gutter, 16, gutter, QuestLayout.bottomInset(context)),
        child: ScreenFrame(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ),
    );
  }
}

class PremiumCard extends StatefulWidget {
  const PremiumCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.gradient, this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  bool pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || pressed == value) return;
    setState(() => pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(QuestRadius.large);
    final dark = widget.gradient != null;
    final card = AnimatedScale(
      scale: pressed ? .975 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? null : Colors.white,
          gradient: widget.gradient,
          borderRadius: radius,
          border: dark ? null : Border.all(color: const Color(0xFFE9EDF3)),
          boxShadow: QuestShadows.card,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: widget.onTap == null
              ? Padding(padding: widget.padding, child: widget.child)
              : InkWell(
                  onTap: widget.onTap,
                  onHighlightChanged: _setPressed,
                  borderRadius: radius,
                  child: Padding(padding: widget.padding, child: widget.child),
                ),
        ),
      ),
    );
    if (widget.onTap == null) return card;
    return Semantics(button: true, child: card);
  }
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.icon, required this.label, this.color = Colors.white, this.foreground = QuestColors.navy});
  final IconData icon;
  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: foreground),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w800, fontSize: 13)),
        ]),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (trailing != null) trailing!,
      ]);
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final wide = QuestLayout.of(context) != QuestWidth.compact;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFDDF3FF), borderRadius: BorderRadius.circular(99)),
                  child: Text(
                    eyebrow.toUpperCase(),
                    style: const TextStyle(color: QuestColors.tealDark, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                  ),
                ),
                const SizedBox(height: 10),
                Text(title, style: wide ? Theme.of(context).textTheme.displayMedium : Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: QuestColors.slate, height: 1.45, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.label,
    this.size = 88,
    this.foreground = QuestColors.gold,
    this.background = const Color(0x33FFFFFF),
  });

  final double value;
  final String label;
  final double size;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0, 1).toDouble()),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, animated, _) => CircularProgressIndicator(
                value: animated,
                strokeWidth: 9,
                strokeCap: StrokeCap.round,
                color: foreground,
                backgroundColor: background,
              ),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.15),
          ),
        ],
      ),
    );
  }
}

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.session,
    required this.progress,
    this.secondsRemaining,
  });
  final GameSession session;
  final double progress;
  final int? secondsRemaining;

  @override
  Widget build(BuildContext context) {
    final relaxed = session.mode == GameMode.relaxed;
    final lowTime = secondsRemaining != null && secondsRemaining! <= 15;
    return Semantics(
      label: relaxed
          ? AppText.of('hud.relaxedSpoken', {'score': session.score, 'percent': (progress * 100).round()})
          : [
              AppText.of('hud.heartsSpoken', {'hearts': session.hearts, 'total': session.startingHearts}),
              if (secondsRemaining != null) AppText.of('hud.secondsSpoken', {'seconds': secondsRemaining}),
              AppText.of('hud.scoreSpoken', {'score': session.score, 'percent': (progress * 100).round()}),
            ].join(' '),
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            gradient: QuestGradients.hero,
            borderRadius: BorderRadius.circular(QuestRadius.large),
            boxShadow: QuestShadows.card,
          ),
          child: Column(children: [
            Row(children: [
              if (relaxed)
                _HudChip(icon: Icons.eco_rounded, label: AppText.of('hud.relaxed'), iconColor: QuestColors.teal)
              else
                Row(mainAxisSize: MainAxisSize.min, children: [
                  for (var i = 0; i < session.startingHearts; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        i < session.hearts ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 22,
                        color: i < session.hearts ? QuestColors.coral : const Color(0x66FFFFFF),
                      ),
                    ),
                ]),
              const Spacer(),
              if (secondsRemaining != null)
                _HudChip(
                  icon: Icons.timer_rounded,
                  label: '${secondsRemaining}s',
                  iconColor: lowTime ? QuestColors.coral : QuestColors.gold,
                  highlight: lowTime,
                )
              else if (session.combo > 1)
                _HudChip(icon: Icons.bolt_rounded, label: 'x${session.combo}', iconColor: QuestColors.gold),
              const SizedBox(width: 8),
              _HudChip(icon: Icons.star_rounded, label: '${session.score}', iconColor: QuestColors.gold),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Stack(children: [
                Container(height: 9, color: const Color(0x33FFFFFF)),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: progress.clamp(0, 1).toDouble()),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 9,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [QuestColors.teal, QuestColors.gold]),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({required this.icon, required this.label, required this.iconColor, this.highlight = false});
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool highlight;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: highlight ? QuestColors.coral.withValues(alpha: .25) : const Color(0x1FFFFFFF),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: iconColor),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
        ]),
      );
}

/// The framed "question" area at the top of a round: soft glow, generous
/// padding and a centred prompt, so every game opens on the same stage.
class GameStage extends StatelessWidget {
  const GameStage({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(QuestRadius.hero),
          border: Border.all(color: const Color(0xFFE9EDF3)),
          boxShadow: QuestShadows.card,
          gradient: const RadialGradient(
            center: Alignment(0, -.6),
            radius: 1.1,
            colors: [Color(0xFFFFF7DC), Colors.white],
          ),
        ),
        child: child,
      );
}

class GameResumeBanner extends StatelessWidget {
  const GameResumeBanner({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFDDF3FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF8FD0FA)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.restore_rounded, color: QuestColors.tealDark),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppText.of('game.restored'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
}

class GameHintButton extends StatelessWidget {
  const GameHintButton({
    super.key,
    required this.revealed,
    required this.onPressed,
  });

  final bool revealed;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: revealed ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9A6800),
              backgroundColor: revealed ? Colors.transparent : const Color(0xFFFFF4CA),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
            ),
            icon: Icon(revealed ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded, size: 19),
            label: Text(revealed ? AppText.of('game.hintUsed') : AppText.of('game.useHint')),
          ),
        ),
      );
}

class GameHintCard extends StatelessWidget {
  const GameHintCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        label: message,
        child: ExcludeSemantics(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7D6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFBE6A2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.lightbulb_rounded, color: Color(0xFF9A6800)),
                const SizedBox(width: 10),
                Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4))),
              ],
            ),
          ),
        ),
      );
}

class AnswerButton extends StatefulWidget {
  const AnswerButton({super.key, required this.label, required this.onTap, this.selected = false, this.correct, this.badge});
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final bool? correct;

  /// Optional short marker (A, B, C…) shown in the leading badge.
  final String? badge;

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    var background = Colors.white;
    var border = const Color(0xFFD6E6F2);
    var accent = QuestColors.slate;
    IconData? icon;
    if (widget.selected) {
      background = const Color(0xFFEAF6FF);
      border = QuestColors.indigo;
      accent = QuestColors.indigo;
    }
    if (widget.correct == true) {
      background = const Color(0xFFE6F5E2);
      border = QuestColors.success;
      accent = QuestColors.successInk;
      icon = Icons.check_rounded;
    } else if (widget.correct == false) {
      background = const Color(0xFFFCE4EC);
      border = QuestColors.coral;
      accent = QuestColors.coral;
      icon = Icons.close_rounded;
    }
    final highlighted = widget.selected || widget.correct != null;
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.correct == true
          ? AppText.of('answer.correctSpoken', {'answer': widget.label})
          : widget.correct == false
              ? AppText.of('answer.incorrectSpoken', {'answer': widget.label})
              : widget.label,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTapDown: widget.onTap == null ? null : (_) => setState(() => pressed = true),
          onTapCancel: () => setState(() => pressed = false),
          onTapUp: (_) => setState(() => pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: pressed ? .97 : 1,
            duration: const Duration(milliseconds: 120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
              decoration: BoxDecoration(
                color: background,
                border: Border.all(color: border, width: highlighted ? 2 : 1.5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: highlighted
                    ? QuestShadows.glow(accent)
                    : const [BoxShadow(color: Color(0x0A07162F), blurRadius: 0, offset: Offset(0, 3))],
              ),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: highlighted ? accent : QuestColors.mist,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: icon != null
                      ? Icon(icon, size: 20, color: Colors.white)
                      : widget.badge != null
                          ? Text(widget.badge!, style: TextStyle(fontWeight: FontWeight.w800, color: highlighted ? Colors.white : QuestColors.slate))
                          : Icon(Icons.circle, size: 9, color: highlighted ? Colors.white : const Color(0xFFB4BFCE)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5, height: 1.3, color: QuestColors.ink),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class FeedbackCard extends StatelessWidget {
  const FeedbackCard({super.key, required this.correct, required this.message});
  final bool correct;
  final String message;
  @override
  Widget build(BuildContext context) {
    final accent = correct ? QuestColors.successInk : QuestColors.coral;
    return Semantics(
      liveRegion: true,
      label: '${correct ? AppText.of('feedback.correctSpoken') : AppText.of('feedback.retrySpoken')}. $message',
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          builder: (context, t, child) => Transform.translate(offset: Offset(0, 14 * (1 - t)), child: Opacity(opacity: t.clamp(0, 1).toDouble(), child: child)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: correct ? const Color(0xFFE6F5E2) : const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: .35)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                child: Icon(correct ? Icons.check_rounded : Icons.lightbulb_rounded, color: Colors.white, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(correct ? GameText.common.correctFeedback : GameText.common.retryFeedback, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: accent)),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(message, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
                  ],
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// [context] is the game's own State context: “Khelh leh” starts its widget
/// again as a fresh round.
Future<void> showGameResult(BuildContext context, QuestController controller, String gameId, GameResult result) async {
  final game = context.widget;
  final outcome = await controller.reward(gameId, result);
  await controller.clearSession(result.sessionId);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 560),
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 26),
          decoration: const BoxDecoration(
            gradient: QuestGradients.hero,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(children: [
            Container(width: 42, height: 5, decoration: BoxDecoration(color: const Color(0x55FFFFFF), borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(3, (index) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 450 + index * 180),
                curve: Curves.elasticOut,
                builder: (context, t, child) => Transform.scale(scale: t, child: child),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star_rounded,
                    size: index == 1 ? 58 : 46,
                    color: index < result.stars ? QuestColors.gold : const Color(0x40FFFFFF),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 12),
            Text(
              AppText.of(switch (result.endReason) { GameEndReason.timedOut => 'result.timeUp', GameEndReason.heartsExhausted => 'result.outOfHearts', _ => 'result.done' }),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.5),
            ),
            const SizedBox(height: 6),
            Text(
              AppText.of(switch (result.endReason) { GameEndReason.timedOut => 'result.timeUpNote', GameEndReason.heartsExhausted => 'result.outOfHeartsNote', _ => 'result.doneNote' }),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFDDF3FF), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
            _LevelBanner(outcome: outcome),
          ]),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).padding.bottom),
          child: Column(children: [
            Row(children: [
              Expanded(child: _ResultStat(icon: Icons.star_rounded, color: QuestColors.goldDeep, label: AppText.of('result.score'), value: '${result.score}')),
              const SizedBox(width: 10),
              Expanded(child: _ResultStat(icon: Icons.track_changes_rounded, color: QuestColors.tealDark, label: AppText.of('result.accuracy'), value: '${(result.accuracy * 100).round()}%')),
              const SizedBox(width: 10),
              Expanded(child: _ResultStat(icon: Icons.bolt_rounded, color: QuestColors.indigo, label: AppText.of('result.xp'), value: '+${outcome.xp}')),
            ]),
            if (result.words.isNotEmpty) ...[
              const SizedBox(height: 18),
              _RoundWords(words: result.words),
            ],
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () { Navigator.of(sheetContext).pop(); Navigator.of(context).pop(); },
                child: Text(AppText.of('common.continue')),
              )),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => game));
                },
                icon: const Icon(Icons.replay_rounded),
                label: Text(AppText.of('result.playAgain')),
              )),
            ]),
          ]),
        ),
      ]),
    ),
  );
}

/// The words a round asked about: missed ones first (they come back in later
/// rounds), so the result quietly doubles as a recap.
class _RoundWords extends StatelessWidget {
  const _RoundWords({required this.words});
  final List<WordPlay> words;

  static const _shown = 12;

  @override
  Widget build(BuildContext context) {
    final ordered = [...words.where((w) => w.missed), ...words.where((w) => !w.missed)];
    final missed = words.where((w) => w.missed).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppText.of('result.words'), style: const TextStyle(fontWeight: FontWeight.w800, color: QuestColors.navy)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final play in ordered.take(_shown))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: play.missed ? const Color(0xFFFCE4EC) : const Color(0xFFE6F5E2),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(play.word, style: TextStyle(
              fontWeight: FontWeight.w700,
              color: play.missed ? QuestColors.coral : QuestColors.successInk,
            )),
          ),
        if (ordered.length > _shown)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('+${ordered.length - _shown}', style: const TextStyle(color: QuestColors.slate, fontWeight: FontWeight.w700)),
          ),
      ]),
      if (missed > 0) ...[
        const SizedBox(height: 6),
        Text(AppText.of('result.missedNote'), style: const TextStyle(color: QuestColors.slate, fontSize: 13)),
      ],
    ]);
  }
}

/// The learner's adaptive level for one game, with progress to the next.
class GameLevelCard extends StatelessWidget {
  const GameLevelCard({super.key, required this.skill});
  final double skill;

  @override
  Widget build(BuildContext context) {
    final level = skill.floor();
    final toNext = level >= 7 ? 1.0 : skill - level;
    return Semantics(
      label: AppText.of('gameLevel.spoken', {'level': level}),
      child: ExcludeSemantics(
        child: PremiumCard(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(gradient: QuestGradients.gold, borderRadius: BorderRadius.circular(16)),
              child: Text('$level', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: QuestColors.midnight)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(level >= 7 ? AppText.of('gameLevel.master') : AppText.of('gameLevel.level', {'level': level}), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 2),
                Text(AppText.of('gameLevel.note'), style: const TextStyle(color: QuestColors.slate, fontSize: 12.5)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(value: toNext, minHeight: 7, color: QuestColors.goldDeep, backgroundColor: const Color(0xFFFFF1C7)),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _LevelBanner extends StatelessWidget {
  const _LevelBanner({required this.outcome});
  final RewardOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final up = outcome.levelledUp;
    final label = up
        ? AppText.of('result.levelUp', {'from': outcome.previousLevel, 'to': outcome.level})
        : outcome.levelledDown
            ? AppText.of('result.levelDown', {'level': outcome.level})
            : AppText.of('result.levelProgress', {
                'level': outcome.level,
                'percent': ((outcome.skill - outcome.level) * 100).round(),
              });
    return Semantics(
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: up ? QuestGradients.gold : null,
            color: up ? null : const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(up ? Icons.trending_up_rounded : Icons.military_tech_rounded, size: 19, color: up ? QuestColors.midnight : QuestColors.gold),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: up ? QuestColors.midnight : Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.icon, required this.color, required this.label, required this.value});
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(color: QuestColors.canvas, borderRadius: BorderRadius.circular(18), border: Border.all(color: QuestColors.line)),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8, color: QuestColors.slate)),
        ]),
      );
}

/// A word's picture: its illustration when one exists, otherwise its emoji,
/// otherwise a neutral initial-letter tile (never an unrelated symbol).
class WordPicture extends StatelessWidget {
  const WordPicture({super.key, required this.entry, this.size = 48});

  final WordEntry entry;
  final double size;

  @override
  Widget build(BuildContext context) {
    final uploaded = WordImages.of(entry.imageChecksum);
    if (uploaded != null) {
      return Image.memory(uploaded, height: size, width: size, fit: BoxFit.contain, gaplessPlayback: true);
    }
    final assetPath = illustrationFor(entry);
    if (assetPath != null) {
      return Image.asset(assetPath, height: size, width: size);
    }
    if (entry.emoji.trim().isNotEmpty) {
      return Text(entry.emoji, style: TextStyle(fontSize: size * 0.92, height: 1.1));
    }
    // No picture or emoji depicts the word (abstract words, many verbs): its
    // topic's icon stands in. hasWordPicture stays false, so picture games
    // never ask about it.
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFDDF3FF), Color(0xFFEAF6FF)]),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(categoryIcon(entry.category), size: size * 0.56, color: QuestColors.tealDark),
    );
  }
}

/// The icon a word without its own picture shows, by topic.
IconData categoryIcon(WordCategory category) => switch (category) {
      WordCategory.chhungkua => Icons.family_restroom_rounded,
      WordCategory.sikul => Icons.school_rounded,
      WordCategory.nungcha => Icons.pets_rounded,
      WordCategory.khawvel => Icons.eco_rounded,
      WordCategory.nunphung => Icons.auto_stories_rounded,
      WordCategory.thiltih => Icons.directions_run_rounded,
    };
