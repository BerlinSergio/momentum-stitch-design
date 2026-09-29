import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// MOMENTUM — COMPLETE SINGLE-FILE REBUILD
// Design reference: Master Design System v2.1
// ============================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MomentumApp(prefs: prefs));
}

class MomentumTokens {
  static const primaryLight = Color(0xFF4F6BFF);
  static const primaryDark = Color(0xFF6366F1);
  static const secondaryLight = Color(0xFF7059FF);
  static const secondaryDark = Color(0xFF38BDF8);

  static const textPrimaryLight = Color(0xFF0F172A);
  static const textSecondaryLight = Color(0xFF475569);
  static const textTertiaryLight = Color(0xFF64748B);
  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const textTertiaryDark = Color(0xFF64748B);

  static const bgLight = Color(0xFFFAF8FF);
  static const bgDark = Color(0xFF0E131F);

  static const successLight = Color(0xFF059669);
  static const successDark = Color(0xFF34D399);
  static const warningLight = Color(0xFFD97706);
  static const warningDark = Color(0xFFFBBF24);
  static const dangerLight = Color(0xFFDC2626);
  static const dangerDark = Color(0xFFF87171);

  static const radiusSm = 8.0;
  static const radiusMd = 14.0;
  static const radiusLg = 20.0;
  static const radiusDock = 28.0;
  static const dockHeight = 68.0;
  static const centerButton = 52.0;
  static const defaultBlur = 18.0;
  static const gutter = 16.0;
}

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

class Store {
  final SharedPreferences prefs;
  Store(this.prefs);

  String get name => prefs.getString('name') ?? 'User';
  String get currency => prefs.getString('currency') ?? 'AFN';
  String get currencySymbol => prefs.getString('currencySymbol') ?? '؋';
  String get timezone => prefs.getString('timezone') ?? 'Asia/Kabul';
  String get city => prefs.getString('city') ?? 'Kabul, Afghanistan';
  int get wallpaperIndex => prefs.getInt('backgroundIndex') ?? 0;
  double get blur => prefs.getDouble('backgroundBlur') ?? MomentumTokens.defaultBlur;
  String get wallpaperSource => prefs.getString('backgroundSource') ?? 'Default / Offline';

  Future<void> setProfile({String? name, String? currency, String? currencySymbol, String? timezone, String? city}) async {
    if (name != null) await prefs.setString('name', name);
    if (currency != null) await prefs.setString('currency', currency);
    if (currencySymbol != null) await prefs.setString('currencySymbol', currencySymbol);
    if (timezone != null) await prefs.setString('timezone', timezone);
    if (city != null) await prefs.setString('city', city);
  }

  List<Map<String, dynamic>> getList(String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      return (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> saveList(String key, List<Map<String, dynamic>> value) async {
    await prefs.setString(key, jsonEncode(value));
  }

  Future<void> setWallpaper(int index) async => prefs.setInt('backgroundIndex', index.clamp(0, wallpapers.length - 1));
  Future<void> setBlur(double value) async => prefs.setDouble('backgroundBlur', value.clamp(0, 40));
  Future<void> setWallpaperSource(String source) async => prefs.setString('backgroundSource', source);

  Future<String> setPin(String pin) async {
    final salt = base64UrlEncode(List<int>.generate(18, (_) => math.Random.secure().nextInt(256)));
    final hash = sha256.convert(utf8.encode('$salt:$pin')).toString();
    await prefs.setString('pinSalt', salt);
    await prefs.setString('pinHash', hash);
    return hash;
  }

  bool hasPin() => prefs.getString('pinHash') != null && prefs.getString('pinSalt') != null;
  bool verifyPin(String pin) {
    final salt = prefs.getString('pinSalt');
    final expected = prefs.getString('pinHash');
    if (salt == null || expected == null) return false;
    return sha256.convert(utf8.encode('$salt:$pin')).toString() == expected;
  }

  bool get appLockEnabled => prefs.getBool('appLockEnabled') ?? false;
  Future<void> setAppLock(bool value) => prefs.setBool('appLockEnabled', value);
  bool get biometricEnabled => prefs.getBool('biometricEnabled') ?? false;
  Future<void> setBiometric(bool value) => prefs.setBool('biometricEnabled', value);

  Future<void> clearAll() async => prefs.clear();
}

class MomentumApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MomentumApp({super.key, required this.prefs});
  @override
  State<MomentumApp> createState() => _MomentumAppState();
}

class _MomentumAppState extends State<MomentumApp> {
  late final Store store;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    store = Store(widget.prefs);
    final saved = widget.prefs.getString('themeMode');
    _themeMode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await widget.prefs.setString('themeMode', mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system');
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final primary = dark ? MomentumTokens.primaryDark : MomentumTokens.primaryLight;
    final secondary = dark ? MomentumTokens.secondaryDark : MomentumTokens.secondaryLight;
    final onSurface = dark ? MomentumTokens.textPrimaryDark : MomentumTokens.textPrimaryLight;
    final secondaryText = dark ? MomentumTokens.textSecondaryDark : MomentumTokens.textSecondaryLight;
    final tertiary = dark ? MomentumTokens.textTertiaryDark : MomentumTokens.textTertiaryLight;
    final surface = dark ? const Color(0xBF161C28) : const Color(0xC7FFFFFF);
    final elevated = dark ? const Color(0xD91E2636) : const Color(0xE6FFFFFF);
    final input = dark ? const Color(0xB3101723) : const Color(0xB3FFFFFF);
    final border = dark ? const Color(0x14FFFFFF) : const Color(0xCCFFFFFF);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        surface: surface,
        onSurface: onSurface,
      ).copyWith(error: dark ? MomentumTokens.dangerDark : MomentumTokens.dangerLight),
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'sans',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, height: 1.15, fontWeight: FontWeight.w700, color: onSurface),
        headlineLarge: TextStyle(fontSize: 24, height: 1.25, fontWeight: FontWeight.w600, color: onSurface),
        headlineMedium: TextStyle(fontSize: 22, height: 1.25, fontWeight: FontWeight.w600, color: onSurface),
        titleLarge: TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w600, color: onSurface),
        titleMedium: TextStyle(fontSize: 16, height: 1.3, fontWeight: FontWeight.w600, color: onSurface),
        titleSmall: TextStyle(fontSize: 15, height: 1.35, fontWeight: FontWeight.w600, color: onSurface),
        bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: secondaryText),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: secondaryText),
        bodySmall: TextStyle(fontSize: 13, height: 1.4, color: secondaryText),
        labelLarge: TextStyle(fontSize: 14, height: 1.35, fontWeight: FontWeight.w500, color: onSurface),
        labelMedium: TextStyle(fontSize: 12, height: 1.35, fontWeight: FontWeight.w500, color: secondaryText),
        labelSmall: TextStyle(fontSize: 11, height: 1.2, fontWeight: FontWeight.w600, letterSpacing: .55, color: tertiary),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: onSurface,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: input,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: TextStyle(color: secondaryText, fontSize: 14),
        hintStyle: TextStyle(color: tertiary, fontSize: 14),
        prefixIconColor: secondaryText,
        suffixIconColor: secondaryText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primary, width: 2)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size.fromHeight(48)),
        backgroundColor: WidgetStateProperty.all(primary),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        textStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size.fromHeight(48)),
        foregroundColor: WidgetStateProperty.all(primary),
        side: WidgetStateProperty.all(BorderSide(color: primary.withValues(alpha: .6))),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      )),
      textButtonTheme: TextButtonThemeData(style: ButtonStyle(foregroundColor: WidgetStateProperty.all(primary))),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary : (dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      dividerTheme: DividerThemeData(color: dark ? Colors.white.withValues(alpha: .05) : Colors.black.withValues(alpha: .04), thickness: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: elevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: elevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      cardTheme: CardThemeData(color: surface, elevation: 0, surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: border))),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFF1E2636) : const Color(0xFF0F172A),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MomentumThemeBridge.callback = setTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Momentum',
      themeMode: _themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: SplashScreen(store: store, setTheme: setTheme),
    );
  }
}

class AppBackdrop extends StatelessWidget {
  final Store store;
  final Widget child;
  const AppBackdrop({super.key, required this.store, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bgIndex = store.wallpaperIndex.clamp(0, wallpapers.length - 1).toInt();
    final bg = wallpapers[bgIndex];
    final colors = dark ? bg.dark : bg.light;
    final blur = store.blur;
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors)),
            child: Stack(children: [
              Positioned(left: -100, top: -90, child: _aura(primary: Theme.of(context).colorScheme.primary.withValues(alpha: .18), size: 240)),
              Positioned(right: -120, top: 120, child: _aura(primary: Colors.white.withValues(alpha: dark ? .04 : .22), size: 280)),
              Positioned(left: 70, bottom: -160, child: _aura(primary: Theme.of(context).colorScheme.secondary.withValues(alpha: .10), size: 260)),
            ]),
          ),
        ),
        Container(color: dark ? const Color.fromRGBO(14, 19, 31, .70) : const Color.fromRGBO(255, 255, 255, .22)),
        child,
      ],
    );
  }

  Widget _aura({required Color primary, required double size}) => IgnorePointer(child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: primary))));
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.borderRadius = const BorderRadius.all(Radius.circular(16)), this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = dark ? const Color(0xBF161C28) : const Color(0xC7FFFFFF);
    final border = dark ? Colors.white.withValues(alpha: .08) : Colors.white.withValues(alpha: .80);
    final content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: MomentumTokens.defaultBlur, sigmaY: MomentumTokens.defaultBlur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(color: fill, borderRadius: borderRadius, border: Border.all(color: border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .28 : .05), blurRadius: 24, offset: const Offset(0, 10))]),
          child: child,
        ),
      ),
    );
    if (onTap == null) return content;
    return InkWell(borderRadius: borderRadius, onTap: onTap, child: content);
  }
}

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;
  const TopBar({super.key, required this.title, this.onBack, this.actions = const []});
  @override
  Size get preferredSize => const Size.fromHeight(56);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: onBack == null ? null : IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)),
      title: Text(title),
      actions: actions,
    );
  }
}

