// ============================================================================
// MOMENTUM DESIGN SYSTEM — TOKENS
// Source of truth: Master Design System Specification v2.1 (authoritative)
// + Stitch HTML reference structure (Luminous Serenity / Nocturne exports).
// Dark mode follows the v2.1 palette (#0E131F canvas, #6366F1/#818CF8 family).
// ============================================================================

import 'package:flutter/material.dart';

/// Raw token constants (spacing, radii, blur, sizes).
class MomentumTokens {
  MomentumTokens._();

  // --- Brand -----------------------------------------------------------
  static const primaryLight = Color(0xFF4F6BFF);
  static const primaryPressedLight = Color(0xFF3B55E6);
  static const primaryDark = Color(0xFF6366F1);
  static const primaryPressedDark = Color(0xFF4F51E0);
  static const accentTextLight = Color(0xFF4F6BFF);
  static const accentTextDark = Color(0xFF818CF8);
  static const secondaryLight = Color(0xFF7059FF);
  static const secondaryDark = Color(0xFF38BDF8);
  static const tertiaryLight = Color(0xFF0D9488); // Oasis teal
  static const tertiaryDark = Color(0xFF2DD4BF);

  // --- Text ------------------------------------------------------------
  static const textPrimaryLight = Color(0xFF0F172A);
  static const textSecondaryLight = Color(0xFF475569);
  static const textTertiaryLight = Color(0xFF64748B);
  static const textDisabledLight = Color(0xFF94A3B8);
  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const textTertiaryDark = Color(0xFF64748B);
  static const textDisabledDark = Color(0xFF475569);

  // --- Canvas ----------------------------------------------------------
  static const bgLight = Color(0xFFFAF8FF);
  static const bgDark = Color(0xFF0E131F);

  // --- Semantic --------------------------------------------------------
  static const successLight = Color(0xFF059669);
  static const successDark = Color(0xFF34D399);
  static const warningLight = Color(0xFFD97706);
  static const warningDark = Color(0xFFFBBF24);
  static const dangerLight = Color(0xFFDC2626);
  static const dangerDark = Color(0xFFF87171);
  static const infoLight = Color(0xFF2563EB);
  static const infoDark = Color(0xFF60A5FA);

  // --- Radii (Stitch: DEFAULT 16 / lg 32 / full) -------------------------
  static const radiusXs = 8.0;
  static const radiusSm = 10.0;
  static const radiusMd = 16.0;
  static const radiusLg = 24.0;
  static const radiusHero = 32.0;
  static const radiusDock = 999.0;

  // --- Blur hierarchy ----------------------------------------------------
  static const blurSm = 8.0;
  static const blurMd = 16.0;
  static const blurXl = 24.0;
  static const blur2xl = 40.0;

  // --- Chrome geometry ---------------------------------------------------
  static const dockHeight = 68.0;
  static const centerButton = 56.0;
  static const centerButtonLift = 20.0;
  static const topBarHeight = 56.0;
  static const backButton = 40.0;
  static const dockClearance = 118.0; // content bottom clearance above dock

  /// Default wallpaper blur (Store default — do not change, persisted).
  static const defaultBlur = 18.0;
  static const gutter = 16.0;
}

/// Resolved per-brightness palette. `Pal.of(context)` everywhere.
class Pal {
  final bool dark;
  final Color canvas, scrim;
  final Color primary, primaryPressed, secondary, tertiary, accentText;
  final Color textPrimary, textSecondary, textTertiary, textDisabled;
  final Color cardBase, cardElevated, cardSubtle;
  final Color hairline, borderActive, dock, inputFill, divider;
  final Color success, successSurface, successBorder;
  final Color warning, warningSurface, warningBorder;
  final Color danger, dangerSurface, dangerBorder;
  final Color info, infoSurface, infoBorder;
  final Color orb1, orb2, orb3;
  final Color headerSurface;

