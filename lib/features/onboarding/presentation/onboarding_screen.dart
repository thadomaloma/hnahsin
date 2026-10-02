import 'package:flutter/material.dart';

import '../../../src/controller.dart';
import '../../../src/theme.dart';
import '../../../src/widgets.dart';
import '../domain/learner_profile.dart';
import '../../../src/app_text.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final QuestController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages = PageController();
  late LearnerProfile profile;
  int step = 0;
  bool saving = false;

  static const stepCount = 5;

  @override
  void initState() {
    super.initState();
    profile = widget.controller.profile;
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (step < stepCount - 1) {
      setState(() => step += 1);
      await _pages.animateToPage(
        step,
        duration: profile.reducedMotion
            ? Duration.zero
            : const Duration(milliseconds: 340),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    setState(() => saving = true);
    await widget.controller.completeOnboarding(profile);
  }

  Future<void> _back() async {
    if (step == 0) return;
    setState(() => step -= 1);
    await _pages.animateToPage(
      step,
      duration: profile.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEEF5FF), QuestColors.canvas],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: ScreenFrame(
                  child: Row(
                    children: <Widget>[
                      if (step > 0)
                        IconButton(
                          tooltip: AppText.of('common.back'),
                          onPressed: saving ? null : _back,
                          icon: const Icon(Icons.arrow_back_rounded),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.asset(
                            'assets/branding/hnahsin_icon.png',
                            width: 42,
                            height: 42,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              width: 42,
                              height: 42,
                              child: ColoredBox(color: QuestColors.indigo),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppText.of('onboarding.brand'),
                          style: const TextStyle(
                            color: QuestColors.navy,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7,
                          ),
                        ),
                      ),
                      Text(
                        '${step + 1}/$stepCount',
                        semanticsLabel: AppText.of('onboarding.stepSpoken', {'n': step + 1, 'total': stepCount}),
                        style: const TextStyle(
                          color: QuestColors.slate,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ScreenFrame(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (step + 1) / stepCount,
                      minHeight: 7,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    _WelcomeStep(profile: profile),
                    _AgeStep(
                      value: profile.ageBand,
                      onChanged: (value) =>
                          setState(() => profile = profile.copyWith(ageBand: value)),
                    ),
                    _LevelStep(
                      value: profile.proficiency,
                      onChanged: (value) => setState(
                        () => profile = profile.copyWith(proficiency: value),
                      ),
                    ),
                    _GoalStep(
                      selected: profile.goals.toSet(),
                      onToggle: (goal) {
                        final goals = profile.goals.toSet();
                        if (goals.contains(goal)) {
                          if (goals.length > 1) goals.remove(goal);
                        } else if (goals.length < 2) {
                          goals.add(goal);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppText.of('onboarding.goalLimit')),
                            ),
                          );
                        }
                        setState(
                          () => profile = profile.copyWith(goals: goals.toList()),
                        );
                      },
                    ),
                    _PreferencesStep(
                      profile: profile,
                      onChanged: (value) => setState(() => profile = value),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: ScreenFrame(
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: saving ? null : _next,
                      icon: saving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              step == stepCount - 1
                                  ? Icons.explore_rounded
                                  : Icons.arrow_forward_rounded,
                            ),
                      label: Text(
                        step == 0
                            ? AppText.of('onboarding.start')
                            : step == stepCount - 1
                                ? AppText.of('onboarding.finish')
                                : AppText.of('common.continue'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepFrame extends StatelessWidget {
  const _StepFrame({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
      child: ScreenFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              eyebrow.toUpperCase(),
              style: const TextStyle(
                color: QuestColors.tealDark,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 9),
            Text(title, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 9),
            Text(
              subtitle,
              style: const TextStyle(color: QuestColors.slate, fontSize: 15),
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.profile});
  final LearnerProfile profile;

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      eyebrow: AppText.of('welcome.eyebrow'),
      title: AppText.of('welcome.title'),
      subtitle: AppText.of('welcome.subtitle'),
      child: PremiumCard(
        padding: const EdgeInsets.all(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[QuestColors.midnight, QuestColors.indigo],
        ),
        child: Column(
          children: <Widget>[
            _BenefitRow(
              icon: Icons.route_rounded,
              title: AppText.of('welcome.path'),
              detail: AppText.of('welcome.pathNote'),
            ),
            const SizedBox(height: 18),
            _BenefitRow(
              icon: Icons.offline_bolt_rounded,
              title: AppText.of('welcome.offline'),
              detail: AppText.of('welcome.offlineNote'),
            ),
            const SizedBox(height: 18),
            _BenefitRow(
              icon: Icons.family_restroom_rounded,
              title: AppText.of('welcome.safe'),
              detail: AppText.of('welcome.safeNote'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFDDF3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: QuestColors.tealDark),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(detail, style: const TextStyle(color: Color(0xFFDDF3FF))),
              ],
            ),
          ),
        ],
      );
}

class _AgeStep extends StatelessWidget {
  const _AgeStep({required this.value, required this.onChanged});
  final LearnerAgeBand value;
  final ValueChanged<LearnerAgeBand> onChanged;

  @override
  Widget build(BuildContext context) => _StepFrame(
        eyebrow: AppText.of('age.eyebrow'),
        title: AppText.of('age.title'),
        subtitle: AppText.of('age.subtitle'),
        child: Column(
          children: LearnerAgeBand.values
              .map(
                (item) => _SelectionCard(
                  title: item.label,
                  subtitle: item.description,
                  icon: switch (item) {
                    LearnerAgeBand.early => Icons.child_care_rounded,
                    LearnerAgeBand.young => Icons.rocket_launch_rounded,
                    LearnerAgeBand.teen => Icons.school_rounded,
                    LearnerAgeBand.adult => Icons.person_rounded,
                  },
                  selected: value == item,
                  onTap: () => onChanged(item),
                ),
              )
              .toList(),
        ),
      );
}

class _LevelStep extends StatelessWidget {
  const _LevelStep({required this.value, required this.onChanged});
  final MizoProficiency value;
  final ValueChanged<MizoProficiency> onChanged;

  @override
  Widget build(BuildContext context) => _StepFrame(
        eyebrow: AppText.of('proficiency.eyebrow'),
        title: AppText.of('proficiency.title'),
        subtitle: AppText.of('proficiency.subtitle'),
        child: Column(
          children: MizoProficiency.values
              .map(
                (item) => _SelectionCard(
                  title: item.label,
                  subtitle: item.description,
                  icon: Icons.signal_cellular_alt_rounded,
                  selected: value == item,
                  onTap: () => onChanged(item),
                ),
              )
              .toList(),
        ),
      );
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.selected, required this.onToggle});
  final Set<LearningGoal> selected;
  final ValueChanged<LearningGoal> onToggle;

  @override
  Widget build(BuildContext context) => _StepFrame(
        eyebrow: AppText.of('goal.eyebrow'),
        title: AppText.of('goal.title'),
        subtitle: AppText.of('goal.subtitle'),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: LearningGoal.values
              .map(
                (goal) => FilterChip(
                  selected: selected.contains(goal),
                  showCheckmark: true,
                  avatar: Icon(
                    switch (goal) {
                      LearningGoal.conversation => Icons.forum_rounded,
                      LearningGoal.vocabulary => Icons.spellcheck_rounded,
                      LearningGoal.reading => Icons.menu_book_rounded,
                      LearningGoal.culture => Icons.auto_awesome_rounded,
                      LearningGoal.refresh => Icons.refresh_rounded,
                    },
                    size: 18,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(goal.label),
                  ),
                  onSelected: (_) => onToggle(goal),
                ),
              )
              .toList(),
        ),
      );
}

class _PreferencesStep extends StatelessWidget {
  const _PreferencesStep({required this.profile, required this.onChanged});
  final LearnerProfile profile;
  final ValueChanged<LearnerProfile> onChanged;

  @override
  Widget build(BuildContext context) => _StepFrame(
        eyebrow: AppText.of('rhythm.eyebrow'),
        title: AppText.of('rhythm.title'),
        subtitle: AppText.of('rhythm.subtitle'),
        child: Column(
          children: <Widget>[
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(AppText.of('rhythm.goal'), style: const TextStyle(color: QuestColors.slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  SegmentedButton<int>(
                    segments: <ButtonSegment<int>>[
                      ButtonSegment<int>(value: 5, label: Text(AppText.of('rhythm.minutes', {'n': 5}))),
                      ButtonSegment<int>(value: 10, label: Text(AppText.of('rhythm.minutes', {'n': 10}))),
                      ButtonSegment<int>(value: 15, label: Text(AppText.of('rhythm.minutes', {'n': 15}))),
                    ],
                    selected: <int>{profile.dailyGoalMinutes},
                    onSelectionChanged: (value) => onChanged(
                      profile.copyWith(dailyGoalMinutes: value.first),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PremiumCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: Text(AppText.of('profile.reduceMotion'), style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(AppText.of('profile.reduceMotionNote')),
                    secondary: const Icon(Icons.motion_photos_off_rounded, color: QuestColors.indigo),
                    value: profile.reducedMotion,
                    onChanged: (value) => onChanged(profile.copyWith(reducedMotion: value)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Icon(Icons.lock_rounded, color: QuestColors.tealDark, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppText.of('rhythm.privacy'),
                    style: const TextStyle(color: QuestColors.slate, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFDDF3FF) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? QuestColors.tealDark : QuestColors.line,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : QuestColors.mist,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: QuestColors.indigo),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: const TextStyle(color: QuestColors.slate, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? QuestColors.tealDark : QuestColors.line,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