class MomentumScaffold extends StatelessWidget {
  final Store store;
  final String title;
  final Widget body;
  final bool showBottomNav;
  final bool showBack;
  final int activeTab;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const MomentumScaffold({super.key, required this.store, required this.title, required this.body, this.showBottomNav = false, this.showBack = false, this.activeTab = 0, this.onBack, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: title.isEmpty && !showBack ? null : TopBar(title: title, onBack: showBack ? onBack ?? () => Navigator.pop(context) : null, actions: actions),
      body: SafeArea(bottom: !showBottomNav, child: AppBackdrop(store: store, child: body)),
      bottomNavigationBar: showBottomNav ? MainBottomNav(store: store, activeTab: activeTab) : null,
    );
  }
}

class MainBottomNav extends StatelessWidget {
  final Store store;
  final int activeTab;
  const MainBottomNav({super.key, required this.store, required this.activeTab});

  void _go(BuildContext context, int index) {
    if (index == 2) {
      showAddSheet(context, store);
      return;
    }
    if (index == 4) {
      showMoreSheet(context, store);
      return;
    }
    final page = switch (index) {
      0 => HomeDashboard(store: store),
      1 => ExpenseTracker(store: store),
      3 => TasksReminders(store: store),
      _ => HomeDashboard(store: store),
    };
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Container(
        height: MomentumTokens.dockHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: dark ? const Color(0xE00E131F) : const Color(0xD6FFFFFF),
          borderRadius: BorderRadius.circular(MomentumTokens.radiusDock),
          border: Border.all(color: dark ? Colors.white.withValues(alpha: .08) : Colors.white.withValues(alpha: .82)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .45 : .10), blurRadius: 28, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            _item(context, 0, Icons.home_outlined, Icons.home_rounded, 'Home'),
            _item(context, 1, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Finance'),
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -14),
                  child: GestureDetector(
                    onTap: () => showAddSheet(context, store),
                    child: Container(
                      width: MomentumTokens.centerButton,
                      height: MomentumTokens.centerButton,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
                        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: .45), blurRadius: 24, offset: const Offset(0, 10))],
                        border: Border.all(color: Colors.white.withValues(alpha: .35)),
                      ),
                      child: const Icon(Icons.add_rounded, size: 24, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            _item(context, 3, Icons.check_circle_outline, Icons.check_circle_rounded, 'Tasks'),
            _item(context, 4, Icons.more_horiz_rounded, Icons.more_horiz_rounded, 'More'),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    final selected = activeTab == index;
    final color = selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: .50);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _go(context, index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: color)),
            const SizedBox(height: 2),
            AnimatedContainer(duration: const Duration(milliseconds: 150), width: selected ? 16 : 0, height: 2, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(10))),
          ],
        ),
      ),
    );
  }
}

Future<void> showAddSheet(BuildContext context, Store store) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GlassCard(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Quick Add', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _sheetAction(context, store, Icons.receipt_long_outlined, 'Add Expense', 'Record spending', () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditExpensePage(store: store)))),
              _sheetAction(context, store, Icons.payments_outlined, 'Add Income', 'Record money received', () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditIncomePage(store: store)))),
              _sheetAction(context, store, Icons.task_alt_outlined, 'Add Task', 'Create a task or reminder', () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskPage(store: store)))),
              _sheetAction(context, store, Icons.event_repeat_outlined, 'Add Routine', 'Create a routine item', () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditRoutinePage(store: store)))),
              _sheetAction(context, store, Icons.note_add_outlined, 'Quick Note', 'Capture an idea', () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNoteEditor(store: store)))),
              _sheetAction(context, store, Icons.edit_note_outlined, 'Long Note', 'Write a detailed note', () => Navigator.push(context, MaterialPageRoute(builder: (_) => LongNoteEditor(store: store)))),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _sheetAction(BuildContext context, Store store, IconData icon, String title, String subtitle, VoidCallback action) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .10), child: Icon(icon, color: Theme.of(context).colorScheme.primary)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: () { Navigator.pop(context); action(); },
  );
}

Future<void> showMoreSheet(BuildContext context, Store store) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(12),
      child: GlassCard(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('More', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _moreAction(context, 'Income Management', Icons.payments_outlined, IncomeManagement(store: store)),
            _moreAction(context, 'Prayer Times', Icons.mosque_outlined, PrayerTimesPage(store: store)),
            _moreAction(context, 'Tasbeeh', Icons.fingerprint_rounded, TasbeehMain(store: store)),
            _moreAction(context, 'Notes', Icons.notes_outlined, NotesMain(store: store)),
            _moreAction(context, 'Calendars', Icons.calendar_month_outlined, CalendarsMain(store: store)),
            _moreAction(context, 'Settings & Profile', Icons.settings_outlined, SettingsProfile(store: store)),
          ],
        ),
      ),
    ),
  );
}

Widget _moreAction(BuildContext context, String title, IconData icon, Widget page) {
  return ListTile(
    leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .10), child: Icon(icon, color: Theme.of(context).colorScheme.primary)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => page)); },
  );
}

class SplashScreen extends StatefulWidget {
  final Store store;
  final Future<void> Function(ThemeMode) setTheme;
  const SplashScreen({super.key, required this.store, required this.setTheme});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final setup = widget.store.prefs.getBool('setupCompleted') ?? false;
    if (!setup) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PersonalSetup(store: widget.store)));
      return;
    }
    if (widget.store.appLockEnabled) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppUnlockPage(store: widget.store)));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeDashboard(store: widget.store)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackdrop(
        store: widget.store,
        child: Center(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 32),
            borderRadius: BorderRadius.circular(26),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 74, height: 74, decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary.withValues(alpha: .12)), child: Icon(Icons.bolt_rounded, size: 38, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 16),
              Text('Momentum', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 6),
              const Text('Move forward every day.'),
              const SizedBox(height: 20),
              SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2, color: Theme.of(context).colorScheme.primary)),
            ]),
          ),
        ),
      ),
    );
  }
}

class PersonalSetup extends StatefulWidget {
  final Store store;
  const PersonalSetup({super.key, required this.store});
  @override
  State<PersonalSetup> createState() => _PersonalSetupState();
}