  const Pal._({
    required this.dark,
    required this.canvas,
    required this.scrim,
    required this.primary,
    required this.primaryPressed,
    required this.secondary,
    required this.tertiary,
    required this.accentText,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.cardBase,
    required this.cardElevated,
    required this.cardSubtle,
    required this.hairline,
    required this.borderActive,
    required this.dock,
    required this.inputFill,
    required this.divider,
    required this.success,
    required this.successSurface,
    required this.successBorder,
    required this.warning,
    required this.warningSurface,
    required this.warningBorder,
    required this.danger,
    required this.dangerSurface,
    required this.dangerBorder,
    required this.info,
    required this.infoSurface,
    required this.infoBorder,
    required this.orb1,
    required this.orb2,
    required this.orb3,
    required this.headerSurface,
  });

  static const light = Pal._(
    dark: false,
    canvas: MomentumTokens.bgLight,
    scrim: Color.fromRGBO(255, 255, 255, .35),
    primary: MomentumTokens.primaryLight,
    primaryPressed: MomentumTokens.primaryPressedLight,
    secondary: MomentumTokens.secondaryLight,
    tertiary: MomentumTokens.tertiaryLight,
    accentText: MomentumTokens.accentTextLight,
    textPrimary: MomentumTokens.textPrimaryLight,
    textSecondary: MomentumTokens.textSecondaryLight,
    textTertiary: MomentumTokens.textTertiaryLight,
    textDisabled: MomentumTokens.textDisabledLight,
    cardBase: Color.fromRGBO(255, 255, 255, .78),
    cardElevated: Color.fromRGBO(255, 255, 255, .90),
    cardSubtle: Color.fromRGBO(242, 243, 255, .60),
    hairline: Color.fromRGBO(255, 255, 255, .80),
    borderActive: Color.fromRGBO(79, 107, 255, .35),
    dock: Color.fromRGBO(255, 255, 255, .82),
    inputFill: Color.fromRGBO(255, 255, 255, .70),
    divider: Color.fromRGBO(0, 0, 0, .04),
    success: MomentumTokens.successLight,
    successSurface: Color.fromRGBO(16, 185, 129, .12),
    successBorder: Color(0xFF10B981),
    warning: MomentumTokens.warningLight,
    warningSurface: Color.fromRGBO(245, 158, 11, .12),
    warningBorder: Color(0xFFF59E0B),
    danger: MomentumTokens.dangerLight,
    dangerSurface: Color.fromRGBO(239, 68, 68, .10),
    dangerBorder: Color(0xFFEF4444),
    info: MomentumTokens.infoLight,
    infoSurface: Color.fromRGBO(37, 99, 235, .08),
    infoBorder: Color.fromRGBO(37, 99, 235, .20),
    orb1: Color.fromRGBO(79, 107, 255, .16),
    orb2: Color.fromRGBO(112, 89, 255, .13),
    orb3: Color.fromRGBO(13, 148, 136, .11),
    headerSurface: Color.fromRGBO(250, 248, 255, .70),
  );

