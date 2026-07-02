import 'package:flutter/material.dart';

/// Minimalist cotton palette — white/black with a single violet accent (matches the SSO).
///
/// Colours are exposed as brightness-aware getters driven by [Palette.dark], which the
/// app sets from the active theme brightness. This lets the whole UI switch between the
/// light and dark themes without threading a BuildContext through every widget.
class Palette {
  /// Set by the app from the current theme brightness before building the tree.
  static bool dark = false;

  static Color get accent => dark ? const Color(0xFF9272F0) : const Color(0xFF7C3AED);
  static Color get accent2 => dark ? const Color(0xFF7C5BE0) : const Color(0xFF6D28D9);

  static Color get bg => dark ? const Color(0xFF0D0D0F) : const Color(0xFFFFFFFF);
  static Color get surface => dark ? const Color(0xFF1B1B20) : const Color(0xFFFAFAFA);
  static Color get surfaceHover => dark ? const Color(0xFF25252C) : const Color(0xFFF4F4F5);

  static Color get textPrimary => dark ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
  static Color get textSecondary => dark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B);
  static Color get textTertiary => dark ? const Color(0xFF71717A) : const Color(0xFF8E8E96);

  static Color get border => dark ? const Color(0x1FFFFFFF) : const Color(0x1A09090B);
  static Color get borderStrong => dark ? const Color(0x33FFFFFF) : const Color(0x2E09090B);
  static Color get danger => dark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
  static Color get success => dark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);

  // Radii (cotton).
  static const rSm = 10.0;
  static const rMd = 13.0;
  static const rLg = 18.0;

  // Immersive dark surface for the call / recorder screens (always dark).
  static const callBg = Color(0xFF09090B);

  // Backwards-compatible aliases used across widgets.
  static Color get glassFill => surface;
  static Color get glassFillStrong => surfaceHover;
  static Color get glassBorder => border;
  static Color get bg0 => bg;
  static Color get bg1 => surface;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
            color: dark ? const Color(0x40000000) : const Color(0x0D09090B),
            blurRadius: 16,
            offset: const Offset(0, 4)),
      ];

  /// Plain background (strict minimalism — no decorative gradient).
  static LinearGradient get backdrop => LinearGradient(colors: [bg, bg]);
}

ThemeData buildGlassTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
  final accent = isDark ? const Color(0xFF9272F0) : const Color(0xFF7C3AED);
  final bg = isDark ? const Color(0xFF0D0D0F) : Colors.white;
  final textPrimary = isDark ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
  return base.copyWith(
    scaffoldBackgroundColor: bg,
    colorScheme: base.colorScheme.copyWith(
      primary: accent,
      secondary: accent,
      surface: bg,
      error: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
      brightness: brightness,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    splashFactory: InkRipple.splashFactory,
    dividerColor: isDark ? const Color(0x1FFFFFFF) : const Color(0x1A09090B),
  );
}