class _PersonalSetupState extends State<PersonalSetup> {
  final _name = TextEditingController();
  String _currency = 'AFN';
  String _timezone = 'Asia/Kabul';
  String _city = 'Kabul, Afghanistan';

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name.'))); return; }
    await widget.store.setProfile(name: _name.text.trim(), currency: _currency, currencySymbol: _currency == 'AFN' ? '؋' : _currency == 'USD' ? r'$' : _currency == 'EUR' ? '€' : _currency, timezone: _timezone, city: _city);
    await widget.store.prefs.setBool('setupCompleted', true);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeDashboard(store: widget.store)));
  }

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'Personal Setup',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome to Momentum', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Set up your personal space once.'),
          const SizedBox(height: 18),
          GlassCard(child: Column(children: [
            TextField(controller: _name, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(initialValue: _currency, decoration: const InputDecoration(labelText: 'Currency', prefixIcon: Icon(Icons.payments_outlined)), items: const [DropdownMenuItem(value: 'AFN', child: Text('AFN / ؋')), DropdownMenuItem(value: 'USD', child: Text('USD / \$')), DropdownMenuItem(value: 'EUR', child: Text('EUR / €'))], onChanged: (v) => setState(() => _currency = v ?? 'AFN')),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(initialValue: _timezone, decoration: const InputDecoration(labelText: 'Timezone', prefixIcon: Icon(Icons.schedule_outlined)), items: const [DropdownMenuItem(value: 'Asia/Kabul', child: Text('Asia/Kabul')), DropdownMenuItem(value: 'Asia/Dubai', child: Text('Asia/Dubai')), DropdownMenuItem(value: 'Asia/Karachi', child: Text('Asia/Karachi'))], onChanged: (v) => setState(() => _timezone = v ?? 'Asia/Kabul')),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(initialValue: _city, decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_on_outlined)), items: const [DropdownMenuItem(value: 'Kabul, Afghanistan', child: Text('Kabul, Afghanistan')), DropdownMenuItem(value: 'Herat, Afghanistan', child: Text('Herat, Afghanistan')), DropdownMenuItem(value: 'Mazar-e-Sharif, Afghanistan', child: Text('Mazar-e-Sharif, Afghanistan')), DropdownMenuItem(value: 'Kandahar, Afghanistan', child: Text('Kandahar, Afghanistan'))], onChanged: (v) => setState(() => _city = v ?? 'Kabul, Afghanistan')),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Continue'))),
          ])),
        ]),
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  final Store store;
  const HomeDashboard({super.key, required this.store});
  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  List<Map<String, dynamic>> get expenses => widget.store.getList('expenses');
  List<Map<String, dynamic>> get incomes => widget.store.getList('incomes');
  List<Map<String, dynamic>> get tasks => widget.store.getList('tasks');
  List<Map<String, dynamic>> get routines => widget.store.getList('routines');

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  double _sum(List<Map<String, dynamic>> list) =>
      list.fold<double>(0, (s, e) => s + ((e['amount'] ?? 0) as num).toDouble());

  String _money(double n) => '${widget.store.currencySymbol}${n.toStringAsFixed(0)}';

  String _dateText() {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final income = _sum(incomes);
    final expense = _sum(expenses);
    final saved = income - expense;
    final saveRate = income <= 0 ? 0.0 : (saved / income).clamp(0.0, 1.0).toDouble();
    final initials = widget.store.name.trim().isEmpty ? 'U' : widget.store.name.trim()[0].toUpperCase();
    final palette = Theme.of(context).brightness == Brightness.dark;

    return MomentumScaffold(
      store: widget.store,
      title: '',
      showBottomNav: true,
      activeTab: 0,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
        children: [
          // Stitch-style fixed-header content.
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: .20),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .30)),
                      ),
                      child: Icon(Icons.bubble_chart_rounded, size: 19, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 8),
                    const Text('Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${_greeting()}, ${widget.store.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('👋', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('Stay consistent. Small steps every day.', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 3),
                    Text(_dateText(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary, letterSpacing: .4)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withValues(alpha: .35), Theme.of(context).colorScheme.secondary.withValues(alpha: .25)]),
                    ),
                  ),
                  CircleAvatar(radius: 22, backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: .78), child: Text(initials, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _roundIcon(context, Icons.account_balance_wallet_outlined, size: 32),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Financial Health', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    _statusPill(context, _monthLabel()),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _moneyMetric(context, 'Income', _money(income), Icons.trending_up_rounded, Theme.of(context).brightness == Brightness.dark ? MomentumTokens.successDark : MomentumTokens.successLight, income > 0 ? '+8.4%' : '—')),
                    _metricDivider(context),
                    Expanded(child: _moneyMetric(context, 'Expenses', _money(expense), Icons.check_circle_outline, Theme.of(context).colorScheme.onSurface.withValues(alpha: .45), expense <= income ? 'Safe limit' : 'Review')),
                    _metricDivider(context),
                    Expanded(child: _moneyMetric(context, 'Saved', _money(saved), Icons.savings_outlined, Theme.of(context).colorScheme.primary, '${(saveRate * 100).round()}%')),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Savings Target (${_money(3000)})', style: Theme.of(context).textTheme.labelSmall),
                    Text('${(saveRate * 100).round()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    height: 8,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: palette ? .06 : .08),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: saveRate,
                      child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary, palette ? const Color(0xFF2DD4BF) : Theme.of(context).colorScheme.secondary]))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _quick(context, Icons.add_card_rounded, 'Log Cost', () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditExpensePage(store: widget.store))))),
              const SizedBox(width: 10),
              Expanded(child: _quick(context, Icons.add_task_rounded, 'Add Task', () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskPage(store: widget.store))))),
              const SizedBox(width: 10),
              Expanded(child: _quick(context, Icons.bedtime_outlined, 'Prayers', () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrayerTimesPage(store: widget.store))))),
              const SizedBox(width: 10),
              Expanded(child: _quick(context, Icons.self_improvement_outlined, 'Reflect', () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNoteEditor(store: widget.store))))),
            ],
          ),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _roundIcon(context, Icons.sync_rounded, size: 32),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Routine & Prayer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DailyRoutine(store: widget.store))), child: const Text('Edit')),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withValues(alpha: .18), Theme.of(context).colorScheme.secondary.withValues(alpha: .10)]),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .18)),
                  ),
                  child: Row(
                    children: [
                      _roundIcon(context, Icons.light_mode_outlined, size: 36),
                      const SizedBox(width: 10),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Next: Dhuhr in 1h 45m', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), SizedBox(height: 3), Text('1:05 PM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))])),
                      _statusPill(context, 'Upcoming'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _prayerTimeline(context),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _roundIcon(context, Icons.checklist_rounded, size: 32),
                    const SizedBox(width: 8),
                    const Expanded(child: Text("Today's Tasks", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskPage(store: widget.store))).then((_) => setState(() {})), icon: const Icon(Icons.add, size: 16), label: const Text('Add Task')),
                  ],
                ),
                const SizedBox(height: 8),
                if (tasks.isEmpty)
                  const Padding(padding: EdgeInsets.all(10), child: EmptyState(title: 'No tasks yet', action: 'Add your first task'))
                else
                  ...tasks.take(3).map((task) => TaskTile(store: widget.store, task: task, onChanged: () => setState(() {}))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(15),
            borderRadius: BorderRadius.circular(14),
            child: Row(
              children: [
                _roundIcon(context, Icons.spa_outlined, size: 40),
                const SizedBox(width: 10),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Mindful Streak: 14 Days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), SizedBox(height: 3), Text('Peace comes from within. Do not seek it without.', maxLines: 1, overflow: TextOverflow.ellipsis)])),
                IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNoteEditor(store: widget.store))), icon: const Icon(Icons.chevron_right_rounded)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel() {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final now = DateTime.now();
    return months[now.month - 1];
  }

  Widget _roundIcon(BuildContext context, IconData icon, {double size = 32}) {
    final c = Theme.of(context).colorScheme.primary;
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: .15), border: Border.all(color: c.withValues(alpha: .25))), child: Icon(icon, size: size * .55, color: c));
  }

  Widget _statusPill(BuildContext context, String label) {
    final c = Theme.of(context).colorScheme.primary;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), color: c.withValues(alpha: .16), border: Border.all(color: c.withValues(alpha: .28))), child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)));
  }

  Widget _metricDivider(BuildContext context) => Container(width: 1, height: 52, margin: const EdgeInsets.symmetric(horizontal: 7), color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .10));

  Widget _moneyMetric(BuildContext context, String label, String value, IconData icon, Color accent, String footer) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.labelSmall), const SizedBox(height: 2), FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))), const SizedBox(height: 2), Row(children: [Icon(icon, size: 13, color: accent), const SizedBox(width: 3), Flexible(child: Text(footer, style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))])]);
  }

  Widget _quick(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final c = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderRadius: BorderRadius.circular(16),
        child: Column(children: [_roundIcon(context, icon, size: 40), const SizedBox(height: 6), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center)]),
      ),
    );
  }

  Widget _prayerTimeline(BuildContext context) {
    const prayers = [('Fajr', '5:12 A'), ('Dhuhr', '1:05 P'), ('Asr', '4:28 P'), ('Magh', '6:42 P'), ('Isha', '8:05 P')];
    return Row(
      children: prayers.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        final active = i == 1;
        final done = i == 0;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == prayers.length - 1 ? 0 : 4),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: active ? Theme.of(context).colorScheme.primary.withValues(alpha: .18) : Theme.of(context).colorScheme.onSurface.withValues(alpha: .045), border: Border.all(color: active ? Theme.of(context).colorScheme.primary.withValues(alpha: .35) : Theme.of(context).colorScheme.onSurface.withValues(alpha: .06))),
            child: Column(children: [Text(p.$1, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? Theme.of(context).colorScheme.primary : null)), const SizedBox(height: 4), Text(p.$2, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? Theme.of(context).colorScheme.primary : null)), const SizedBox(height: 5), Container(width: active || done ? 20 : 14, height: active || done ? 20 : 14, decoration: BoxDecoration(shape: BoxShape.circle, color: done ? const Color(0x3310B981) : active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: .10)), child: done ? const Icon(Icons.check, size: 13, color: Color(0xFF10B981)) : active ? const Icon(Icons.alarm, size: 12, color: Colors.white) : null)]),
          ),
        );
      }).toList(),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title; final String? action; final VoidCallback? onTap;
  const SectionTitle({super.key, required this.title, this.action, this.onTap});
  @override Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)), if (action != null) TextButton(onPressed: onTap, child: Text(action!))]);
}

class TaskTile extends StatelessWidget {
  final Store store; final Map<String, dynamic> task; final VoidCallback onChanged;
  const TaskTile({super.key, required this.store, required this.task, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final done = task['done'] == true;
    return ListTile(contentPadding: EdgeInsets.zero, leading: Checkbox(value: done, onChanged: (v) async { final items = store.getList('tasks'); final i = items.indexWhere((e) => e['id'] == task['id']); if (i >= 0) { items[i]['done'] = v ?? false; await store.saveList('tasks', items); onChanged(); } }), title: Text(task['title'] ?? 'Task', style: TextStyle(decoration: done ? TextDecoration.lineThrough : null, fontWeight: FontWeight.w600)), subtitle: Text('${task['time'] ?? ''}${(task['priority'] ?? '') == '' ? '' : ' • ${task['priority']}'}'), trailing: const Icon(Icons.chevron_right_rounded));
  }
}
class RoutineTile extends StatelessWidget { final Map<String, dynamic> item; const RoutineTile({super.key, required this.item}); @override Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .10), child: Icon(Icons.event_repeat_outlined, color: Theme.of(context).colorScheme.primary)), title: Text(item['title'] ?? 'Routine', style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text('${item['time'] ?? ''} • ${item['repeat'] ?? 'Every Day'}')); }
class PrayerPreviewCard extends StatelessWidget { const PrayerPreviewCard({super.key}); @override Widget build(BuildContext context) => const GlassCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.mosque_outlined), title: Text('Next Prayer'), subtitle: Text('Open Prayer Times to load today’s schedule'), trailing: Icon(Icons.chevron_right_rounded))); }
class QuickAction extends StatelessWidget { final IconData icon; final String label; final VoidCallback onTap; const QuickAction({super.key, required this.icon, required this.label, required this.onTap}); @override Widget build(BuildContext context) => GlassCard(onTap: onTap, padding: const EdgeInsets.symmetric(vertical: 14), child: Column(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 6), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))])); }
class EmptyState extends StatelessWidget { final String title; final String action; const EmptyState({super.key, required this.title, required this.action}); @override Widget build(BuildContext context) => Column(children: [const Icon(Icons.inbox_outlined, size: 34), const SizedBox(height: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(action, style: Theme.of(context).textTheme.bodySmall)]); }

class ExpenseTracker extends StatefulWidget { final Store store; const ExpenseTracker({super.key, required this.store}); @override State<ExpenseTracker> createState() => _ExpenseTrackerState(); }
class _ExpenseTrackerState extends State<ExpenseTracker> {
  String _query = ''; String _category = 'All';
  final categories = const ['All','Food','Transportation','Shopping','Bills','Rent','Health','Education','Entertainment','Family','Work','Other'];
  List<Map<String,dynamic>> get _items => widget.store.getList('expenses');
  double _total(List<Map<String,dynamic>> items) => items.fold(0, (s,e)=>s+((e['amount']??0) as num).toDouble());
  @override Widget build(BuildContext context) {
    final list = _items.where((e) { final c = _category == 'All' || e['category'] == _category; final q = _query.isEmpty || '${e['category']} ${e['note']}'.toLowerCase().contains(_query.toLowerCase()); return c && q; }).toList();
    return MomentumScaffold(store: widget.store, title: 'Expense Tracker', showBottomNav: true, activeTab: 1, body: ListView(padding: const EdgeInsets.fromLTRB(16,16,16,110), children: [
      GlassCard(child: Row(children:[Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[Text('Total Expenses',style:Theme.of(context).textTheme.labelLarge),const SizedBox(height:4),Text('${widget.store.currencySymbol}${_total(_items).toStringAsFixed(0)}',style:Theme.of(context).textTheme.headlineMedium)])),FilledButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AddEditExpensePage(store:widget.store))),icon:const Icon(Icons.add,size:18),label:const Text('Add'))])),
      const SizedBox(height:12),
      TextField(onChanged:(v)=>setState(()=>_query=v),decoration:const InputDecoration(hintText:'Search expenses',prefixIcon:Icon(Icons.search))),
      const SizedBox(height:8),
      SizedBox(height:42,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:categories.length,itemBuilder:(_,i){final c=categories[i];return ChoiceChip(label:Text(c),selected:_category==c,onSelected:(_)=>setState(()=>_category=c));},separatorBuilder:(_,__)=>const SizedBox(width:8))),
      const SizedBox(height:12),
      if(list.isEmpty) const GlassCard(child:EmptyState(title:'No expenses',action:'Add your first expense')) else ...list.map((e)=>_expenseTile(e)),
    ]));
  }
  Widget _expenseTile(Map<String,dynamic> e){final amount=(e['amount']??0) as num;return Padding(padding:const EdgeInsets.only(bottom:10),child:GlassCard(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AddEditExpensePage(store:widget.store,existing:e))).then((_)=>setState((){})),child:Row(children:[CircleAvatar(backgroundColor:Theme.of(context).colorScheme.primary.withValues(alpha:.10),child:Icon(Icons.receipt_long_outlined,color:Theme.of(context).colorScheme.primary)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e['category']??'Other',style:const TextStyle(fontWeight:FontWeight.w700)),const SizedBox(height:3),Text(e['note']??'',maxLines:1,overflow:TextOverflow.ellipsis),Text(_fmtDate(e['date']),style:Theme.of(context).textTheme.labelSmall)])),Text('-${widget.store.currencySymbol}${amount.toStringAsFixed(0)}',style:TextStyle(color:Theme.of(context).colorScheme.error,fontWeight:FontWeight.w700))])));}
}