  static const darkPal = Pal._(
    dark: true,
    canvas: MomentumTokens.bgDark,
    scrim: Color.fromRGBO(14, 19, 31, .70),
    primary: MomentumTokens.primaryDark,
    primaryPressed: MomentumTokens.primaryPressedDark,
    secondary: MomentumTokens.secondaryDark,
    tertiary: MomentumTokens.tertiaryDark,
    accentText: MomentumTokens.accentTextDark,
    textPrimary: MomentumTokens.textPrimaryDark,
    textSecondary: MomentumTokens.textSecondaryDark,
    textTertiary: MomentumTokens.textTertiaryDark,
    textDisabled: MomentumTokens.textDisabledDark,
    cardBase: Color.fromRGBO(22, 28, 40, .75),
    cardElevated: Color.fromRGBO(30, 38, 54, .85),
    cardSubtle: Color.fromRGBO(16, 23, 35, .60),
    hairline: Color.fromRGBO(255, 255, 255, .08),
    borderActive: Color.fromRGBO(99, 102, 241, .45),
    dock: Color.fromRGBO(14, 19, 31, .88),
    inputFill: Color.fromRGBO(16, 23, 35, .70),
    divider: Color.fromRGBO(255, 255, 255, .05),
    success: MomentumTokens.successDark,
    successSurface: Color.fromRGBO(16, 185, 129, .20),
    successBorder: Color(0xFF059669),
    warning: MomentumTokens.warningDark,
    warningSurface: Color.fromRGBO(245, 158, 11, .20),
    warningBorder: Color(0xFFB45309),
    danger: MomentumTokens.dangerDark,
    dangerSurface: Color.fromRGBO(239, 68, 68, .22),
    dangerBorder: Color(0xFF991B1B),
    info: MomentumTokens.infoDark,
    infoSurface: Color.fromRGBO(96, 165, 250, .16),
    infoBorder: Color.fromRGBO(96, 165, 250, .30),
    orb1: Color.fromRGBO(99, 102, 241, .22),
    orb2: Color.fromRGBO(56, 189, 248, .13),
    orb3: Color.fromRGBO(45, 212, 191, .10),
    headerSurface: Color.fromRGBO(14, 19, 31, .70),
  );

  static Pal of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPal : light;

  static Pal fromBrightness(Brightness b) =>
      b == Brightness.dark ? darkPal : light;

  // --- Gradients ---------------------------------------------------------
  /// Primary brand gradient (135deg).
  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const [Color(0xFF6366F1), Color(0xFF38BDF8)]
            : const [Color(0xFF4F6BFF), Color(0xFF7059FF)],
      );

  /// Tri-color wash: primary → secondary → tertiary (progress fills, `+`).
  LinearGradient get triGradient => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [primary, secondary, tertiary],
      );

  LinearGradient get triGradientDiagonal => LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [primary, secondary, tertiary],
      );

  // --- Shadows -----------------------------------------------------------
  List<BoxShadow> get cardShadow => dark
      ? const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, .50), blurRadius: 30, spreadRadius: -5, offset: Offset(0, 10)),
          BoxShadow(color: Color.fromRGBO(255, 255, 255, .06), blurRadius: 1, spreadRadius: 1),
        ]
      : const [
          BoxShadow(color: Color.fromRGBO(79, 107, 255, .08), blurRadius: 25, spreadRadius: -5, offset: Offset(0, 10)),
          BoxShadow(color: Color.fromRGBO(0, 0, 0, .03), blurRadius: 10, spreadRadius: -6, offset: Offset(0, 8)),
        ];

  List<BoxShadow> get heroShadow => dark
      ? const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, .55), blurRadius: 32, spreadRadius: -4, offset: Offset(0, 12)),
          BoxShadow(color: Color.fromRGBO(255, 255, 255, .06), blurRadius: 1, spreadRadius: 1),
        ]
      : const [
          BoxShadow(color: Color.fromRGBO(73, 101, 249, .12), blurRadius: 32, spreadRadius: -4, offset: Offset(0, 12)),
        ];

  List<BoxShadow> get dockShadow => dark
      ? const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, .55), blurRadius: 36, spreadRadius: -4, offset: Offset(0, 16)),
        ]
      : const [
          BoxShadow(color: Color.fromRGBO(33, 0, 94, .12), blurRadius: 36, offset: Offset(0, 16)),
        ];

  List<BoxShadow> get fabGlow => dark
      ? const [
          BoxShadow(color: Color.fromRGBO(99, 102, 241, .55), blurRadius: 28, spreadRadius: -4, offset: Offset(0, 12)),
          BoxShadow(color: Color.fromRGBO(56, 189, 248, .35), blurRadius: 15),
        ]
      : const [
          BoxShadow(color: Color.fromRGBO(79, 107, 255, .45), blurRadius: 24, spreadRadius: -4, offset: Offset(0, 12)),
        ];
}

