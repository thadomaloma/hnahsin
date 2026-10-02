import 'dart:ui';

import 'package:flutter/material.dart';

import '../features/onboarding/presentation/onboarding_screen.dart';
import 'controller.dart';
import 'data.dart';
import 'screens.dart';
import 'theme.dart';
import 'app_text.dart';

class HnahsinApp extends StatelessWidget {
  const HnahsinApp({super.key, required this.controller});
  final QuestController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hnahsin',
      theme: buildQuestTheme(),
      // Honour larger system text, but cap it where game layouts would break.
      // Profile's Reduce motion turns animations off like the device's
      // setting does (see motionFor).
      builder: (context, child) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              disableAnimations:
                  media.disableAnimations || controller.profile.reducedMotion,
            ),
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.35,
              child: child!,
            ),
          );
        },
      ),
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (ContentPolicy.isProduction && !controller.releaseContentReady) {
            return const _ReleaseContentGate();
          }
          return controller.profile.onboardingCompleted
              ? QuestShell(controller: controller)
              : OnboardingScreen(controller: controller);
        },
      ),
    );
  }
}

class _ReleaseContentGate extends StatelessWidget {
  const _ReleaseContentGate();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.fact_check_rounded,
                      size: 58,
                      color: QuestColors.indigo,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppText.of('review.title'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppText.of('review.body'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: QuestColors.slate),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class QuestShell extends StatefulWidget {
  const QuestShell({super.key, required this.controller});
  final QuestController controller;

  @override
  State<QuestShell> createState() => _QuestShellState();
}

class _Destination {
  const _Destination(this.textId, this.icon, this.selectedIcon);
  final String textId;
  String get label => AppText.of(textId);
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = <_Destination>[
  _Destination('nav.home', Icons.home_outlined, Icons.home_rounded),
  _Destination('nav.learn', Icons.auto_stories_outlined, Icons.auto_stories_rounded),
  _Destination('nav.games', Icons.sports_esports_outlined, Icons.sports_esports_rounded),
  _Destination('nav.profile', Icons.person_outline_rounded, Icons.person_rounded),
];

class _QuestShellState extends State<QuestShell> {
  int index = 0;

  void _select(int value) => setState(() => index = value);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(controller: widget.controller, openGames: () => _select(2)),
      LearnScreen(controller: widget.controller),
      GamesScreen(controller: widget.controller),
      ProfileScreen(controller: widget.controller),
    ];
    final body = IndexedStack(index: index, children: pages);
    if (QuestLayout.useRail(context)) {
      return Scaffold(
        body: Row(children: [
          _SideRail(index: index, onSelect: _select),
          Expanded(child: body),
        ]),
      );
    }
    return Scaffold(
      extendBody: true,
      body: body,
      bottomNavigationBar: _BottomBar(index: index, onSelect: _select),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onSelect});
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final gutter = QuestLayout.gutter(context);
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(gutter, 0, gutter, 12),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 70,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .86),
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: QuestShadows.raised,
                ),
                child: Row(children: [
                  for (var i = 0; i < _destinations.length; i++)
                    _NavItem(
                      destination: _destinations[i],
                      selected: index == i,
                      onTap: () => onSelect(i),
                    ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.destination, required this.selected, required this.onTap});

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: destination.label,
        child: ExcludeSemantics(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: AnimatedContainer(
              duration: motionFor(context, const Duration(milliseconds: 260)),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                gradient: selected ? QuestGradients.hero : null,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    size: 23,
                    color: selected ? QuestColors.gold : QuestColors.slate,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    destination.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: selected ? Colors.white : QuestColors.slate,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.index, required this.onSelect});
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      decoration: const BoxDecoration(gradient: QuestGradients.hero),
      child: SafeArea(
        right: false,
        child: Column(children: [
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset('assets/branding/hnahsin_icon.png', width: 52, height: 52, fit: BoxFit.cover),
          ),
          const SizedBox(height: 30),
          for (var i = 0; i < _destinations.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Semantics(
                button: true,
                selected: index == i,
                label: _destinations[i].label,
                child: ExcludeSemantics(
                  child: InkWell(
                    onTap: () => onSelect(i),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: motionFor(context, const Duration(milliseconds: 240)),
                      height: 68,
                      decoration: BoxDecoration(
                        color: index == i ? Colors.white.withValues(alpha: .14) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(
                          index == i ? _destinations[i].selectedIcon : _destinations[i].icon,
                          color: index == i ? QuestColors.gold : const Color(0xFF8FD0FA),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _destinations[i].label,
                          style: TextStyle(
                            color: index == i ? Colors.white : const Color(0xFF8FD0FA),
                            fontSize: 12,
                            fontWeight: index == i ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