class AddEditExpensePage extends StatefulWidget { final Store store; final Map<String,dynamic>? existing; const AddEditExpensePage({super.key, required this.store, this.existing}); @override State<AddEditExpensePage> createState()=>_AddEditExpensePageState(); }
class _AddEditExpensePageState extends State<AddEditExpensePage>{late TextEditingController _amount;late TextEditingController _note;String _category='Food';DateTime _date=DateTime.now();final cats=const ['Food','Transportation','Shopping','Bills','Rent','Health','Education','Entertainment','Family','Work','Other'];@override void initState(){super.initState();final e=widget.existing;_amount=TextEditingController(text:e==null?'':(e['amount']??'').toString());_note=TextEditingController(text:e?['note']?.toString() ?? '');_category=e?['category']?.toString() ?? 'Food';if(e?['date'] != null){_date=DateTime.tryParse(e!['date'].toString())??DateTime.now();}}@override void dispose(){_amount.dispose();_note.dispose();super.dispose();}Future<void> _save()async{final a=double.tryParse(_amount.text.trim());if(a==null||a<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Enter a valid amount.')));return;}final items=widget.store.getList('expenses');final obj={'id':widget.existing?['id']??DateTime.now().microsecondsSinceEpoch.toString(),'amount':a,'category':_category,'note':_note.text.trim(),'date':_date.toIso8601String()};final i=items.indexWhere((e)=>e['id']==obj['id']);if(i>=0)items[i]=obj;else items.insert(0,obj);await widget.store.saveList('expenses',items);if(mounted)Navigator.pop(context);}Future<void> _pickDate()async{final d=await showDatePicker(context:context,firstDate:DateTime(2020),lastDate:DateTime(2100),initialDate:_date);if(d!=null)setState(()=>_date=d);} @override Widget build(BuildContext context)=>MomentumScaffold(store:widget.store,title:widget.existing==null?'Add Expense':'Edit Expense',showBack:true,body:ListView(padding:const EdgeInsets.all(16),children:[GlassCard(child:Column(children:[TextField(controller:_amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:'Amount',prefixText:'${widget.store.currencySymbol} ')),const SizedBox(height:14),DropdownButtonFormField<String>(initialValue:_category,decoration:const InputDecoration(labelText:'Category'),items:cats.map((c)=>DropdownMenuItem(value:c,child:Text(c))).toList(),onChanged:(v)=>setState(()=>_category=v??'Food')),const SizedBox(height:14),ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.calendar_today_outlined),title:const Text('Date'),subtitle:Text(_fmtDate(_date.toIso8601String())),trailing:TextButton(onPressed:_pickDate,child:const Text('Change'))),TextField(controller:_note,maxLines:3,decoration:const InputDecoration(labelText:'Note')),const SizedBox(height:18),SizedBox(width:double.infinity,child:FilledButton(onPressed:_save,child:Text(widget.existing==null?'Save Expense':'Save Changes'))),if(widget.existing!=null)Padding(padding:const EdgeInsets.only(top:8),child:TextButton.icon(onPressed:()async{final items=widget.store.getList('expenses');items.removeWhere((e)=>e['id']==widget.existing?['id']);await widget.store.saveList('expenses',items);if(mounted)Navigator.pop(context);},icon:const Icon(Icons.delete_outline),label:const Text('Delete Expense')))]))]));}

class IncomeManagement extends StatefulWidget {final Store store;const IncomeManagement({super.key,required this.store});@override State<IncomeManagement> createState()=>_IncomeManagementState();}
class _IncomeManagementState extends State<IncomeManagement>{final sources=const ['Salary','Freelance','Business','Bonus','Other'];String _query='';List<Map<String,dynamic>> get _items=>widget.store.getList('incomes');double _sum()=>_items.fold(0,(s,e)=>s+((e['amount']??0) as num).toDouble());@override Widget build(BuildContext context){final list=_items.where((e)=>_query.isEmpty||'${e['source']} ${e['note']}'.toLowerCase().contains(_query.toLowerCase())).toList();return MomentumScaffold(store:widget.store,title:'Income Management',body:ListView(padding:const EdgeInsets.all(16),children:[GlassCard(child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Total Income',style:Theme.of(context).textTheme.labelLarge),const SizedBox(height:4),Text('${widget.store.currencySymbol}${_sum().toStringAsFixed(0)}',style:Theme.of(context).textTheme.headlineMedium)])),FilledButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AddEditIncomePage(store:widget.store))).then((_)=>setState((){})),icon:const Icon(Icons.add,size:18),label:const Text('Add'))])),const SizedBox(height:12),TextField(onChanged:(v)=>setState(()=>_query=v),decoration:const InputDecoration(hintText:'Search income',prefixIcon:Icon(Icons.search))),const SizedBox(height:12),if(list.isEmpty)const GlassCard(child:EmptyState(title:'No income records',action:'Add your first income')) else ...list.map((e)=>Padding(padding:const EdgeInsets.only(bottom:10),child:GlassCard(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AddEditIncomePage(store:widget.store,existing:e))).then((_)=>setState((){})),child:Row(children:[CircleAvatar(backgroundColor:MomentumTokens.successLight.withValues(alpha:.10),child:Icon(Icons.payments_outlined,color:MomentumTokens.successDark)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e['source']??'Other',style:const TextStyle(fontWeight:FontWeight.w700)),Text(_fmtDate(e['date']),style:Theme.of(context).textTheme.labelSmall),Text(e['note']??'',maxLines:1,overflow:TextOverflow.ellipsis)])),Text('+${widget.store.currencySymbol}${((e['amount']??0)as num).toStringAsFixed(0)}',style:TextStyle(color:Theme.of(context).brightness==Brightness.dark?MomentumTokens.successDark:MomentumTokens.successLight,fontWeight:FontWeight.w700))]))))]));}}

class AddEditIncomePage extends StatefulWidget {final Store store;final Map<String,dynamic>? existing;const AddEditIncomePage({super.key,required this.store,this.existing});@override State<AddEditIncomePage> createState()=>_AddEditIncomePageState();}
class _AddEditIncomePageState extends State<AddEditIncomePage>{late TextEditingController _amount;late TextEditingController _note;String _source='Salary';DateTime _date=DateTime.now();final sources=const ['Salary','Freelance','Business','Bonus','Other'];@override void initState(){super.initState();final e=widget.existing;_amount=TextEditingController(text:e==null?'':(e['amount']??'').toString());_note=TextEditingController(text:e?['note']?.toString() ?? '');_source=e?['source']?.toString() ?? 'Salary';_date=e?['date'] != null ? DateTime.tryParse(e!['date'].toString()) ?? DateTime.now() : DateTime.now();}@override void dispose(){_amount.dispose();_note.dispose();super.dispose();}Future<void>_save()async{final a=double.tryParse(_amount.text.trim());if(a==null||a<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Enter a valid amount.')));return;}final items=widget.store.getList('incomes');final obj={'id':widget.existing?['id']??DateTime.now().microsecondsSinceEpoch.toString(),'amount':a,'source':_source,'note':_note.text.trim(),'date':_date.toIso8601String()};final i=items.indexWhere((e)=>e['id']==obj['id']);if(i>=0)items[i]=obj;else items.insert(0,obj);await widget.store.saveList('incomes',items);if(mounted)Navigator.pop(context);} @override Widget build(BuildContext context)=>MomentumScaffold(store:widget.store,title:widget.existing==null?'Add Income':'Edit Income',showBack:true,body:ListView(padding:const EdgeInsets.all(16),children:[GlassCard(child:Column(children:[TextField(controller:_amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:'Amount',prefixText:'${widget.store.currencySymbol} ')),const SizedBox(height:14),DropdownButtonFormField<String>(initialValue:_source,decoration:const InputDecoration(labelText:'Income Source'),items:sources.map((c)=>DropdownMenuItem(value:c,child:Text(c))).toList(),onChanged:(v)=>setState(()=>_source=v??'Salary')),const SizedBox(height:14),ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.calendar_today_outlined),title:const Text('Date'),subtitle:Text(_fmtDate(_date.toIso8601String())),trailing:TextButton(onPressed:()=>showDatePicker(context:context,firstDate:DateTime(2020),lastDate:DateTime(2100),initialDate:_date).then((d){if(d!=null)setState(()=>_date=d);}),child:const Text('Change'))),TextField(controller:_note,maxLines:3,decoration:const InputDecoration(labelText:'Note')),const SizedBox(height:18),SizedBox(width:double.infinity,child:FilledButton(onPressed:_save,child:Text(widget.existing==null?'Save Income':'Save Changes')))]))]));}

class TasksReminders extends StatefulWidget {
  final Store store;
  const TasksReminders({super.key, required this.store});
  @override
  State<TasksReminders> createState() => _TasksRemindersState();
}

class _TasksRemindersState extends State<TasksReminders> {
  List<Map<String, dynamic>> get items => widget.store.getList('tasks');

  @override
  Widget build(BuildContext context) {
    final done = items.where((e) => e['done'] == true).length;
    return MomentumScaffold(
      store: widget.store,
      title: 'Tasks & Reminders',
      showBottomNav: true,
      activeTab: 3,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          GlassCard(
            child: Row(
              children: [
                Expanded(child: Text('$done of ${items.length} completed', style: Theme.of(context).textTheme.titleMedium)),
                FilledButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskPage(store: widget.store))).then((_) => setState(() {})),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const GlassCard(child: EmptyState(title: 'No tasks yet', action: 'Create a reminder'))
          else
            ...items.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskPage(store: widget.store, existing: t))).then((_) => setState(() {})),
                  child: TaskTile(store: widget.store, task: t, onChanged: () => setState(() {})),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AddEditTaskPage extends StatefulWidget {
  final Store store;
  final Map<String, dynamic>? existing;
  const AddEditTaskPage({super.key, required this.store, this.existing});
  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  String _priority = 'Normal';
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _reminder = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?['title']?.toString() ?? '');
    _desc = TextEditingController(text: e?['description']?.toString() ?? '');
    _priority = e?['priority']?.toString() ?? 'Normal';
    _reminder = e?['reminder'] == true;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    final items = widget.store.getList('tasks');
    final obj = <String, dynamic>{
      'id': widget.existing?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'priority': _priority,
      'time': _time.format(context),
      'reminder': _reminder,
      'done': widget.existing?['done'] == true,
    };
    final i = items.indexWhere((e) => e['id'] == obj['id']);
    if (i >= 0) {
      items[i] = obj;
    } else {
      items.insert(0, obj);
    }
    await widget.store.saveList('tasks', items);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: widget.existing == null ? 'Add Task' : 'Edit Task',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                TextField(controller: _title, decoration: const InputDecoration(labelText: 'Task title')),
                const SizedBox(height: 14),
                TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const ['Low', 'Normal', 'High'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _priority = v ?? 'Normal'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Time'),
                  trailing: TextButton(
                    onPressed: () => showTimePicker(context: context, initialTime: _time).then((t) { if (t != null) setState(() => _time = t); }),
                    child: Text(_time.format(context)),
                  ),
                ),
                SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Reminder'), value: _reminder, onChanged: (v) => setState(() => _reminder = v)),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: Text(widget.existing == null ? 'Save Task' : 'Save Changes'))),
                if (widget.existing != null)
                  TextButton.icon(
                    onPressed: () async {
                      final items = widget.store.getList('tasks');
                      items.removeWhere((e) => e['id'] == widget.existing?['id']);
                      await widget.store.saveList('tasks', items);
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Task'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailyRoutine extends StatefulWidget {
  final Store store;
  const DailyRoutine({super.key, required this.store});
  @override
  State<DailyRoutine> createState() => _DailyRoutineState();
}

class _DailyRoutineState extends State<DailyRoutine> {
  List<Map<String, dynamic>> get items => widget.store.getList('routines');

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'Daily Routine',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Row(
              children: [
                Expanded(child: Text('${items.length} routine items', style: Theme.of(context).textTheme.titleMedium)),
                FilledButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditRoutinePage(store: widget.store))).then((_) => setState(() {})),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const GlassCard(child: EmptyState(title: 'No routines yet', action: 'Create your first routine'))
          else
            ...items.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditRoutinePage(store: widget.store, existing: r))).then((_) => setState(() {})),
                  child: RoutineTile(item: r),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AddEditRoutinePage extends StatefulWidget {
  final Store store;
  final Map<String, dynamic>? existing;
  const AddEditRoutinePage({super.key, required this.store, this.existing});
  @override
  State<AddEditRoutinePage> createState() => _AddEditRoutinePageState();
}

class _AddEditRoutinePageState extends State<AddEditRoutinePage> {
  late final TextEditingController _title;
  String _repeat = 'Every Day';
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  bool _reminder = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?['title']?.toString() ?? '');
    _repeat = e?['repeat']?.toString() ?? 'Every Day';
    _reminder = e?['reminder'] == true;
  }

  @override
  void dispose() { _title.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    final items = widget.store.getList('routines');
    final obj = <String, dynamic>{
      'id': widget.existing?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      'title': _title.text.trim(),
      'repeat': _repeat,
      'time': _time.format(context),
      'reminder': _reminder,
    };
    final i = items.indexWhere((e) => e['id'] == obj['id']);
    if (i >= 0) items[i] = obj; else items.insert(0, obj);
    await widget.store.saveList('routines', items);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: widget.existing == null ? 'Add Routine' : 'Edit Routine',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                TextField(controller: _title, decoration: const InputDecoration(labelText: 'Routine name')),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _repeat,
                  decoration: const InputDecoration(labelText: 'Repeat'),
                  items: const ['Every Day', 'Monday–Friday', 'Custom Days'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _repeat = v ?? 'Every Day'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Time'),
                  trailing: TextButton(
                    onPressed: () => showTimePicker(context: context, initialTime: _time).then((t) { if (t != null) setState(() => _time = t); }),
                    child: Text(_time.format(context)),
                  ),
                ),
                SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Reminder'), value: _reminder, onChanged: (v) => setState(() => _reminder = v)),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: Text(widget.existing == null ? 'Save Routine' : 'Save Changes'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrayerService {
  static Future<Map<String, String>> fetch({required String city, required String country}) async {
    final uri = Uri.parse('https://api.aladhan.com/v1/timingsByCity?city=${Uri.encodeQueryComponent(city)}&country=${Uri.encodeQueryComponent(country)}&method=2');
    final client = HttpClient();
    try {
      final req = await client.getUrl(uri).timeout(const Duration(seconds: 12));
      final res = await req.close().timeout(const Duration(seconds: 12));
      final body = await utf8.decodeStream(res);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final timings = Map<String, dynamic>.from(data['data']['timings']);
        return {for (final k in ['Fajr','Dhuhr','Asr','Maghrib','Isha']) k: '${timings[k] ?? '--:--'}'};
      }
    } catch (_) {}
    finally { client.close(force: true); }
    return {for (final k in ['Fajr','Dhuhr','Asr','Maghrib','Isha']) k: '--:--'};
  }
}

class PrayerTimesPage extends StatefulWidget {
  final Store store;
  const PrayerTimesPage({super.key, required this.store});
  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  Map<String, String> _times = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final parts = widget.store.city.split(',');
    final city = parts.first.trim();
    final country = parts.length > 1 ? parts.sublist(1).join(',').trim() : 'Afghanistan';
    final t = await PrayerService.fetch(city: city, country: country);
    if (mounted) {
      setState(() {
        _times = t;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'Prayer Times',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.store.city, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Today • ${widget.store.timezone}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else
            GlassCard(
              child: Column(
                children: _times.entries
                    .map(
                      (e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
                          child: Icon(Icons.access_time_rounded, color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Text(e.value, style: Theme.of(context).textTheme.titleMedium),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 12),
          GlassCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrayerNotificationSettings(store: widget.store))),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.notifications_outlined),
              title: Text('Prayer Notification Settings'),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class PrayerNotificationSettings extends StatefulWidget{final Store store;const PrayerNotificationSettings({super.key,required this.store});@override State<PrayerNotificationSettings> createState()=>_PrayerNotificationSettingsState();}
class _PrayerNotificationSettingsState extends State<PrayerNotificationSettings>{bool master=true;Map<String,bool> offsets={'At prayer time':true,'5 minutes before':false,'10 minutes before':false,'15 minutes before':false};@override Widget build(BuildContext context)=>MomentumScaffold(store:widget.store,title:'Prayer Notifications',showBack:true,body:ListView(padding:const EdgeInsets.all(16),children:[GlassCard(child:SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Prayer notifications'),value:master,onChanged:(v)=>setState(()=>master=v))),const SizedBox(height:12),GlassCard(child:Column(children:offsets.keys.map((k)=>SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(k),value:offsets[k]!,onChanged:master?(v)=>setState(()=>offsets[k]=v):null)).toList()))]));}

class TasbeehMain extends StatefulWidget {
  final Store store;
  const TasbeehMain({super.key, required this.store});
  @override
  State<TasbeehMain> createState() => _TasbeehMainState();
}

class _TasbeehMainState extends State<TasbeehMain> {
  String _name = 'SubhanAllah';
  int _count = 0;
  int _target = 33;
  bool _vibrate = true;
  bool _sound = false;

  List<Map<String, dynamic>> _getHistory() => widget.store.getList('tasbeehHistory');

  Future<void> _increment() async {
    setState(() => _count++);
    if (_vibrate) HapticFeedback.lightImpact();
    if (_sound) SystemSound.play(SystemSoundType.click);
    if (_count < _target) return;

    final completed = _count;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Target Completed'),
        content: Text('$_name • $completed'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continue')),
          FilledButton(
            onPressed: () {
              setState(() => _count = 0);
              Navigator.pop(context);
            },
            child: const Text('New Session'),
          ),
        ],
      ),
    );
    final history = _getHistory();
    history.insert(0, {
      'name': _name,
      'count': completed,
      'target': _target,
      'date': DateTime.now().toIso8601String(),
    });
    await widget.store.saveList('tasbeehHistory', history);
  }

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'Tasbeeh',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                Text(_name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text('Target $_target', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 20),
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .24), width: 2),
                  ),
                  child: Center(child: Text('$_count', style: Theme.of(context).textTheme.displayLarge)),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: _increment,
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
                      boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: .35), blurRadius: 22, offset: const Offset(0, 10))],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(onPressed: () => setState(() => _count = 0), child: const Text('Reset')),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewEditTasbeeh(store: widget.store))).then((_) => setState(() {})),
                      child: const Text('New Tasbeeh'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TasbeehHistory(store: widget.store))),
                  child: const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.history_rounded), title: Text('History'), trailing: Icon(Icons.chevron_right_rounded)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TasbeehSettings(store: widget.store))),
                  child: const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.tune_rounded), title: Text('Settings'), trailing: Icon(Icons.chevron_right_rounded)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NewEditTasbeeh extends StatefulWidget{final Store store;const NewEditTasbeeh({super.key,required this.store});@override State<NewEditTasbeeh> createState()=>_NewEditTasbeehState();}
class _NewEditTasbeehState extends State<NewEditTasbeeh>{final _name=TextEditingController();String _target='33';@override void dispose(){_name.dispose();super.dispose();}@override Widget build(BuildContext context)=>MomentumScaffold(store:widget.store,title:'New / Edit Tasbeeh',showBack:true,body:ListView(padding:const EdgeInsets.all(16),children:[GlassCard(child:Column(children:[TextField(controller:_name,decoration:const InputDecoration(labelText:'Dhikr / Tasbeeh name')),const SizedBox(height:14),DropdownButtonFormField<String>(initialValue:_target,decoration:const InputDecoration(labelText:'Target'),items:const ['33','99','100','1000','Custom'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>_target=v??'33')),const SizedBox(height:18),SizedBox(width:double.infinity,child:FilledButton(onPressed:()=>Navigator.pop(context),child:const Text('Save Tasbeeh')))]))]));}
class TasbeehHistory extends StatelessWidget{final Store store;const TasbeehHistory({super.key,required this.store});@override Widget build(BuildContext context){final h=store.getList('tasbeehHistory');return MomentumScaffold(store:store,title:'Tasbeeh History',showBack:true,body:ListView(padding:const EdgeInsets.all(16),children:[if(h.isEmpty)const GlassCard(child:EmptyState(title:'No sessions yet',action:'Complete your first target')) else ...h.map((e)=>Padding(padding:const EdgeInsets.only(bottom:10),child:GlassCard(child:ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.auto_awesome_rounded),title:Text(e['name']?.toString() ?? 'Tasbeeh session',style:const TextStyle(fontWeight:FontWeight.w600)),subtitle:Text('${e['count']}/${e['target']} • ${_fmtDate(e['date'])}')))))]));}}
class TasbeehSettings extends StatefulWidget{final Store store;const TasbeehSettings({super.key,required this.store});@override State<TasbeehSettings> createState()=>_TasbeehSettingsState();}
class _TasbeehSettingsState extends State<TasbeehSettings>{bool vibration=true;bool sound=false;@override Widget build(BuildContext context)=>MomentumScaffold(store:widget.store,title:'Tasbeeh Settings',showBack:true,body:ListView(padding:const EdgeInsets.all(16),children:[GlassCard(child:Column(children:[SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Vibration'),value:vibration,onChanged:(v)=>setState(()=>vibration=v)),SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Sound'),value:sound,onChanged:(v)=>setState(()=>sound=v))]))]));}

class NotesMain extends StatefulWidget {
  final Store store;
  const NotesMain({super.key, required this.store});
  @override
  State<NotesMain> createState() => _NotesMainState();
}

class _NotesMainState extends State<NotesMain> {
  String query = '';
  List<Map<String, dynamic>> get notes => widget.store.getList('notes');

  @override
  Widget build(BuildContext context) {
    final list = notes.where((e) {
      final q = query.toLowerCase();
      return q.isEmpty || '${e['title']} ${e['content']}'.toLowerCase().contains(q);
    }).toList();
    return MomentumScaffold(
      store: widget.store,
      title: 'Notes',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(hintText: 'Search notes', prefixIcon: Icon(Icons.search)))),
              const SizedBox(width: 8),
              IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNoteEditor(store: widget.store))).then((_) => setState(() {})), icon: const Icon(Icons.flash_on_outlined)),
              IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LongNoteEditor(store: widget.store))).then((_) => setState(() {})), icon: const Icon(Icons.edit_note_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            const GlassCard(child: EmptyState(title: 'No notes yet', action: 'Create a quick or long note'))
          else
            ...list.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  onTap: () {
                    final page = n['type'] == 'quick'
                        ? QuickNoteEditor(store: widget.store, existing: n)
                        : LongNoteEditor(store: widget.store, existing: n);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) => setState(() {}));
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
                      child: Icon(n['type'] == 'quick' ? Icons.flash_on_outlined : Icons.description_outlined, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(n['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(n['content'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Text(_fmtDate(n['date']), style: Theme.of(context).textTheme.labelSmall),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QuickNoteEditor extends StatefulWidget {
  final Store store;
  final Map<String, dynamic>? existing;
  const QuickNoteEditor({super.key, required this.store, this.existing});
  @override
  State<QuickNoteEditor> createState() => _QuickNoteEditorState();
}

class _QuickNoteEditorState extends State<QuickNoteEditor> {
  late final TextEditingController _title;
  late final TextEditingController _content;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?['title']?.toString() ?? '');
    _content = TextEditingController(text: widget.existing?['content']?.toString() ?? '');
  }

  @override
  void dispose() { _title.dispose(); _content.dispose(); super.dispose(); }

  Future<void> _save() async {
    final items = widget.store.getList('notes');
    final obj = <String, dynamic>{
      'id': widget.existing?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      'type': 'quick',
      'title': _title.text.trim().isEmpty ? 'Quick Note' : _title.text.trim(),
      'content': _content.text.trim(),
      'date': DateTime.now().toIso8601String(),
      'attachments': widget.existing?['attachments'] ?? [],
    };
    final i = items.indexWhere((e) => e['id'] == obj['id']);
    if (i >= 0) items[i] = obj; else items.insert(0, obj);
    await widget.store.saveList('notes', items);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => MomentumScaffold(
        store: widget.store,
        title: 'Quick Note',
        showBack: true,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              child: Column(
                children: [
                  TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 14),
                  TextField(controller: _content, minLines: 6, maxLines: 10, decoration: const InputDecoration(labelText: 'Quick note')),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save Note'))),
                ],
              ),
            ),
          ],
        ),
      );
}