/// One of the 30 coordinated atmospheric scenes (light + dark gradient pair).
class WallpaperSpec {
  final String name;
  final List<Color> light;
  final List<Color> dark;
  const WallpaperSpec(this.name, this.light, this.dark);
}

const wallpapers = <WallpaperSpec>[
  WallpaperSpec('Dawn Tranquility', [Color(0xFFFFD6C4), Color(0xFFE3E8FF)], [Color(0xFF1D233A), Color(0xFF56384E)]),
  WallpaperSpec('Serene Horizon', [Color(0xFFDDF7FF), Color(0xFFB8D5FF)], [Color(0xFF10253C), Color(0xFF1B4B62)]),
  WallpaperSpec('Twilight Cloudscape', [Color(0xFFE9D7FF), Color(0xFFD3E8FF)], [Color(0xFF20163D), Color(0xFF2B4066)]),
  WallpaperSpec('Aurora Solitude', [Color(0xFFDFFFEA), Color(0xFFE2E4FF)], [Color(0xFF0A2C31), Color(0xFF253266)]),
  WallpaperSpec('Dusk Radiance', [Color(0xFFFFD8C9), Color(0xFFE9D7FF)], [Color(0xFF2A1726), Color(0xFF4E2C45)]),
  WallpaperSpec('High Noon Mist', [Color(0xFFF2FAFF), Color(0xFFD9E6F7)], [Color(0xFF162331), Color(0xFF30465B)]),
  WallpaperSpec('Minaret Sunrise', [Color(0xFFFFE3C2), Color(0xFFD7E4FF)], [Color(0xFF281A23), Color(0xFF334874)]),
  WallpaperSpec('Sacred Geometry', [Color(0xFFE8E7FF), Color(0xFFD7FCF6)], [Color(0xFF17172F), Color(0xFF183F46)]),
  WallpaperSpec('Blue Mosque Dusk', [Color(0xFFDFF0FF), Color(0xFFC8D3FF)], [Color(0xFF0B2340), Color(0xFF243B70)]),
  WallpaperSpec('Archway Reflections', [Color(0xFFFFEBD9), Color(0xFFE2E8FF)], [Color(0xFF261A25), Color(0xFF35416A)]),
  WallpaperSpec('Andalusian Courtyard', [Color(0xFFEFFFE7), Color(0xFFFFE9D6)], [Color(0xFF10241F), Color(0xFF3F2B24)]),
  WallpaperSpec('Samarkand Azure', [Color(0xFFDFF8FF), Color(0xFFDCF0FF)], [Color(0xFF08293B), Color(0xFF18496D)]),
  WallpaperSpec('Palm Oasis Silhouette', [Color(0xFFFFF0C8), Color(0xFFDDF6E8)], [Color(0xFF1E1B22), Color(0xFF164435)]),
  WallpaperSpec('Desert Minaret', [Color(0xFFFFE3BC), Color(0xFFFFD8D2)], [Color(0xFF251A1B), Color(0xFF4F2D2A)]),
  WallpaperSpec('Kabul Solitude', [Color(0xFFDCEBFF), Color(0xFFD5F0F0)], [Color(0xFF0C2530), Color(0xFF213B5A)]),
  WallpaperSpec('Emerald Oasis', [Color(0xFFDFFFEA), Color(0xFFCFF3D6)], [Color(0xFF0D2B21), Color(0xFF15483C)]),
  WallpaperSpec('Mountain Zenith', [Color(0xFFE7F4FF), Color(0xFFD6E5FF)], [Color(0xFF102338), Color(0xFF263E63)]),
  WallpaperSpec('Quiet Pine Mist', [Color(0xFFE4F2E7), Color(0xFFD7E6F8)], [Color(0xFF12211C), Color(0xFF243D3A)]),
  WallpaperSpec('Alpine Reflection', [Color(0xFFE5F6FF), Color(0xFFD8E6FF)], [Color(0xFF12273C), Color(0xFF274C61)]),
  WallpaperSpec('Dune Silence', [Color(0xFFFFE8C7), Color(0xFFF2E1C9)], [Color(0xFF281E1A), Color(0xFF463328)]),
  WallpaperSpec('Cascading Spring', [Color(0xFFDFFFEF), Color(0xFFD8EEFF)], [Color(0xFF0B2830), Color(0xFF1F4C56)]),
  WallpaperSpec('Cedar Grove', [Color(0xFFE8F3E7), Color(0xFFD7E8FF)], [Color(0xFF0D211B), Color(0xFF22372B)]),
  WallpaperSpec('Lavender Haze', [Color(0xFFF2E6FF), Color(0xFFDDE2FF)], [Color(0xFF221A38), Color(0xFF342A59)]),
  WallpaperSpec('Prismatic Fluid', [Color(0xFFDFF7FF), Color(0xFFF6DFFF)], [Color(0xFF12223C), Color(0xFF3C2551)]),
  WallpaperSpec('Indigo Silk', [Color(0xFFE3E9FF), Color(0xFFD4DDFF)], [Color(0xFF101B3D), Color(0xFF232D62)]),
  WallpaperSpec('Radiant Sphere', [Color(0xFFFFE7D0), Color(0xFFE5E0FF)], [Color(0xFF2C1E2A), Color(0xFF3A315E)]),
  WallpaperSpec('Amber Quartz', [Color(0xFFFFEDCA), Color(0xFFFFD9B0)], [Color(0xFF241B1A), Color(0xFF49321F)]),
  WallpaperSpec('Obsidian Refraction', [Color(0xFFE0E4EA), Color(0xFFC9D7F0)], [Color(0xFF0C111B), Color(0xFF1A2740)]),
  WallpaperSpec('Luminous Void', [Color(0xFFEAEAFF), Color(0xFFDDFBFF)], [Color(0xFF101522), Color(0xFF243451)]),
  WallpaperSpec('Opal Ribbon', [Color(0xFFE6F7FF), Color(0xFFF9E5FF)], [Color(0xFF102330), Color(0xFF302043)]),
];

