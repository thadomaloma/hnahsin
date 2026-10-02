import 'package:flutter/material.dart';

/// The Hnahsin palette, taken from the logo: sky blues, flower pink and
/// gold, leaf green, cream. Names are the old roles so every widget keeps
/// working; white text only ever sits on [indigo] or darker.
abstract final class QuestColors {
  static const midnight = Color(0xFF0D47A1);
  static const navy = Color(0xFF0D47A1);
  static const indigo = Color(0xFF1565C0);
  static const indigoBright = Color(0xFF3C9FEA);
  static const teal = Color(0xFF8FD0FA);
  static const tealDark = Color(0xFF1565C0);
  static const gold = Color(0xFFFFC94A);
  static const goldDeep = Color(0xFFF2A516);
  static const coral = Color(0xFFC2185B);
  static const cream = Color(0xFFFFFDF7);
  static const canvas = Color(0xFFDDF3FF);
  static const mist = Color(0xFFEAF6FF);
  static const ink = Color(0xFF15213A);
  static const slate = Color(0xFF5B6B80);
  static const line = Color(0xFFD6E6F2);
  static const success = Color(0xFF6DBE5E);

  /// Leaf green is too light for text on white; this is its readable shade.
  static const successInk = Color(0xFF2E7D32);
  static const violet = Color(0xFF7569E8);
}

abstract final class QuestSpace {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class QuestRadius {
  static const small = 12.0;
  static const medium = 18.0;
  static const large = 24.0;
  static const hero = 30.0;
}

abstract final class QuestGradients {
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [QuestColors.midnight, QuestColors.indigo],
  );
  static const gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD66B), QuestColors.goldDeep],
  );
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [QuestColors.indigoBright, QuestColors.indigo],
  );
}

abstract final class QuestShadows {
  static const card = [
    BoxShadow(color: Color(0x0A0D47A1), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F0D47A1), blurRadius: 24, offset: Offset(0, 10)),
  ];
  static const raised = [
    BoxShadow(color: Color(0x140D47A1), blurRadius: 6, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x240D47A1), blurRadius: 32, offset: Offset(0, 16)),
  ];
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(color: color.withValues(alpha: .35), blurRadius: 22, offset: const Offset(0, 10)),
      ];
}

/// Width classes shared by every screen so phones, foldables, tablets and
/// desktop browsers all get a layout made for them.
enum QuestWidth { compact, medium, expanded }

abstract final class QuestLayout {
  static const railBreakpoint = 840.0;
  static const contentMaxWidth = 960.0;

  static QuestWidth of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) return QuestWidth.expanded;
    if (width >= 600) return QuestWidth.medium;
    return QuestWidth.compact;
  }

  static bool useRail(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= railBreakpoint;

  /// Side gutter: tighter on small phones, roomier on tablets.
  static double gutter(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 14;
    if (width < 600) return 18;
    if (width < 1024) return 28;
    return 36;
  }

  /// Space the floating bottom navigation occupies on phones.
  static double bottomInset(BuildContext context) =>
      useRail(context) ? 32 : 112 + MediaQuery.paddingOf(context).bottom;
}

const questFontFamily = 'PlusJakartaSans';

/// [duration], or none when the learner asked for less motion (Profile's
/// Reduce motion, or the device's own setting).
Duration motionFor(BuildContext context, Duration duration) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

/// The platform's page transition, or none with reduced motion.
class _MotionAwareTransitions extends PageTransitionsBuilder {
  const _MotionAwareTransitions(this.standard);

  final PageTransitionsBuilder standard;

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      MediaQuery.disableAnimationsOf(context)
          ? child
          : standard.buildTransitions(route, context, animation, secondaryAnimation, child);
}

ThemeData buildQuestTheme() {
  const scheme = ColorScheme.light(
    primary: QuestColors.indigo,
    onPrimary: Colors.white,
    secondary: QuestColors.tealDark,
    onSecondary: Colors.white,
    tertiary: QuestColors.gold,
    error: QuestColors.coral,
    surface: Colors.white,
    onSurface: QuestColors.ink,
    outline: QuestColors.line,
  );
  const textTheme = TextTheme(
    displayMedium: TextStyle(fontSize: 38, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -1.4, color: QuestColors.ink),
    displaySmall: TextStyle(fontSize: 30, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -1, color: QuestColors.ink),
    headlineSmall: TextStyle(fontSize: 23, height: 1.18, fontWeight: FontWeight.w800, letterSpacing: -.5, color: QuestColors.ink),
    titleLarge: TextStyle(fontSize: 19, height: 1.25, fontWeight: FontWeight.w800, letterSpacing: -.3, color: QuestColors.ink),
    titleMedium: TextStyle(fontSize: 16, height: 1.3, fontWeight: FontWeight.w700, color: QuestColors.ink),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500, color: QuestColors.ink),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500, color: QuestColors.ink),
    bodySmall: TextStyle(fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w500, color: QuestColors.slate),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: .1),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .2),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
  );
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
  return ThemeData(
    useMaterial3: true,
    fontFamily: questFontFamily,
    colorScheme: scheme,
    scaffoldBackgroundColor: QuestColors.canvas,
    visualDensity: VisualDensity.standard,
    splashFactory: InkSparkle.splashFactory,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: QuestColors.canvas,
      surfaceTintColor: Colors.transparent,
      foregroundColor: QuestColors.ink,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        backgroundColor: QuestColors.indigo,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFDDE3EC),
        disabledForegroundColor: QuestColors.slate,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontFamily: questFontFamily, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: .1),
        shape: buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 56),
        foregroundColor: QuestColors.indigo,
        side: const BorderSide(color: QuestColors.line, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: const TextStyle(fontFamily: questFontFamily, fontWeight: FontWeight.w800, fontSize: 16),
        shape: buttonShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: QuestColors.indigo,
        minimumSize: const Size(48, 44),
        textStyle: const TextStyle(fontFamily: questFontFamily, fontWeight: FontWeight.w800, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: QuestColors.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: QuestColors.line, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: QuestColors.indigo, width: 2)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: QuestColors.tealDark, linearTrackColor: Color(0xFFE2E8F0)),
    chipTheme: ChipThemeData(
      side: const BorderSide(color: QuestColors.line),
      backgroundColor: Colors.white,
      selectedColor: QuestColors.canvas,
      checkmarkColor: QuestColors.tealDark,
      labelStyle: const TextStyle(fontFamily: questFontFamily, fontWeight: FontWeight.w700, color: QuestColors.ink),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) => Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? QuestColors.tealDark : const Color(0xFFD5DCE6),
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent, elevation: 0),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: QuestColors.navy,
      contentTextStyle: const TextStyle(fontFamily: questFontFamily, color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(color: QuestColors.line, space: 1),
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      for (final MapEntry(:key, :value) in const PageTransitionsTheme().builders.entries)
        key: _MotionAwareTransitions(value),
    }),
  );
}