class LongNoteEditor extends StatefulWidget {
  final Store store;
  final Map<String, dynamic>? existing;
  const LongNoteEditor({super.key, required this.store, this.existing});
  @override
  State<LongNoteEditor> createState() => _LongNoteEditorState();
}

class _LongNoteEditorState extends State<LongNoteEditor> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _attachments = [];

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?['title']?.toString() ?? '');
    _content = TextEditingController(text: widget.existing?['content']?.toString() ?? '');
    final raw = widget.existing?['attachments'];
    _attachments = (raw is List ? raw : const <dynamic>[]).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  void dispose() { _title.dispose(); _content.dispose(); super.dispose(); }

  Future<void> _pick(ImageSource source, {required bool video}) async {
    final XFile? f = video ? await _picker.pickVideo(source: source) : await _picker.pickImage(source: source);
    if (f != null) setState(() => _attachments.add({'type': video ? 'video' : 'image', 'path': f.path}));
  }

  Future<void> _save() async {
    final items = widget.store.getList('notes');
    final obj = <String, dynamic>{
      'id': widget.existing?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      'type': 'long',
      'title': _title.text.trim().isEmpty ? 'Long Note' : _title.text.trim(),
      'content': _content.text,
      'date': DateTime.now().toIso8601String(),
      'attachments': _attachments,
    };
    final i = items.indexWhere((e) => e['id'] == obj['id']);
    if (i >= 0) items[i] = obj; else items.insert(0, obj);
    await widget.store.saveList('notes', items);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => MomentumScaffold(
        store: widget.store,
        title: 'Long Note',
        showBack: true,
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      title: const Text('Photo'),
                      leading: const Icon(Icons.photo_outlined),
                      onTap: () { Navigator.pop(context); _pick(ImageSource.gallery, video: false); },
                    ),
                    ListTile(
                      title: const Text('Video'),
                      leading: const Icon(Icons.videocam_outlined),
                      onTap: () { Navigator.pop(context); _pick(ImageSource.gallery, video: true); },
                    ),
                  ],
                ),
              ),
            ),
            icon: const Icon(Icons.attach_file_rounded),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              child: Column(
                children: [
                  TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 14),
                  TextField(controller: _content, minLines: 15, maxLines: 30, decoration: const InputDecoration(labelText: 'Write your note', alignLabelWithHint: true)),
                  const SizedBox(height: 14),
                  if (_attachments.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _attachments.asMap().entries.map((entry) => Chip(
                        avatar: Icon(entry.value['type'] == 'video' ? Icons.videocam_outlined : Icons.photo_outlined),
                        label: Text(entry.value['type'] == 'video' ? 'Video attached' : 'Photo attached'),
                        onDeleted: () => setState(() => _attachments.removeAt(entry.key)),
                      )).toList(),
                    ),
                  const SizedBox(height: 14),
                  SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save Note'))),
                ],
              ),
            ),
          ],
        ),
      );
}