// ============================================================================
// THEME BUILDER
// ============================================================================

/// Stitch type scale, mapped to Flutter's TextTheme.
TextTheme momentumTextTheme(Pal p) {
  const display = 'SpaceGrotesk';
  const body = 'Inter';
  return TextTheme(
    // display-lg 32/40 700 (hero counters, splash brand)
    displayLarge: TextStyle(fontFamily: display, fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w700, letterSpacing: -.64, color: p.textPrimary),
    // metric-lg 28/34 700
    displayMedium: TextStyle(fontFamily: display, fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w700, letterSpacing: -.56, color: p.textPrimary),
    displaySmall: TextStyle(fontFamily: display, fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700, letterSpacing: -.36, color: p.textPrimary),
    // headline-lg 24/32 700
    headlineLarge: TextStyle(fontFamily: display, fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700, letterSpacing: -.36, color: p.textPrimary),
    // H1 screen title 22/1.25 600
    headlineMedium: TextStyle(fontFamily: display, fontSize: 22, height: 1.25, fontWeight: FontWeight.w600, letterSpacing: -.33, color: p.textPrimary),
    // headline-md 18/24 600
    headlineSmall: TextStyle(fontFamily: display, fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600, letterSpacing: -.18, color: p.textPrimary),
    // top bar title 17-18 semibold
    titleLarge: TextStyle(fontFamily: body, fontSize: 17, height: 1.3, fontWeight: FontWeight.w600, letterSpacing: -.17, color: p.textPrimary),
    // headline-sm 16/22 600 (card titles)
    titleMedium: TextStyle(fontFamily: body, fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w600, letterSpacing: -.16, color: p.textPrimary),
    // H3 subsection 15/1.35 600 (list titles)
    titleSmall: TextStyle(fontFamily: body, fontSize: 15, height: 1.35, fontWeight: FontWeight.w600, color: p.textPrimary),
    // body-lg 15/22
    bodyLarge: TextStyle(fontFamily: body, fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400, color: p.textSecondary),
    // body-md 13/18 400
    bodyMedium: TextStyle(fontFamily: body, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w400, color: p.textSecondary),
    // body-sm 12/16 400
    bodySmall: TextStyle(fontFamily: body, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, letterSpacing: .12, color: p.textSecondary),
    // buttons 14 600
    labelLarge: TextStyle(fontFamily: body, fontSize: 14, height: 1.35, fontWeight: FontWeight.w600, color: p.textPrimary),
    // label-md 12/16 600
    labelMedium: TextStyle(fontFamily: body, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: p.textSecondary),
    // label-sm 11/14 500 +tracking (overlines, chips, dock labels)
    labelSmall: TextStyle(fontFamily: body, fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w600, letterSpacing: .55, color: p.textTertiary),
  );
}