class NoteMediaViewer extends StatelessWidget {
  final Store store;
  final String path;
  final bool isVideo;
  const NoteMediaViewer({super.key, required this.store, required this.path, required this.isVideo});
  @override
  Widget build(BuildContext context) => MomentumScaffold(
        store: store,
        title: 'Attachment',
        showBack: true,
        body: Center(
          child: isVideo
              ? GlassCard(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.videocam_outlined, size: 56), const SizedBox(height: 12), const Text('Video attachment'), const SizedBox(height: 6), Text(path, textAlign: TextAlign.center)]))
              : Image.file(File(path), fit: BoxFit.contain),
        ),
      );
}

class CalendarsMain extends StatefulWidget {
  final Store store;
  const CalendarsMain({super.key, required this.store});
  @override
  State<CalendarsMain> createState() => _CalendarsMainState();
}

class _CalendarsMainState extends State<CalendarsMain> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      GregorianCalendarPage(store: widget.store),
      HijriCalendarPage(store: widget.store),
      ShamsiCalendarPage(store: widget.store),
    ];
    return MomentumScaffold(
      store: widget.store,
      title: 'Calendars',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Gregorian')),
                    ButtonSegment(value: 1, label: Text('Hijri')),
                    ButtonSegment(value: 2, label: Text('Shamsi')),
                  ],
                  selected: {tab},
                  onSelectionChanged: (s) => setState(() => tab = s.first),
                ),
                const SizedBox(height: 14),
                pages[tab],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GregorianCalendarPage extends StatefulWidget {
  final Store store;
  const GregorianCalendarPage({super.key, required this.store});
  @override
  State<GregorianCalendarPage> createState() => _GregorianCalendarPageState();
}

class _GregorianCalendarPageState extends State<GregorianCalendarPage> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  Widget build(BuildContext context) {
    return _calendarShell(
      context,
      store: widget.store,
      title: 'Gregorian',
      monthLabel: '${_months[month.month - 1]} ${month.year}',
      onPrev: () => setState(() => month = DateTime(month.year, month.month - 1)),
      onNext: () => setState(() => month = DateTime(month.year, month.month + 1)),
      days: List.generate(DateTime(month.year, month.month + 1, 0).day, (i) => DateTime(month.year, month.month, i + 1)),
      toLabel: (d) => '${d.day}',
    );
  }
}

class HijriCalendarPage extends StatefulWidget {
  final Store store;
  const HijriCalendarPage({super.key, required this.store});
  @override
  State<HijriCalendarPage> createState() => _HijriCalendarPageState();
}

class _HijriCalendarPageState extends State<HijriCalendarPage> {
  DateTime month = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final h = _gregorianToHijri(month);
    final days = List.generate(30, (i) => _addDays(month, i));
    return _calendarShell(
      context,
      store: widget.store,
      title: 'Islamic / Hijri',
      monthLabel: '${_hijriMonths[h[1] - 1]} ${h[0]}',
      onPrev: () => setState(() => month = DateTime(month.year, month.month - 1)),
      onNext: () => setState(() => month = DateTime(month.year, month.month + 1)),
      days: days,
      toLabel: (d) {
        final x = _gregorianToHijri(d);
        return '${x[2]}';
      },
    );
  }
}

class ShamsiCalendarPage extends StatefulWidget {
  final Store store;
  const ShamsiCalendarPage({super.key, required this.store});
  @override
  State<ShamsiCalendarPage> createState() => _ShamsiCalendarPageState();
}

class _ShamsiCalendarPageState extends State<ShamsiCalendarPage> {
  DateTime month = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final j = _gregorianToJalali(month);
    final monthDays = j[1] <= 6 ? 31 : 30;
    final days = List.generate(monthDays, (i) => _addDays(month, i));
    return _calendarShell(
      context,
      store: widget.store,
      title: 'Afghan Solar / Hijri Shamsi',
      monthLabel: '${_jalaliMonths[j[1] - 1]} ${j[0]}',
      onPrev: () => setState(() => month = DateTime(month.year, month.month - 1)),
      onNext: () => setState(() => month = DateTime(month.year, month.month + 1)),
      days: days,
      toLabel: (d) {
        final x = _gregorianToJalali(d);
        return '${x[2]}';
      },
    );
  }
}

Widget _calendarShell(
  BuildContext context, {
  required Store store,
  required String title,
  required String monthLabel,
  required VoidCallback onPrev,
  required VoidCallback onNext,
  required List<DateTime> days,
  required String Function(DateTime) toLabel,
}) {
  final now = DateTime.now();
  return MomentumScaffold(
    store: store,
    title: title,
    showBack: true,
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left_rounded)),
                  Expanded(child: Center(child: Text(monthLabel, style: Theme.of(context).textTheme.titleLarge))),
                  IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right_rounded)),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (c, i) {
                  final d = days[i];
                  final today = d.year == now.year && d.month == now.month && d.day == now.day;
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: today ? Theme.of(context).colorScheme.primary.withValues(alpha: .14) : Colors.transparent,
                      border: Border.all(color: today ? Theme.of(context).colorScheme.primary : Colors.transparent),
                    ),
                    child: Center(
                      child: Text(
                        toLabel(d),
                        style: TextStyle(fontWeight: today ? FontWeight.w700 : FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text('Use the calendar section for dates, events and occasion details.'),
            ],
          ),
        ),
      ],
    ),
  );
}

class SettingsProfile extends StatelessWidget {
  final Store store;
  const SettingsProfile({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: store,
      title: 'Settings & Profile',
      showBottomNav: true,
      activeTab: 4,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          GlassCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
                child: Text(
                  store.name.isEmpty ? 'U' : store.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
                ),
              ),
              title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(store.city),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfile(store: store))),
            ),
          ),
          const SizedBox(height: 10),
          _settings(context, 'Appearance', Icons.palette_outlined, AppearancePage(store: store)),
          _settings(context, 'Background / Wallpaper Library', Icons.wallpaper_outlined, WallpaperLibrary(store: store)),
          _settings(context, 'Background Preview & Blur', Icons.blur_on_rounded, WallpaperBlurPage(store: store)),
          _settings(context, 'App Lock', Icons.lock_outline_rounded, AppLockPage(store: store)),
          _settings(context, 'Notifications', Icons.notifications_none_rounded, NotificationsPage(store: store)),
          _settings(context, 'Currency', Icons.payments_outlined, CurrencySelectionPage(store: store)),
          _settings(context, 'Timezone', Icons.schedule_outlined, TimezoneSelectionPage(store: store)),
          _settings(context, 'City', Icons.location_on_outlined, CitySelectionPage(store: store)),
          GlassCard(
            onTap: () => _clear(context, store),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_sweep_outlined, color: Colors.red),
              title: Text('Clear All Data', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 10),
          _settings(context, 'About Momentum', Icons.info_outline_rounded, AboutPage(store: store)),
        ],
      ),
    );
  }
}

Widget _settings(BuildContext context, String title, IconData icon, Widget page) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GlassCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    ),
  );
}

Future<void> _clear(BuildContext context, Store store) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Clear All Data?'),
      content: const Text('This removes your local Momentum data from this device.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
      ],
    ),
  );
  if (ok == true) {
    await store.clearAll();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MomentumApp(prefs: store.prefs)), (_) => false);
    }
  }
}