ThemeData buildMomentumTheme(Brightness brightness) {
  final p = Pal.fromBrightness(brightness);
  final dark = p.dark;
  final text = momentumTextTheme(p);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Inter',
    textTheme: text,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: brightness,
      primary: p.primary,
      secondary: p.secondary,
      tertiary: p.tertiary,
      surface: p.cardBase,
      onSurface: p.textPrimary,
    ).copyWith(error: p.danger),
    scaffoldBackgroundColor: Colors.transparent,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.textPrimary,
      centerTitle: true,
      titleTextStyle: text.titleLarge,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(fontFamily: 'Inter', color: p.textSecondary, fontSize: 14),
      hintStyle: TextStyle(fontFamily: 'Inter', color: p.textTertiary, fontSize: 14),
      prefixIconColor: p.textSecondary,
      suffixIconColor: p.textSecondary,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(MomentumTokens.radiusMd), borderSide: BorderSide(color: p.hairline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MomentumTokens.radiusMd), borderSide: BorderSide(color: p.hairline)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(MomentumTokens.radiusMd), borderSide: BorderSide(color: p.primary, width: 2)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size.fromHeight(48)),
        backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.pressed) ? p.primaryPressed : p.primary),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(MomentumTokens.radiusMd))),
        textStyle: WidgetStateProperty.all(const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size.fromHeight(48)),
        foregroundColor: WidgetStateProperty.all(p.accentText),
        side: WidgetStateProperty.all(BorderSide(color: p.primary.withValues(alpha: .55))),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(MomentumTokens.radiusMd))),
        textStyle: WidgetStateProperty.all(const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(p.accentText),
        textStyle: WidgetStateProperty.all(const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.primary : (dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: p.textTertiary.withValues(alpha: .6), width: 1.6),
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.primary : Colors.transparent),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.primary,
      inactiveTrackColor: p.textPrimary.withValues(alpha: dark ? .10 : .08),
      thumbColor: Colors.white,
      overlayColor: p.primary.withValues(alpha: .12),
      trackHeight: 6,
    ),
    dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: dark ? const Color(0xFF1E2636) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MomentumTokens.radiusLg), side: BorderSide(color: p.hairline)),
      titleTextStyle: text.headlineSmall,
      contentTextStyle: text.bodyLarge,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: p.cardBase,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MomentumTokens.radiusMd), side: BorderSide(color: p.hairline)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? const Color(0xFF1E2636) : const Color(0xFF0F172A),
      contentTextStyle: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 13.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MomentumTokens.radiusMd)),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: p.textSecondary,
      titleTextStyle: text.titleSmall,
      subtitleTextStyle: text.bodySmall,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all(BorderSide(color: p.hairline)),
        backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.primary.withValues(alpha: dark ? .28 : .14) : Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accentText : p.textSecondary),
        textStyle: WidgetStateProperty.all(const TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.w600)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.cardSubtle,
      selectedColor: p.primary.withValues(alpha: dark ? .30 : .14),
      side: BorderSide(color: p.hairline),
      labelStyle: TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.w600, color: p.textSecondary),
      shape: const StadiumBorder(),
      showCheckmark: false,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
  );
}