class EditProfile extends StatefulWidget {
  final Store store;
  const EditProfile({super.key, required this.store});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late final TextEditingController _name;
  String _currency = 'AFN';
  String _timezone = 'Asia/Kabul';
  String _city = 'Kabul, Afghanistan';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.store.name);
    _currency = widget.store.currency;
    _timezone = widget.store.timezone;
    _city = widget.store.city;
  }

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'Edit Profile',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: const ['AFN', 'USD', 'EUR'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _currency = v ?? 'AFN'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _timezone,
                  decoration: const InputDecoration(labelText: 'Timezone'),
                  items: const ['Asia/Kabul', 'Asia/Dubai', 'Asia/Karachi'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _timezone = v ?? 'Asia/Kabul'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _city,
                  decoration: const InputDecoration(labelText: 'City'),
                  items: const ['Kabul, Afghanistan', 'Herat, Afghanistan', 'Mazar-e-Sharif, Afghanistan', 'Kandahar, Afghanistan'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _city = v ?? 'Kabul, Afghanistan'),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await widget.store.setProfile(
                        name: _name.text.trim(),
                        currency: _currency,
                        currencySymbol: _currency == 'AFN' ? '؋' : _currency == 'USD' ? r'$' : '€',
                        timezone: _timezone,
                        city: _city,
                      );
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppearancePage extends StatefulWidget {
  final Store store;
  const AppearancePage({super.key, required this.store});
  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  ThemeMode mode = ThemeMode.system;
  @override
  void initState() {
    super.initState();
    final s = widget.store.prefs.getString('themeMode');
    mode = s == 'light' ? ThemeMode.light : s == 'dark' ? ThemeMode.dark : ThemeMode.system;
  }

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'Appearance',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                    ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto_outlined)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) async {
                    final next = s.first;
                    setState(() => mode = next);
                    final cb = MomentumThemeBridge.callback;
                    if (cb != null) await cb(next);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Background blur'),
                const SizedBox(height: 6),
                Text('${widget.store.blur.toStringAsFixed(0)} px'),
                Slider(
                  value: widget.store.blur,
                  min: 0,
                  max: 40,
                  onChanged: (v) async {
                    await widget.store.setBlur(v);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

typedef ThemeCallback = Future<void> Function(ThemeMode mode);
class MomentumThemeBridge { static ThemeCallback? callback; }

class WallpaperLibrary extends StatefulWidget {
  final Store store;
  const WallpaperLibrary({super.key, required this.store});
  @override
  State<WallpaperLibrary> createState() => _WallpaperLibraryState();
}

class _WallpaperLibraryState extends State<WallpaperLibrary> {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return MomentumScaffold(
      store: widget.store,
      title: 'Wallpaper Library',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Row(
              children: [
                const Expanded(child: Text('30 coordinated backgrounds')),
                DropdownButton<String>(
                  value: widget.store.wallpaperSource,
                  items: const [
                    DropdownMenuItem(value: 'Default / Offline', child: Text('Default / Offline')),
                    DropdownMenuItem(value: 'Online', child: Text('Online')),
                  ],
                  onChanged: (v) async {
                    if (v != null) {
                      await widget.store.setWallpaperSource(v);
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wallpapers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.25,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, i) {
              final w = wallpapers[i];
              final selected = widget.store.wallpaperIndex == i;
              return GestureDetector(
                onTap: () async {
                  await widget.store.setWallpaper(i);
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: dark ? w.dark : w.light),
                    border: Border.all(
                      color: selected ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: .6),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        children: [
                          Expanded(child: Text('${i + 1}. ${w.name}', style: TextStyle(color: dark ? Colors.white : Colors.black87, fontWeight: FontWeight.w700))),
                          if (selected) Icon(Icons.check_circle, color: dark ? Colors.white : Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          GlassCard(
            onTap: () => _onlineInfo(context),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.cloud_download_outlined),
              title: Text('Check for online update'),
              subtitle: Text('Prepare a new 30-background pack for offline use'),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onlineInfo(BuildContext context) async {
    final connected = await _checkInternet();
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(connected ? 'New backgrounds are available' : 'No internet connection'),
        content: Text(connected ? 'The app is online. The local collection remains available offline; configure an authorized image source before downloading a new pack.' : 'Connect to the internet to check for a new background pack.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  Future<bool> _checkInternet() async {
    final c = HttpClient();
    try {
      final r = await c.getUrl(Uri.parse('https://example.com')).timeout(const Duration(seconds: 5));
      final x = await r.close().timeout(const Duration(seconds: 5));
      return x.statusCode >= 200 && x.statusCode < 500;
    } catch (_) {
      return false;
    } finally {
      c.close(force: true);
    }
  }
}

class WallpaperBlurPage extends StatefulWidget {
  final Store store;
  const WallpaperBlurPage({super.key, required this.store});
  @override
  State<WallpaperBlurPage> createState() => _WallpaperBlurPageState();
}

class _WallpaperBlurPageState extends State<WallpaperBlurPage> {
  late double blur;
  @override
  void initState() { super.initState(); blur = widget.store.blur; }
  @override
  Widget build(BuildContext context) {
    final w = wallpapers[widget.store.wallpaperIndex];
    final colors = Theme.of(context).brightness == Brightness.dark ? w.dark : w.light;
    return MomentumScaffold(
      store: widget.store,
      title: 'Background Preview & Blur',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: colors))),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Blur ${blur.toStringAsFixed(0)} px'),
                Slider(value: blur, min: 0, max: 40, onChanged: (v) async { setState(() => blur = v); await widget.store.setBlur(v); }),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Crisp'), Text('Dreamy')]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppLockPage extends StatefulWidget {
  final Store store;
  const AppLockPage({super.key, required this.store});
  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  Future<void> _toggleLock(bool value) async {
    if (value && !widget.store.hasPin()) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PinSetupPage(store: widget.store)),
      );
      if (!widget.store.hasPin()) return;
    }
    await widget.store.setAppLock(value);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'App Lock',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('App Lock'),
                  subtitle: const Text('Lock Momentum when it is reopened'),
                  value: widget.store.appLockEnabled,
                  onChanged: _toggleLock,
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('PIN'),
                  subtitle: Text(
                    widget.store.hasPin() ? 'PIN is configured' : 'Set a PIN',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PinSetupPage(store: widget.store),
                    ),
                  ).then((_) => setState(() {})),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Biometric Authentication'),
                  subtitle: const Text('Use supported device biometrics'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BiometricPage(store: widget.store),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PinSetupPage extends StatefulWidget {
  final Store store;
  const PinSetupPage({super.key, required this.store});
  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!RegExp(r'^\d{4}$').hasMatch(_pin.text) ||
        _pin.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the same 4-digit PIN twice.')),
      );
      return;
    }
    await widget.store.setPin(_pin.text);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'PIN Setup / Change',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _pin,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'Create PIN'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _confirm,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'Confirm PIN'),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save PIN'),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your PIN is stored as a one-way hash, not as readable text.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BiometricPage extends StatefulWidget {
  final Store store;
  const BiometricPage({super.key, required this.store});
  @override
  State<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool available = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      available = await auth.canCheckBiometrics && await auth.isDeviceSupported();
    } catch (_) {
      available = false;
    }
    if (mounted) setState(() {});
  }

  Future<void> _setBiometric(bool enabled) async {
    if (!enabled) {
      await widget.store.setBiometric(false);
      if (mounted) setState(() {});
      return;
    }

    try {
      final ok = await auth.authenticate(
        localizedReason: 'Verify your identity to enable Biometric Authentication.',
      );
      if (ok) {
        await widget.store.setBiometric(true);
        if (mounted) setState(() {});
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric Authentication is unavailable.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'Biometric Authentication',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.fingerprint_rounded,
                  size: 46,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  available
                      ? 'Biometric authentication is available.'
                      : 'Biometric authentication is not available on this device.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Biometric Authentication'),
                  value: widget.store.biometricEnabled && available,
                  onChanged: available ? _setBiometric : null,
                ),
                const SizedBox(height: 6),
                const Text('PIN remains the fallback method.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  final Store store;
  const NotificationsPage({super.key, required this.store});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool master = true;
  bool prayer = true;
  bool tasks = true;
  bool routine = true;
  String prayerTiming = 'At prayer time';

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'Notifications Settings',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Master Notifications'),
                  value: master,
                  onChanged: (v) => setState(() => master = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Prayer Notifications'),
                  value: prayer,
                  onChanged: master ? (v) => setState(() => prayer = v) : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Task Reminders'),
                  value: tasks,
                  onChanged: master ? (v) => setState(() => tasks = v) : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Routine Reminders'),
                  value: routine,
                  onChanged: master ? (v) => setState(() => routine = v) : null,
                ),
                const Divider(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Prayer timing',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: prayerTiming,
                  decoration: const InputDecoration(labelText: 'Prayer alert'),
                  items: const [
                    'At prayer time',
                    '5 minutes before',
                    '10 minutes before',
                    '15 minutes before',
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: master && prayer
                      ? (v) => setState(() => prayerTiming = v ?? prayerTiming)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencySelectionPage extends StatelessWidget {
  final Store store;
  const CurrencySelectionPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) => _SelectionPage(
        store: store,
        title: 'Currency Selection',
        items: const [
          ('AFN', '؋'),
          ('USD', r'\$'),
          ('EUR', '€'),
        ],
        selected: store.currency,
        onPick: (value) => store.setProfile(
          currency: value.$1,
          currencySymbol: value.$2,
        ),
      );
}

class TimezoneSelectionPage extends StatelessWidget {
  final Store store;
  const TimezoneSelectionPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) => _SelectionPage(
        store: store,
        title: 'Timezone Selection',
        items: const [
          ('Asia/Kabul', 'UTC+4:30'),
          ('Asia/Dubai', 'UTC+4:00'),
          ('Asia/Karachi', 'UTC+5:00'),
        ],
        selected: store.timezone,
        onPick: (value) => store.setProfile(timezone: value.$1),
      );
}

class CitySelectionPage extends StatelessWidget {
  final Store store;
  const CitySelectionPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) => _SelectionPage(
        store: store,
        title: 'City Selection',
        items: const [
          ('Kabul, Afghanistan', 'Afghanistan'),
          ('Herat, Afghanistan', 'Afghanistan'),
          ('Mazar-e-Sharif, Afghanistan', 'Afghanistan'),
          ('Kandahar, Afghanistan', 'Afghanistan'),
        ],
        selected: store.city,
        onPick: (value) => store.setProfile(city: value.$1),
      );
}

class _SelectionPage extends StatefulWidget {
  final Store store;
  final String title;
  final List<(String, String)> items;
  final String selected;
  final Future<void> Function((String, String)) onPick;

  const _SelectionPage({
    required this.store,
    required this.title,
    required this.items,
    required this.selected,
    required this.onPick,
  });

  @override
  State<_SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<_SelectionPage> {
  late String selected;
  String query = '';

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((e) => e.$1.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return MomentumScaffold(
      store: widget.store,
      title: widget.title,
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          ...filtered.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                onTap: () async {
                  setState(() => selected = e.$1);
                  await widget.onPick(e);
                  if (mounted) Navigator.pop(context);
                },
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    e.$1,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(e.$2),
                  trailing: selected == e.$1
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  final Store store;
  const AboutPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: store,
      title: 'About Momentum',
      showBack: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: .12),
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 38,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Momentum',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text('Created by Milad Wardak'),
                const SizedBox(height: 4),
                const Text(
                  'Personal productivity, finance, routine and spiritual tools.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                const Text('Version 1.0.0'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppUnlockPage extends StatefulWidget {
  final Store store;
  const AppUnlockPage({super.key, required this.store});
  @override
  State<AppUnlockPage> createState() => _AppUnlockPageState();
}

class _AppUnlockPageState extends State<AppUnlockPage> {
  final _pin = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _tryBio();
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _tryBio() async {
    if (!widget.store.biometricEnabled) return;
    try {
      final ok = await auth.authenticate(localizedReason: 'Unlock Momentum');
      if (ok && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeDashboard(store: widget.store)),
        );
      }
    } catch (_) {}
  }

  void _submit() {
    if (widget.store.verifyPin(_pin.text)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeDashboard(store: widget.store)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackdrop(
        store: widget.store,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Unlock Momentum',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _pin,
                    obscureText: true,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(labelText: 'PIN'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Unlock'),
                    ),
                  ),
                  if (widget.store.biometricEnabled)
                    TextButton.icon(
                      onPressed: _tryBio,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: const Text('Use Biometric Authentication'),
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

String _fmtDate(String? value){if(value==null||value.isEmpty)return '';final d=DateTime.tryParse(value);if(d==null)return '';return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';}
const _months=['January','February','March','April','May','June','July','August','September','October','November','December'];
const _hijriMonths=['Muharram','Safar','Rabi al-Awwal','Rabi al-Thani','Jumada al-Awwal','Jumada al-Thani','Rajab','Sha’ban','Ramadan','Shawwal','Dhu al-Qadah','Dhu al-Hijjah'];
const _jalaliMonths=['Farvardin','Ordibehesht','Khordad','Tir','Mordad','Shahrivar','Mehr','Aban','Azar','Dey','Bahman','Esfand'];
DateTime _addDays(DateTime d,int n)=>DateTime(d.year,d.month,d.day+n);
List<int> _gregorianToHijri(DateTime date){final y=date.year,m=date.month,d=date.day;final jd=(367*y-(7*(y+(m+9)~/12))~/4+(275*m)~/9+d+1721013.5).floor();var l=jd-1948440+10632;final n=((l-1)/10631).floor();l=l-10631*n+354;final j=(((10985-l)/5316).floor()*((50*l/17719).floor())+(l/5670).floor()*((43*l/15238).floor()));l=l-((30-j)/15).floor()*((17719*j)/50).floor()-((j/16).floor())*((15238*j)/43).floor()+29;final mm=((24*l)/709).floor();final dd=l-((709*mm)/24).floor();final yy=30*n+j-30;return [yy,mm,dd];}
List<int> _gregorianToJalali(DateTime date){final gy=date.year;final gm=date.month;final gd=date.day;final gDayNo=365*gy+(gy+3)~/4-(gy+99)~/100+(gy+399)~/400;final gMonthDays=List<int>.from([0,31,59,90,120,151,181,212,243,273,304,334,365]);int gdn=gDayNo+gMonthDays[gm-1]+gd; if(gm>2&&((gy%4==0&&gy%100!=0)||(gy%400==0)))gdn++;int jDayNo=gdn-79;int jNp=jDayNo~/12053;int jy=979+33*jNp;jDayNo%=12053;jy+=4*(jDayNo~/1461);jDayNo%=1461;if(jDayNo>=366){jy+=(jDayNo-1)~/365;jDayNo=(jDayNo-1)%365;}int jm,jd;if(jDayNo<186){jm=1+jDayNo~/31;jd=1+jDayNo%31;}else{jm=7+(jDayNo-186)~/30;jd=1+(jDayNo-186)%30;}return [jy,jm,jd];}

// ============================================================================
// End of Momentum rebuild
// ============================================================================
