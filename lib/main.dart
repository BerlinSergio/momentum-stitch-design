import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/chrome.dart';
import 'ui/glass.dart';
import 'ui/symbols.dart';
import 'ui/tokens.dart';
import 'ui/widgets.dart';

// ============================================================================
// MOMENTUM — Stitch-faithful UI on top of the original single-file logic.
// Visual source of truth: Stitch HTML references + Design System v2.1.
// Business logic (Store, CRUD, prayer, calendars, PIN, biometrics, wallpaper
// state) is preserved unchanged from the original implementation.
// ============================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MomentumApp(prefs: prefs));
}

// ============================================================================
// STORE — persistence & security (UNCHANGED LOGIC)
// ============================================================================

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

// ============================================================================
// APP ROOT
// ============================================================================

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

  @override
  Widget build(BuildContext context) {
    MomentumThemeBridge.callback = setTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Momentum',
      themeMode: _themeMode,
      theme: buildMomentumTheme(Brightness.light),
      darkTheme: buildMomentumTheme(Brightness.dark),
      home: SplashScreen(store: store, setTheme: setTheme),
    );
  }
}

typedef ThemeCallback = Future<void> Function(ThemeMode mode);

class MomentumThemeBridge {
  static ThemeCallback? callback;
}

// ============================================================================
// SCAFFOLD SHELL — atmospheric backdrop + pinned chrome + floating dock
// ============================================================================

class MomentumScaffold extends StatelessWidget {
  final Store store;
  final String title;
  final Widget body;
  final bool showBottomNav;
  final bool showBack;
  final int activeTab;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const MomentumScaffold({
    super.key,
    required this.store,
    required this.title,
    required this.body,
    this.showBottomNav = false,
    this.showBack = false,
    this.activeTab = 0,
    this.onBack,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final hasHeader = showBottomNav || title.isNotEmpty || showBack;
    return MomentumBackdrop(
      wallpaperIndex: store.wallpaperIndex,
      wallpaperBlur: store.blur,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(child: body),
            if (hasHeader)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: showBottomNav
                    ? MomentumHeaderBar(
                        title: title,
                        avatarInitial: store.name.trim().isEmpty ? 'U' : store.name.trim()[0].toUpperCase(),
                        onBellTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage(store: store))),
                        onAvatarTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsProfile(store: store))),
                      )
                    : SubPageBar(
                        title: title,
                        onBack: showBack ? (onBack ?? () => Navigator.pop(context)) : null,
                        actions: actions,
                      ),
              ),
          ],
        ),
        bottomNavigationBar: showBottomNav ? MainBottomNav(store: store, activeTab: activeTab) : null,
      ),
    );
  }
}

class MainBottomNav extends StatelessWidget {
  final Store store;
  final int activeTab;
  const MainBottomNav({super.key, required this.store, required this.activeTab});

  void _go(BuildContext context, int index) {
    if (index == activeTab) return;
    final page = switch (index) {
      0 => HomeDashboard(store: store),
      1 => ExpenseTracker(store: store),
      3 => TasksReminders(store: store),
      4 => MorePage(store: store),
      _ => HomeDashboard(store: store),
    };
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return MomentumDock(
      activeTab: activeTab,
      onTab: (i) => _go(context, i),
      onCenter: () => showAddSheet(context, store),
    );
  }
}

// ============================================================================
// QUICK ADD SHEET (center `+` trigger)
// ============================================================================

Future<void> showAddSheet(BuildContext context, Store store) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      final p = Pal.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: GlassCard(
            tier: GlassTier.elevated,
            borderRadius: BorderRadius.circular(MomentumTokens.radiusLg),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: p.textTertiary.withValues(alpha: .35), borderRadius: BorderRadius.circular(999)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconBubble(MSym.add, size: 30, gradient: p.primaryGradient),
                    const SizedBox(width: 9),
                    Text('Quick Add', style: Theme.of(sheetContext).textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: 12),
                _sheetAction(sheetContext, MSym.addCard, 'Add Expense', 'Record spending', p.primary,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditExpensePage(store: store)))),
                _sheetAction(sheetContext, MSym.payments, 'Add Income', 'Record money received', p.tertiary,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditIncomePage(store: store)))),
                _sheetAction(sheetContext, MSym.addTask, 'Add Task', 'Create a task or reminder', p.secondary,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskPage(store: store)))),
                _sheetAction(sheetContext, MSym.eventRepeat, 'Add Routine', 'Create a routine item', p.primary,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditRoutinePage(store: store)))),
                _sheetAction(sheetContext, MSym.noteAdd, 'Quick Note', 'Capture an idea', p.secondary,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNoteEditor(store: store)))),
                _sheetAction(sheetContext, MSym.editNote, 'Long Note', 'Write a detailed note', p.tertiary,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => LongNoteEditor(store: store)))),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _sheetAction(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback action) {
  return MomentumRow(
    icon: icon,
    iconColor: color,
    title: title,
    subtitle: subtitle,
    onTap: () {
      Navigator.pop(context);
      action();
    },
  );
}

// ============================================================================
// SPLASH — glow-ring brand seal over atmospheric orbs
// ============================================================================

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
    final p = Pal.of(context);
    return MomentumBackdrop(
      wallpaperIndex: widget.store.wallpaperIndex,
      wallpaperBlur: widget.store.blur,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Brand seal with ambient glow + glass ring.
              SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GlassOrb(size: 190, color: p.primary.withValues(alpha: .28), sigma: 46),
                    Container(
                      width: 118,
                      height: 118,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(38),
                        color: Colors.white.withValues(alpha: p.dark ? .10 : .55),
                        border: Border.all(color: Colors.white.withValues(alpha: p.dark ? .18 : .85)),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(33),
                          gradient: p.triGradientDiagonal,
                          boxShadow: p.fabGlow,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -22,
                              right: -22,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .30)),
                              ),
                            ),
                            const Center(child: Icon(MSym.bolt, size: 52, color: Colors.white, fill: 1)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'MOMENTUM',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 5.8,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: Text(
                  'Spiritual tools, mindful finance & daily routines',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, height: 1.5, fontWeight: FontWeight.w500, color: p.textSecondary),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _splashPill(context, 'Focus'),
                  _dot(context),
                  _splashPill(context, 'Barakah'),
                  _dot(context),
                  _splashPill(context, 'Growth'),
                ],
              ),
              const Spacer(flex: 4),
              // Status capsule.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: GlassCard(
                  tier: GlassTier.subtle,
                  borderRadius: BorderRadius.circular(18),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: p.primaryGradient),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Aligning your day',
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: p.textPrimary)),
                                Text('98%',
                                    style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, fontWeight: FontWeight.w700, color: p.accentText)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const GradientProgressBar(value: .98, height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'v1.0.0  •  Crafted for intentional living',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: .5, color: p.textTertiary),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _splashPill(BuildContext context, String label) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: p.dark ? .08 : .70),
        border: Border.all(color: Colors.white.withValues(alpha: p.dark ? .12 : .85)),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: p.accentText)),
    );
  }

  Widget _dot(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('•', style: TextStyle(color: Pal.of(context).textTertiary.withValues(alpha: .5), fontSize: 11)),
      );
}

// ============================================================================
// PERSONAL SETUP (first launch)
// ============================================================================

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
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name.')));
      return;
    }
    await widget.store.setProfile(
        name: _name.text.trim(),
        currency: _currency,
        currencySymbol: _currency == 'AFN' ? '؋' : _currency == 'USD' ? r'$' : _currency == 'EUR' ? '€' : _currency,
        timezone: _timezone,
        city: _city);
    await widget.store.prefs.setBool('setupCompleted', true);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeDashboard(store: widget.store)));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: 'Personal Setup',
      body: ListView(
        padding: pagePadding(context),
        children: [
          const SizedBox(height: 6),
          const Overline('Local-first • No account needed'),
          const SizedBox(height: 6),
          Text('Welcome to Momentum', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text('Set up your personal space once. Everything stays on this device.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            child: Column(
              children: [
                TextField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(MSym.person, size: 20)),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: const InputDecoration(labelText: 'Currency', prefixIcon: Icon(MSym.payments, size: 20)),
                  items: const [
                    DropdownMenuItem(value: 'AFN', child: Text('AFN / ؋')),
                    DropdownMenuItem(value: 'USD', child: Text('USD / \$')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR / €')),
                  ],
                  onChanged: (v) => setState(() => _currency = v ?? 'AFN'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _timezone,
                  decoration: const InputDecoration(labelText: 'Timezone', prefixIcon: Icon(MSym.schedule, size: 20)),
                  items: const [
                    DropdownMenuItem(value: 'Asia/Kabul', child: Text('Asia/Kabul')),
                    DropdownMenuItem(value: 'Asia/Dubai', child: Text('Asia/Dubai')),
                    DropdownMenuItem(value: 'Asia/Karachi', child: Text('Asia/Karachi')),
                  ],
                  onChanged: (v) => setState(() => _timezone = v ?? 'Asia/Kabul'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _city,
                  decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(MSym.locationOn, size: 20)),
                  items: const [
                    DropdownMenuItem(value: 'Kabul, Afghanistan', child: Text('Kabul, Afghanistan')),
                    DropdownMenuItem(value: 'Herat, Afghanistan', child: Text('Herat, Afghanistan')),
                    DropdownMenuItem(value: 'Mazar-e-Sharif, Afghanistan', child: Text('Mazar-e-Sharif, Afghanistan')),
                    DropdownMenuItem(value: 'Kandahar, Afghanistan', child: Text('Kandahar, Afghanistan')),
                  ],
                  onChanged: (v) => setState(() => _city = v ?? 'Kabul, Afghanistan'),
                ),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: GradientButton(label: 'Continue', onPressed: _save)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HOME DASHBOARD — pinned header, greeting, Financial Health bento,
// quick actions, Routine & Prayer card, Today's Tasks, mindful streak.
// ============================================================================

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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  double _sum(List<Map<String, dynamic>> list) => list.fold<double>(0, (s, e) => s + ((e['amount'] ?? 0) as num).toDouble());

  String _money(double n) => '${widget.store.currencySymbol}${n.toStringAsFixed(0)}';

  String _dateText() {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  String _monthLabel() {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[DateTime.now().month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final income = _sum(incomes);
    final expense = _sum(expenses);
    final saved = income - expense;
    final saveRate = income <= 0 ? 0.0 : (saved / income).clamp(0.0, 1.0).toDouble();
    final initials = widget.store.name.trim().isEmpty ? 'U' : widget.store.name.trim()[0].toUpperCase();

    return MomentumScaffold(
      store: widget.store,
      title: 'Home',
      showBottomNav: true,
      activeTab: 0,
      body: ListView(
        padding: pagePadding(context, dock: true),
        children: [
          // --- Greeting & profile block -----------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
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
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('👋', style: TextStyle(fontSize: 19)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text('Stay consistent. Small steps every day.', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 5),
                      Overline(_dateText()),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Avatar with ambient aura ring.
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GlassOrb(size: 56, color: p.primary.withValues(alpha: .35), sigma: 8),
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: p.triGradientDiagonal),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.dark ? const Color(0xFF242A36) : Colors.white,
                          ),
                          child: Center(
                            child: Text(initials,
                                style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 18, fontWeight: FontWeight.w700, color: p.accentText)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // --- Financial Health bento --------------------------------------
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, size: 176, color: p.orb1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBubble(MSym.accountBalanceWallet, size: 32, iconSize: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Financial Health', style: Theme.of(context).textTheme.titleMedium)),
                    StatusPill(_monthLabel()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MetricColumn(
                        label: 'Income',
                        value: _money(income),
                        footerIcon: MSym.trendingUp,
                        footerText: income > 0 ? '+8.4%' : '—',
                        footerColor: p.success,
                      ),
                    ),
                    const MetricDivider(),
                    Expanded(
                      child: MetricColumn(
                        label: 'Expenses',
                        value: _money(expense),
                        footerIcon: MSym.checkCircle,
                        footerText: expense <= income ? 'Safe limit' : 'Review',
                        footerColor: expense <= income ? p.textSecondary : p.warning,
                      ),
                    ),
                    const MetricDivider(),
                    Expanded(
                      child: MetricColumn(
                        label: 'Saved',
                        value: '+${_money(saved)}',
                        valueColor: p.accentText,
                        footerIcon: MSym.savings,
                        footerText: '${(saveRate * 100).toStringAsFixed(1)}%',
                        footerColor: p.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Savings Target (${_money(3000)})',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: p.textSecondary)),
                    Text('${(saveRate * 100).toStringAsFixed(1)}%',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: p.accentText)),
                  ],
                ),
                const SizedBox(height: 6),
                GradientProgressBar(value: saveRate),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // --- Quick actions (4 tiles) -------------------------------------
          Row(
            children: [
              Expanded(child: _quick(context, MSym.addCard, 'Log Cost', p.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditExpensePage(store: widget.store))).then((_) => setState(() {})))),
              const SizedBox(width: 10),
              Expanded(child: _quick(context, MSym.addTask, 'Add Task', p.secondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskPage(store: widget.store))).then((_) => setState(() {})))),
              const SizedBox(width: 10),
              Expanded(child: _quick(context, MSym.bedtime, 'Prayers', p.tertiary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrayerTimesPage(store: widget.store))))),
              const SizedBox(width: 10),
              Expanded(child: _quick(context, MSym.selfImprovement, 'Reflect', p.textSecondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNoteEditor(store: widget.store))))),
            ],
          ),
          const SizedBox(height: 12),

          // --- Routine & Prayer card ---------------------------------------
          GlassCard.hero(
            mosqueWatermark: true,
            glow: null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBubble(MSym.sync, size: 32, iconSize: 18, color: p.secondary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Routine & Prayer', style: Theme.of(context).textTheme.titleMedium)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DailyRoutine(store: widget.store))).then((_) => setState(() {})),
                      child: Text('Edit', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: p.accentText)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Next prayer countdown banner.
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MomentumTokens.radiusMd),
                    gradient: LinearGradient(colors: [
                      p.primary.withValues(alpha: p.dark ? .26 : .16),
                      p.secondary.withValues(alpha: p.dark ? .14 : .09),
                      p.tertiary.withValues(alpha: p.dark ? .10 : .07),
                    ]),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.dark ? const Color(0xFF242A36) : Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Icon(MSym.lightMode, size: 20, color: p.accentText, fill: 1),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Next: Dhuhr in 1h 45m',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w500, color: p.textSecondary)),
                            const SizedBox(height: 2),
                            Text('1:05 PM',
                                style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 17, fontWeight: FontWeight.w700, color: p.textPrimary)),
                          ],
                        ),
                      ),
                      const StatusPill('Upcoming', solid: true),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _prayerTimeline(context),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // --- Today's Tasks -----------------------------------------------
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topLeft, size: 150, color: p.orb2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBubble(MSym.checklist, size: 32, iconSize: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text("Today's Tasks", style: Theme.of(context).textTheme.titleMedium)),
                    ActionPill(
                      label: 'Add Task',
                      icon: MSym.add,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskPage(store: widget.store))).then((_) => setState(() {})),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (tasks.isEmpty)
                  const Padding(padding: EdgeInsets.all(10), child: EmptyState(title: 'No tasks yet', action: 'Add your first task'))
                else
                  ...tasks.take(3).map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskTile(store: widget.store, task: task, onChanged: () => setState(() {})),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // --- Mindful streak banner ---------------------------------------
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNoteEditor(store: widget.store))),
            child: Row(
              children: [
                IconBubble(MSym.spa, size: 40, color: p.tertiary),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mindful Streak: 14 Days', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text('Peace comes from within. Do not seek it without.',
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quick(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final p = Pal.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      tier: GlassTier.base,
      onTap: onTap,
      child: Column(
        children: [
          IconBubble(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, height: 1.1, fontWeight: FontWeight.w500, color: p.textPrimary)),
        ],
      ),
    );
  }

  Widget _prayerTimeline(BuildContext context) {
    final p = Pal.of(context);
    const prayers = [('Fajr', '5:12 A'), ('Dhuhr', '1:05 P'), ('Asr', '4:28 P'), ('Magh', '6:42 P'), ('Isha', '8:05 P')];
    return Row(
      children: prayers.asMap().entries.map((entry) {
        final i = entry.key;
        final pr = entry.value;
        final active = i == 1;
        final done = i == 0;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == prayers.length - 1 ? 0 : 5),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: active
                  ? p.primary.withValues(alpha: p.dark ? .26 : .12)
                  : p.cardSubtle.withValues(alpha: done ? .70 : .40),
            ),
            child: Column(
              children: [
                Text(pr.$1,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? p.accentText : p.textSecondary)),
                const SizedBox(height: 4),
                Text(pr.$2,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: active ? p.accentText : (done ? p.textPrimary : p.textSecondary))),
                const SizedBox(height: 6),
                Container(
                  width: active || done ? 20 : 16,
                  height: active || done ? 20 : 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? p.successSurface
                        : active
                            ? p.primary
                            : p.textPrimary.withValues(alpha: .08),
                    boxShadow: active ? [BoxShadow(color: p.primary.withValues(alpha: .4), blurRadius: 8)] : null,
                  ),
                  child: done
                      ? Icon(MSym.check, size: 13, color: p.success, weight: 700)
                      : active
                          ? const Icon(MSym.alarm, size: 12, color: Colors.white)
                          : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// SHARED TILES
// ============================================================================

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;
  const SectionTitle({super.key, required this.title, this.action, this.onTap});
  @override
  Widget build(BuildContext context) => SectionHeader(title, trailing: action, onTrailingTap: onTap);
}

/// Task row — circular check (Stitch), strikethrough when done.
/// Persistence logic unchanged.
class TaskTile extends StatelessWidget {
  final Store store;
  final Map<String, dynamic> task;
  final VoidCallback onChanged;
  final bool showChevron;
  const TaskTile({super.key, required this.store, required this.task, required this.onChanged, this.showChevron = false});

  Future<void> _toggle(bool v) async {
    final items = store.getList('tasks');
    final i = items.indexWhere((e) => e['id'] == task['id']);
    if (i >= 0) {
      items[i]['done'] = v;
      await store.saveList('tasks', items);
      onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final done = task['done'] == true;
    return InsetRow(
      onTap: () => _toggle(!done),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      color: p.cardSubtle.withValues(alpha: .55),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? p.primary : p.textPrimary.withValues(alpha: p.dark ? .14 : .08),
              boxShadow: done ? [BoxShadow(color: p.primary.withValues(alpha: .35), blurRadius: 6)] : null,
            ),
            child: done ? const Icon(MSym.check, size: 14, color: Colors.white, weight: 700) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? 'Task',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: p.textPrimary.withValues(alpha: done ? .55 : 1),
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: p.textSecondary,
                  ),
                ),
                if ((task['priority'] ?? '') != '' && task['priority'] != 'Normal') ...[
                  const SizedBox(height: 2),
                  Text('${task['priority']} priority', style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          Icon(MSym.schedule, size: 14, color: p.textTertiary),
          const SizedBox(width: 4),
          Text('${task['time'] ?? ''}', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: p.textTertiary)),
          if (showChevron) ...[
            const SizedBox(width: 6),
            Icon(MSym.chevronRight, size: 18, color: p.textTertiary),
          ],
        ],
      ),
    );
  }
}

class RoutineTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const RoutineTile({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(
      children: [
        IconBubble(MSym.eventRepeat, size: 40, color: p.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['title'] ?? 'Routine', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              Text('${item['time'] ?? ''} • ${item['repeat'] ?? 'Every Day'}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
      ],
    );
  }
}

class PrayerPreviewCard extends StatelessWidget {
  const PrayerPreviewCard({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GlassCard(
      child: Row(
        children: [
          IconBubble(MSym.mosque, size: 40, color: p.tertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next Prayer', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text('Open Prayer Times to load today’s schedule', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
        ],
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const QuickAction({super.key, required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            IconBubble(icon, size: 40),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      );
}

class EmptyState extends StatelessWidget {
  final String title;
  final String action;
  const EmptyState({super.key, required this.title, required this.action});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(
      children: [
        IconBubble(MSym.notes, size: 52, iconSize: 26, color: p.textTertiary),
        const SizedBox(height: 10),
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 3),
        Text(action, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ============================================================================
// FINANCE — Expense Tracker, Add/Edit Expense, Income Management, Add/Edit Income
// ============================================================================

IconData _categoryIcon(String c) => switch (c) {
      'Food' => MSym.restaurant,
      'Transportation' => MSym.directionsBus,
      'Shopping' => MSym.shoppingBag,
      'Bills' => MSym.receiptLong,
      'Rent' => MSym.apartment,
      'Health' => MSym.medicalServices,
      'Education' => MSym.school,
      'Entertainment' => MSym.movie,
      'Family' => MSym.diversity1,
      'Work' => MSym.work,
      _ => MSym.category,
    };

IconData _sourceIcon(String s) => switch (s) {
      'Salary' => MSym.paid,
      'Freelance' => MSym.stylus,
      'Business' => MSym.businessCenter,
      'Bonus' => MSym.redeem,
      _ => MSym.payments,
    };

String _dayGroupLabel(String? iso) {
  final d = DateTime.tryParse(iso ?? '');
  if (d == null) return 'Earlier';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(d.year, d.month, d.day);
  final diff = today.difference(that).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[d.month - 1]} ${d.day}${d.year != now.year ? ', ${d.year}' : ''}';
}

class ExpenseTracker extends StatefulWidget {
  final Store store;
  const ExpenseTracker({super.key, required this.store});
  @override
  State<ExpenseTracker> createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  String _query = '';
  String _category = 'All';
  final categories = const ['All', 'Food', 'Transportation', 'Shopping', 'Bills', 'Rent', 'Health', 'Education', 'Entertainment', 'Family', 'Work', 'Other'];

  List<Map<String, dynamic>> get _items => widget.store.getList('expenses');
  double _total(List<Map<String, dynamic>> items) => items.fold(0, (s, e) => s + ((e['amount'] ?? 0) as num).toDouble());

  String _monthLabel() {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[DateTime.now().month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final list = _items.where((e) {
      final c = _category == 'All' || e['category'] == _category;
      final q = _query.isEmpty || '${e['category']} ${e['note']}'.toLowerCase().contains(_query.toLowerCase());
      return c && q;
    }).toList();
    final income = widget.store.getList('incomes').fold<double>(0, (s, e) => s + ((e['amount'] ?? 0) as num).toDouble());
    final total = _total(_items);
    final budgetLeft = income - total;

    // Day-grouped view of the filtered list (presentation only).
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final e in list) {
      groups.putIfAbsent(_dayGroupLabel(e['date']?.toString()), () => []).add(e);
    }

    return MomentumScaffold(
      store: widget.store,
      title: 'Finance',
      showBottomNav: true,
      activeTab: 1,
      body: ListView(
        padding: pagePadding(context, dock: true),
        children: [
          // --- Summary hero -------------------------------------------------
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Overline('Total Expenses • ${_monthLabel()}')),
                    StatusPill(widget.store.currency, icon: MSym.paid),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${widget.store.currencySymbol}${total.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 4),
                Text(
                  budgetLeft >= 0
                      ? 'A calm pace — ${widget.store.currencySymbol}${budgetLeft.toStringAsFixed(0)} of income still unspent.'
                      : 'Spending has passed recorded income. Review below.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: MetricColumn(
                        label: 'Entries',
                        value: '${_items.length}',
                        footerIcon: MSym.receiptLong,
                        footerText: 'records',
                      ),
                    ),
                    const MetricDivider(),
                    Expanded(
                      child: MetricColumn(
                        label: 'Income',
                        value: '${widget.store.currencySymbol}${income.toStringAsFixed(0)}',
                        footerIcon: MSym.trendingUp,
                        footerText: 'this month',
                        footerColor: p.success,
                      ),
                    ),
                    const MetricDivider(),
                    Expanded(
                      child: MetricColumn(
                        label: 'Balance',
                        value: '${widget.store.currencySymbol}${budgetLeft.toStringAsFixed(0)}',
                        valueColor: budgetLeft >= 0 ? p.accentText : p.danger,
                        footerIcon: MSym.savings,
                        footerText: budgetLeft >= 0 ? 'on track' : 'over',
                        footerColor: budgetLeft >= 0 ? p.secondary : p.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Budget used',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: p.textSecondary)),
                    Text(income > 0 ? '${((total / income) * 100).clamp(0, 999).toStringAsFixed(0)}%' : '—',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: p.accentText)),
                  ],
                ),
                const SizedBox(height: 6),
                GradientProgressBar(value: income > 0 ? (total / income).clamp(0.0, 1.0) : 0),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // --- Category carousel --------------------------------------------
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final c = categories[i];
                return MChoicePill(
                  label: c,
                  icon: c == 'All' ? MSym.filterList : _categoryIcon(c),
                  selected: _category == c,
                  onTap: () => setState(() => _category = c),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 8),
            ),
          ),
          const SizedBox(height: 12),

          // --- Search + add row ----------------------------------------------
          Row(
            children: [
              Expanded(child: MSearchField(hint: 'Search expenses', onChanged: (v) => setState(() => _query = v))),
              const SizedBox(width: 10),
              ActionPill(
                label: 'Add',
                icon: MSym.add,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditExpensePage(store: widget.store))).then((_) => setState(() {})),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Day-grouped transactions --------------------------------------
          if (list.isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(28),
              child: EmptyState(title: 'No expenses', action: 'Add your first expense'),
            )
          else
            ...groups.entries.expand((g) => [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
                    child: Overline(g.key, color: p.textTertiary),
                  ),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Column(
                      children: [
                        for (var i = 0; i < g.value.length; i++) ...[
                          _expenseRow(g.value[i]),
                          if (i != g.value.length - 1) Divider(color: p.divider, height: 1),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ]),
        ],
      ),
    );
  }

  Widget _expenseRow(Map<String, dynamic> e) {
    final p = Pal.of(context);
    final amount = (e['amount'] ?? 0) as num;
    final category = e['category']?.toString() ?? 'Other';
    return MomentumRow(
      icon: _categoryIcon(category),
      iconColor: p.primary,
      title: category,
      subtitle: (e['note'] ?? '').toString().isEmpty ? _fmtDate(e['date']) : e['note'],
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('-${widget.store.currencySymbol}${amount.toStringAsFixed(0)}',
              style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 15, fontWeight: FontWeight.w700, color: p.danger)),
          const SizedBox(height: 2),
          Text(_fmtDate(e['date']), style: TextStyle(fontFamily: 'Inter', fontSize: 10.5, color: p.textTertiary)),
        ],
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditExpensePage(store: widget.store, existing: e))).then((_) => setState(() {})),
    );
  }
}

class AddEditExpensePage extends StatefulWidget {
  final Store store;
  final Map<String, dynamic>? existing;
  const AddEditExpensePage({super.key, required this.store, this.existing});
  @override
  State<AddEditExpensePage> createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends State<AddEditExpensePage> {
  late TextEditingController _amount;
  late TextEditingController _note;
  String _category = 'Food';
  DateTime _date = DateTime.now();
  final cats = const ['Food', 'Transportation', 'Shopping', 'Bills', 'Rent', 'Health', 'Education', 'Entertainment', 'Family', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amount = TextEditingController(text: e == null ? '' : (e['amount'] ?? '').toString());
    _note = TextEditingController(text: e?['note']?.toString() ?? '');
    _category = e?['category']?.toString() ?? 'Food';
    if (e?['date'] != null) {
      _date = DateTime.tryParse(e!['date'].toString()) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final a = double.tryParse(_amount.text.trim());
    if (a == null || a <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount.')));
      return;
    }
    final items = widget.store.getList('expenses');
    final obj = {
      'id': widget.existing?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      'amount': a,
      'category': _category,
      'note': _note.text.trim(),
      'date': _date.toIso8601String(),
    };
    final i = items.indexWhere((e) => e['id'] == obj['id']);
    if (i >= 0) {
      items[i] = obj;
    } else {
      items.insert(0, obj);
    }
    await widget.store.saveList('expenses', items);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: _date);
    if (d != null) setState(() => _date = d);
  }

  Future<void> _delete() async {
    final items = widget.store.getList('expenses');
    items.removeWhere((e) => e['id'] == widget.existing?['id']);
    await widget.store.saveList('expenses', items);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: widget.existing == null ? 'Add Expense' : 'Edit Expense',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          // Amount hero input.
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            child: Column(
              children: [
                Overline('Amount • ${widget.store.currency}', color: p.textTertiary),
                const SizedBox(height: 6),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 34, fontWeight: FontWeight.w700, color: p.textPrimary),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 34, fontWeight: FontWeight.w700, color: p.textTertiary.withValues(alpha: .5)),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixText: '${widget.store.currencySymbol} ',
                    prefixStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 26, fontWeight: FontWeight.w700, color: p.accentText),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Category'),
          GlassCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cats
                  .map((c) => MChoicePill(
                        label: c,
                        icon: _categoryIcon(c),
                        selected: _category == c,
                        onTap: () => setState(() => _category = c),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Details'),
          GlassCard(
            child: Column(
              children: [
                MomentumRow(
                  icon: MSym.calendarToday,
                  title: 'Date',
                  subtitle: _fmtDate(_date.toIso8601String()),
                  trailing: TextButton(onPressed: _pickDate, child: const Text('Change')),
                ),
                Divider(color: p.divider, height: 1),
                const SizedBox(height: 12),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Note', alignLabelWithHint: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(label: widget.existing == null ? 'Save Expense' : 'Save Changes', icon: MSym.check, onPressed: _save),
          if (widget.existing != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _delete,
              style: OutlinedButton.styleFrom(foregroundColor: p.danger, side: BorderSide(color: p.dangerBorder.withValues(alpha: .5))),
              icon: const Icon(MSym.delete, size: 18),
              label: const Text('Delete Expense'),
            ),
          ],
        ],
      ),
    );
  }
}

class IncomeManagement extends StatefulWidget {
  final Store store;
  const IncomeManagement({super.key, required this.store});
  @override
  State<IncomeManagement> createState() => _IncomeManagementState();
}

class _IncomeManagementState extends State<IncomeManagement> {
  final sources = const ['Salary', 'Freelance', 'Business', 'Bonus', 'Other'];
  String _query = '';

  List<Map<String, dynamic>> get _items => widget.store.getList('incomes');
  double _sum() => _items.fold(0, (s, e) => s + ((e['amount'] ?? 0) as num).toDouble());

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final list = _items.where((e) => _query.isEmpty || '${e['source']} ${e['note']}'.toLowerCase().contains(_query.toLowerCase())).toList();
    return MomentumScaffold(
      store: widget.store,
      title: 'Income Management',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Overline('Total Income')),
                    StatusPill('${_items.length} sources', color: p.tertiary),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${widget.store.currencySymbol}${_sum().toStringAsFixed(0)}', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'Add Income',
                    icon: MSym.add,
                    height: 46,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditIncomePage(store: widget.store))).then((_) => setState(() {})),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          MSearchField(hint: 'Search income', onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: 14),
          if (list.isEmpty)
            const GlassCard(padding: EdgeInsets.all(28), child: EmptyState(title: 'No income records', action: 'Add your first income'))
          else
            ...list.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditIncomePage(store: widget.store, existing: e))).then((_) => setState(() {})),
                    child: MomentumRow(
                      icon: _sourceIcon(e['source']?.toString() ?? 'Other'),
                      iconColor: p.success,
                      title: e['source'] ?? 'Other',
                      subtitle: '${_fmtDate(e['date'])}${(e['note'] ?? '').toString().isEmpty ? '' : ' • ${e['note']}'}',
                      trailing: Text('+${widget.store.currencySymbol}${((e['amount'] ?? 0) as num).toStringAsFixed(0)}',
                          style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 15, fontWeight: FontWeight.w700, color: p.success)),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class AddEditIncomePage extends StatefulWidget {
  final Store store;
  final Map<String, dynamic>? existing;
  const AddEditIncomePage({super.key, required this.store, this.existing});
  @override
  State<AddEditIncomePage> createState() => _AddEditIncomePageState();
}

class _AddEditIncomePageState extends State<AddEditIncomePage> {
  late TextEditingController _amount;
  late TextEditingController _note;
  String _source = 'Salary';
  DateTime _date = DateTime.now();
  final sources = const ['Salary', 'Freelance', 'Business', 'Bonus', 'Other'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amount = TextEditingController(text: e == null ? '' : (e['amount'] ?? '').toString());
    _note = TextEditingController(text: e?['note']?.toString() ?? '');
    _source = e?['source']?.toString() ?? 'Salary';
    _date = e?['date'] != null ? DateTime.tryParse(e!['date'].toString()) ?? DateTime.now() : DateTime.now();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final a = double.tryParse(_amount.text.trim());
    if (a == null || a <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount.')));
      return;
    }
    final items = widget.store.getList('incomes');
    final obj = {
      'id': widget.existing?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      'amount': a,
      'source': _source,
      'note': _note.text.trim(),
      'date': _date.toIso8601String(),
    };
    final i = items.indexWhere((e) => e['id'] == obj['id']);
    if (i >= 0) {
      items[i] = obj;
    } else {
      items.insert(0, obj);
    }
    await widget.store.saveList('incomes', items);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: widget.existing == null ? 'Add Income' : 'Edit Income',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb3),
            child: Column(
              children: [
                Overline('Amount • ${widget.store.currency}', color: p.textTertiary),
                const SizedBox(height: 6),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 34, fontWeight: FontWeight.w700, color: p.textPrimary),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 34, fontWeight: FontWeight.w700, color: p.textTertiary.withValues(alpha: .5)),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixText: '${widget.store.currencySymbol} ',
                    prefixStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 26, fontWeight: FontWeight.w700, color: p.success),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Income Source'),
          GlassCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sources
                  .map((c) => MChoicePill(
                        label: c,
                        icon: _sourceIcon(c),
                        selected: _source == c,
                        onTap: () => setState(() => _source = c),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Details'),
          GlassCard(
            child: Column(
              children: [
                MomentumRow(
                  icon: MSym.calendarToday,
                  title: 'Date',
                  subtitle: _fmtDate(_date.toIso8601String()),
                  trailing: TextButton(
                    onPressed: () => showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: _date).then((d) {
                      if (d != null) setState(() => _date = d);
                    }),
                    child: const Text('Change'),
                  ),
                ),
                Divider(color: p.divider, height: 1),
                const SizedBox(height: 12),
                TextField(controller: _note, maxLines: 3, decoration: const InputDecoration(labelText: 'Note', alignLabelWithHint: true)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(label: widget.existing == null ? 'Save Income' : 'Save Changes', icon: MSym.check, onPressed: _save),
        ],
      ),
    );
  }
}

// ============================================================================
// TASKS & REMINDERS / DAILY ROUTINE
// ============================================================================

class TasksReminders extends StatefulWidget {
  final Store store;
  const TasksReminders({super.key, required this.store});
  @override
  State<TasksReminders> createState() => _TasksRemindersState();
}

class _TasksRemindersState extends State<TasksReminders> {
  List<Map<String, dynamic>> get items => widget.store.getList('tasks');

  String _dateText() {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final done = items.where((e) => e['done'] == true).length;
    final rate = items.isEmpty ? 0.0 : done / items.length;
    return MomentumScaffold(
      store: widget.store,
      title: 'Tasks',
      showBottomNav: true,
      activeTab: 3,
      body: ListView(
        padding: pagePadding(context, dock: true),
        children: [
          // --- Heading block -----------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Overline(_dateText()),
                const SizedBox(height: 3),
                Text('Tasks & Reminders', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 3),
                Text('Organize your day with mindful focus', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // --- Daily completion hero ---------------------------------------
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, size: 120, color: p.orb1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBubble(MSym.taskAlt, size: 36, iconSize: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Overline('Daily Completion', color: p.textTertiary),
                          const SizedBox(height: 2),
                          Text('$done of ${items.length} Completed', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                    ActionPill(
                      label: 'Add',
                      icon: MSym.add,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskPage(store: widget.store))).then((_) => setState(() {})),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GradientProgressBar(value: rate),
                const SizedBox(height: 6),
                Text(
                  items.isEmpty ? 'A clear day. Add a task to begin.' : '${((rate) * 100).toStringAsFixed(0)}% of today’s intentions honored',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // --- Routine shortcut --------------------------------------------
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DailyRoutine(store: widget.store))).then((_) => setState(() {})),
            child: MomentumRow(
              icon: MSym.eventRepeat,
              iconColor: p.secondary,
              title: 'Daily Routine',
              subtitle: 'Recurring intentions & gentle rhythms',
              trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('All Tasks'),

          if (items.isEmpty)
            const GlassCard(padding: EdgeInsets.all(28), child: EmptyState(title: 'No tasks yet', action: 'Create a reminder'))
          else
            ...items.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.all(6),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTaskPage(store: widget.store, existing: t))).then((_) => setState(() {})),
                  child: TaskTile(store: widget.store, task: t, onChanged: () => setState(() {}), showChevron: true),
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

  Future<void> _delete() async {
    final items = widget.store.getList('tasks');
    items.removeWhere((e) => e['id'] == widget.existing?['id']);
    await widget.store.saveList('tasks', items);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: widget.existing == null ? 'Add Task' : 'Edit Task',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb2),
            child: Column(
              children: [
                TextField(controller: _title, decoration: const InputDecoration(labelText: 'Task title')),
                const SizedBox(height: 14),
                TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Priority'),
          GlassCard(
            child: Row(
              children: [
                for (final level in const ['Low', 'Normal', 'High']) ...[
                  Expanded(
                    child: MChoicePill(
                      label: level,
                      icon: level == 'High' ? MSym.priorityHigh : (level == 'Low' ? MSym.south : MSym.flag),
                      selected: _priority == level,
                      onTap: () => setState(() => _priority = level),
                    ),
                  ),
                  if (level != 'High') const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Schedule'),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.schedule,
                title: 'Time',
                subtitle: _time.format(context),
                trailing: TextButton(
                  onPressed: () => showTimePicker(context: context, initialTime: _time).then((t) {
                    if (t != null) setState(() => _time = t);
                  }),
                  child: Text(_time.format(context)),
                ),
              ),
              MomentumRow(
                icon: MSym.notifications,
                title: 'Reminder',
                subtitle: 'Gentle nudge at the chosen time',
                trailing: Switch(value: _reminder, onChanged: (v) => setState(() => _reminder = v)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GradientButton(label: widget.existing == null ? 'Save Task' : 'Save Changes', icon: MSym.check, onPressed: _save),
          if (widget.existing != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _delete,
              style: OutlinedButton.styleFrom(foregroundColor: p.danger, side: BorderSide(color: p.dangerBorder.withValues(alpha: .5))),
              icon: const Icon(MSym.delete, size: 18),
              label: const Text('Delete Task'),
            ),
          ],
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
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: 'Daily Routine',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb2),
            child: Row(
              children: [
                IconBubble(MSym.eventRepeat, size: 44, iconSize: 22, color: p.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${items.length} routine ${items.length == 1 ? 'item' : 'items'}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text('Rhythms that anchor your day', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                ActionPill(
                  label: 'Add',
                  icon: MSym.add,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditRoutinePage(store: widget.store))).then((_) => setState(() {})),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const GlassCard(padding: EdgeInsets.all(28), child: EmptyState(title: 'No routines yet', action: 'Create your first routine'))
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
  void dispose() {
    _title.dispose();
    super.dispose();
  }

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
    if (i >= 0) {
      items[i] = obj;
    } else {
      items.insert(0, obj);
    }
    await widget.store.saveList('routines', items);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: widget.existing == null ? 'Add Routine' : 'Edit Routine',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb2),
            child: TextField(controller: _title, decoration: const InputDecoration(labelText: 'Routine name')),
          ),
          const SizedBox(height: 14),
          SectionHeader('Repeat'),
          GlassCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const ['Every Day', 'Monday–Friday', 'Custom Days']
                  .map((r) => MChoicePill(
                        label: r,
                        icon: MSym.repeat,
                        selected: _repeat == r,
                        onTap: () => setState(() => _repeat = r),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Schedule'),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.schedule,
                title: 'Time',
                subtitle: _time.format(context),
                trailing: TextButton(
                  onPressed: () => showTimePicker(context: context, initialTime: _time).then((t) {
                    if (t != null) setState(() => _time = t);
                  }),
                  child: Text(_time.format(context)),
                ),
              ),
              MomentumRow(
                icon: MSym.notifications,
                title: 'Reminder',
                subtitle: 'Gentle nudge at the chosen time',
                trailing: Switch(value: _reminder, onChanged: (v) => setState(() => _reminder = v)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GradientButton(label: widget.existing == null ? 'Save Routine' : 'Save Changes', icon: MSym.check, onPressed: _save),
        ],
      ),
    );
  }
}

// ============================================================================
// PRAYER — service, times page, notification settings
// ============================================================================

class PrayerService {
  static Future<Map<String, String>> fetch(String city) async {
    try {
      final uri = Uri.parse('https://api.aladhan.com/v1/timingsByCity?city=$city&country=Afghanistan&method=2');
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
      final req = await client.getUrl(uri).timeout(const Duration(seconds: 12));
      final res = await req.close().timeout(const Duration(seconds: 12));
      final body = await res.transform(utf8.decoder).join();
      client.close();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final t = (data['data']?['timings'] ?? {}) as Map<String, dynamic>;
      return {
        'Fajr': t['Fajr']?.toString() ?? '--:--',
        'Dhuhr': t['Dhuhr']?.toString() ?? '--:--',
        'Asr': t['Asr']?.toString() ?? '--:--',
        'Maghrib': t['Maghrib']?.toString() ?? '--:--',
        'Isha': t['Isha']?.toString() ?? '--:--',
      };
    } catch (_) {
      return {'Fajr': '--:--', 'Dhuhr': '--:--', 'Asr': '--:--', 'Maghrib': '--:--', 'Isha': '--:--'};
    }
  }
}

class PrayerTimesPage extends StatefulWidget {
  final Store store;
  const PrayerTimesPage({super.key, required this.store});
  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  Map<String, String>? _times;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final t = await PrayerService.fetch(widget.store.city);
    if (mounted) {
      setState(() {
        _times = t;
        _loading = false;
      });
    }
  }

  static const _icons = {
    'Fajr': MSym.wbTwilight,
    'Dhuhr': MSym.lightMode,
    'Asr': MSym.routine,
    'Maghrib': MSym.wbSunny,
    'Isha': MSym.bedtime,
  };

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final entries = (_times ?? {}).entries.toList();
    return MomentumScaffold(
      store: widget.store,
      title: 'Prayer Times',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            mosqueWatermark: true,
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBubble(MSym.mosque, size: 44, iconSize: 22, color: p.tertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Overline('${widget.store.city}, Afghanistan', color: p.textTertiary),
                          const SizedBox(height: 2),
                          Text('Daily Schedule', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _load,
                      icon: Icon(MSym.refresh, color: p.accentText),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Calculated with ISNA method for your city', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_loading)
            Padding(
              padding: const EdgeInsets.all(36),
              child: Center(child: CircularProgressIndicator(color: p.primary)),
            )
          else ...[
            ...entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        IconBubble(_icons[e.key] ?? MSym.schedule, size: 40, color: p.tertiary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(e.key, style: Theme.of(context).textTheme.titleSmall)),
                        Text(e.value,
                            style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 17, fontWeight: FontWeight.w700, color: p.textPrimary)),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 4),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrayerNotificationSettings(store: widget.store))),
              child: MomentumRow(
                icon: MSym.notificationsActive,
                iconColor: p.secondary,
                title: 'Prayer Notifications',
                subtitle: 'Adhan & reminder preferences',
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PrayerNotificationSettings extends StatefulWidget {
  final Store store;
  const PrayerNotificationSettings({super.key, required this.store});
  @override
  State<PrayerNotificationSettings> createState() => _PrayerNotificationSettingsState();
}

class _PrayerNotificationSettingsState extends State<PrayerNotificationSettings> {
  final Map<String, bool> _enabled = {'Fajr': true, 'Dhuhr': true, 'Asr': true, 'Maghrib': true, 'Isha': true};
  bool _adhanSound = true;
  bool _preReminder = false;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: 'Prayer Notifications',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb3),
            child: Row(
              children: [
                IconBubble(MSym.notificationsActive, size: 44, iconSize: 22, color: p.tertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stay Connected', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text('Choose which prayers gently call you back', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Per-Prayer Alerts'),
          SettingsGroup(
            children: _enabled.keys
                .map((k) => MomentumRow(
                      icon: MSym.mosque,
                      iconColor: p.tertiary,
                      title: k,
                      subtitle: _enabled[k]! ? 'Notification on' : 'Muted',
                      trailing: Switch(value: _enabled[k]!, onChanged: (v) => setState(() => _enabled[k] = v)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          SectionHeader('Sound & Timing'),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.volumeUp,
                title: 'Adhan Sound',
                subtitle: 'Play the call to prayer',
                trailing: Switch(value: _adhanSound, onChanged: (v) => setState(() => _adhanSound = v)),
              ),
              MomentumRow(
                icon: MSym.timer,
                title: '15-minute Pre-reminder',
                subtitle: 'A quiet heads-up before each prayer',
                trailing: Switch(value: _preReminder, onChanged: (v) => setState(() => _preReminder = v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TASBEEH — main counter, new/edit, history, settings
// ============================================================================

const Map<String, String> _dhikrArabic = {
  'SubhanAllah': 'سُبْحَانَ ٱللَّٰهِ',
  'Alhamdulillah': 'ٱلْحَمْدُ لِلَّٰهِ',
  'Allahu Akbar': 'ٱللَّٰهُ أَكْبَرُ',
  'Astaghfirullah': 'أَسْتَغْفِرُ ٱللَّٰهَ',
};

class _TasbeehGaugePainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color start;
  final Color end;
  _TasbeehGaugePainter({required this.progress, required this.track, required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const stroke = 13.0;
    const startAngle = math.pi * .75;
    const sweep = math.pi * 1.5;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, false, trackPaint);
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweep,
          colors: [start, end],
          transform: const GradientRotation(0),
        ).createShader(rect);
      canvas.drawArc(rect, startAngle, sweep * progress.clamp(0.0, 1.0), false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_TasbeehGaugePainter old) =>
      old.progress != progress || old.track != track || old.start != start || old.end != end;
}

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

  Future<void> _increment() async {
    setState(() => _count++);
    if (_vibrate) HapticFeedback.lightImpact();
    if (_sound) SystemSound.play(SystemSoundType.click);
    if (_count >= _target) {
      final history = widget.store.getList('tasbeehHistory');
      history.insert(0, {
        'name': _name,
        'count': _count,
        'target': _target,
        'date': DateTime.now().toIso8601String(),
      });
      await widget.store.saveList('tasbeehHistory', history);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Target Reached'),
          content: Text('You completed $_target of $_name. Alhamdulillah.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _count = 0);
              },
              child: const Text('New Session'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final progress = _target == 0 ? 0.0 : (_count % math.max(_target, 1)) / math.max(_target, 1);
    final displayProgress = _count > 0 && _count % math.max(_target, 1) == 0 ? 1.0 : progress;
    return MomentumScaffold(
      store: widget.store,
      title: 'Tasbeeh',
      showBack: true,
      actions: [
        TopBarAction(icon: MSym.history, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TasbeehHistory(store: widget.store)))),
      ],
      body: ListView(
        padding: pagePadding(context),
        children: [
          // Dhikr identity block.
          Column(
            children: [
              Text(
                _dhikrArabic[_name] ?? 'سُبْحَانَ ٱللَّٰهِ',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: 'Amiri', fontSize: 30, height: 1.6, color: p.accentText),
              ),
              const SizedBox(height: 2),
              Text(_name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              StatusPill('Target: $_target', icon: MSym.flag),
            ],
          ),
          const SizedBox(height: 12),

          // Radial gauge + XL tap surface.
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.center, size: 220, color: p.orb1),
            child: Column(
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(240, 240),
                        painter: _TasbeehGaugePainter(
                          progress: displayProgress,
                          track: p.textPrimary.withValues(alpha: p.dark ? .10 : .07),
                          start: p.primary,
                          end: p.secondary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_count',
                              style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 56, fontWeight: FontWeight.w700, height: 1.0, color: p.textPrimary)),
                          const SizedBox(height: 4),
                          Text('of $_target', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Glossy 96px tap button.
                GestureDetector(
                  onTap: _increment,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: p.triGradientDiagonal,
                      boxShadow: p.fabGlow,
                      border: Border.all(color: Colors.white.withValues(alpha: .35), width: 1.5),
                    ),
                    child: const Icon(MSym.touchApp, size: 38, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Tap anywhere on the button to count', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 14),
                // Preset target pills.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [33, 99, 100, 1000]
                      .map((t) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: MChoicePill(
                              label: '$t',
                              selected: _target == t,
                              onTap: () => setState(() => _target = t),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Session controls.
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onTap: () => setState(() => _count = 0),
                  child: Column(
                    children: [
                      IconBubble(MSym.restartAlt, size: 36, iconSize: 19, color: p.danger),
                      const SizedBox(height: 6),
                      Text('Reset', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onTap: () async {
                    final result = await Navigator.push<Map<String, dynamic>>(
                        context, MaterialPageRoute(builder: (_) => NewEditTasbeeh(store: widget.store, currentName: _name, currentTarget: _target)));
                    if (result != null) {
                      setState(() {
                        _name = result['name'] ?? _name;
                        _target = result['target'] ?? _target;
                        _count = 0;
                      });
                    }
                  },
                  child: Column(
                    children: [
                      IconBubble(MSym.edit, size: 36, iconSize: 19, color: p.secondary),
                      const SizedBox(height: 6),
                      Text('Dhikr', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onTap: () async {
                    final result = await Navigator.push<Map<String, bool>>(
                        context, MaterialPageRoute(builder: (_) => TasbeehSettings(store: widget.store, vibrate: _vibrate, sound: _sound)));
                    if (result != null) {
                      setState(() {
                        _vibrate = result['vibrate'] ?? _vibrate;
                        _sound = result['sound'] ?? _sound;
                      });
                    }
                  },
                  child: Column(
                    children: [
                      IconBubble(MSym.tune, size: 36, iconSize: 19, color: p.tertiary),
                      const SizedBox(height: 6),
                      Text('Settings', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NewEditTasbeeh extends StatefulWidget {
  final Store store;
  final String currentName;
  final int currentTarget;
  const NewEditTasbeeh({super.key, required this.store, required this.currentName, required this.currentTarget});
  @override
  State<NewEditTasbeeh> createState() => _NewEditTasbeehState();
}

class _NewEditTasbeehState extends State<NewEditTasbeeh> {
  late final TextEditingController _custom;
  late String _selected;
  late int _target;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentName;
    _target = widget.currentTarget;
    _custom = TextEditingController(text: _dhikrArabic.containsKey(widget.currentName) ? '' : widget.currentName);
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: 'Choose Dhikr',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionHeader('Common Adhkar'),
          ..._dhikrArabic.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                onTap: () => setState(() => _selected = e.key),
                tier: _selected == e.key ? GlassTier.elevated : GlassTier.base,
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selected == e.key ? p.primary : Colors.transparent,
                        border: Border.all(color: _selected == e.key ? p.primary : p.textTertiary, width: 2),
                      ),
                      child: _selected == e.key ? const Icon(MSym.check, size: 14, color: Colors.white, weight: 700) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e.key, style: Theme.of(context).textTheme.titleSmall)),
                    Text(e.value,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 20, height: 1.5, color: p.accentText)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SectionHeader('Custom Dhikr'),
          GlassCard(
            child: TextField(
              controller: _custom,
              decoration: const InputDecoration(labelText: 'Write your own phrase'),
              onChanged: (v) {
                if (v.trim().isNotEmpty) setState(() => _selected = v.trim());
              },
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Target'),
          GlassCard(
            child: Row(
              children: [33, 99, 100, 1000]
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: MChoicePill(label: '$t', selected: _target == t, onTap: () => setState(() => _target = t)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(
            label: 'Start Session',
            icon: MSym.playArrow,
            onPressed: () => Navigator.pop(context, {'name': _selected, 'target': _target}),
          ),
        ],
      ),
    );
  }
}

class TasbeehHistory extends StatefulWidget {
  final Store store;
  const TasbeehHistory({super.key, required this.store});
  @override
  State<TasbeehHistory> createState() => _TasbeehHistoryState();
}

class _TasbeehHistoryState extends State<TasbeehHistory> {
  List<Map<String, dynamic>> get items => widget.store.getList('tasbeehHistory');

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final total = items.fold<int>(0, (s, e) => s + ((e['count'] ?? 0) as num).toInt());
    return MomentumScaffold(
      store: widget.store,
      title: 'Tasbeeh History',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            child: Row(
              children: [
                Expanded(
                  child: MetricColumn(label: 'Sessions', value: '${items.length}', footerIcon: MSym.history, footerText: 'recorded'),
                ),
                const MetricDivider(),
                Expanded(
                  child: MetricColumn(label: 'Total Dhikr', value: '$total', valueColor: p.accentText, footerIcon: MSym.spa, footerText: 'counts'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const GlassCard(padding: EdgeInsets.all(28), child: EmptyState(title: 'No sessions yet', action: 'Complete a target to record one'))
          else
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: MomentumRow(
                    icon: MSym.spa,
                    iconColor: p.tertiary,
                    title: e['name'] ?? 'Dhikr',
                    subtitle: _fmtDate(e['date']),
                    trailing: StatusPill('${e['count']} / ${e['target']}', color: p.secondary),
                  ),
                ),
              ),
            ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await widget.store.saveList('tasbeehHistory', []);
                setState(() {});
              },
              style: OutlinedButton.styleFrom(foregroundColor: p.danger, side: BorderSide(color: p.dangerBorder.withValues(alpha: .5))),
              icon: const Icon(MSym.delete, size: 18),
              label: const Text('Clear History'),
            ),
          ],
        ],
      ),
    );
  }
}

class TasbeehSettings extends StatefulWidget {
  final Store store;
  final bool vibrate;
  final bool sound;
  const TasbeehSettings({super.key, required this.store, required this.vibrate, required this.sound});
  @override
  State<TasbeehSettings> createState() => _TasbeehSettingsState();
}

class _TasbeehSettingsState extends State<TasbeehSettings> {
  late bool _vibrate;
  late bool _sound;

  @override
  void initState() {
    super.initState();
    _vibrate = widget.vibrate;
    _sound = widget.sound;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, {'vibrate': _vibrate, 'sound': _sound});
      },
      child: MomentumScaffold(
        store: widget.store,
        title: 'Tasbeeh Settings',
        showBack: true,
        body: ListView(
          padding: pagePadding(context),
          children: [
            SectionHeader('Feedback'),
            SettingsGroup(
              children: [
                MomentumRow(
                  icon: MSym.vibration,
                  title: 'Vibration',
                  subtitle: 'Haptic pulse on every count',
                  trailing: Switch(value: _vibrate, onChanged: (v) => setState(() => _vibrate = v)),
                ),
                MomentumRow(
                  icon: MSym.volumeUp,
                  title: 'Sound',
                  subtitle: 'Soft click on every count',
                  trailing: Switch(value: _sound, onChanged: (v) => setState(() => _sound = v)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// NOTES — hub, quick note, long note, media viewer
// ============================================================================

class NotesMain extends StatefulWidget {
  final Store store;
  const NotesMain({super.key, required this.store});
  @override
  State<NotesMain> createState() => _NotesMainState();
}

class _NotesMainState extends State<NotesMain> {
  String _query = '';
  List<Map<String, dynamic>> get items => widget.store.getList('notes');

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final list = items.where((e) => _query.isEmpty || '${e['title']} ${e['content']}'.toLowerCase().contains(_query.toLowerCase())).toList();
    return MomentumScaffold(
      store: widget.store,
      title: 'Notes',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNoteEditor(store: widget.store))).then((_) => setState(() {})),
                  child: Column(
                    children: [
                      IconBubble(MSym.bolt, size: 44, iconSize: 22),
                      const SizedBox(height: 8),
                      Text('Quick Note', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text('Capture a thought', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LongNoteEditor(store: widget.store))).then((_) => setState(() {})),
                  child: Column(
                    children: [
                      IconBubble(MSym.article, size: 44, iconSize: 22, color: p.secondary),
                      const SizedBox(height: 8),
                      Text('Long Note', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text('Write with media', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          MSearchField(hint: 'Search notes', onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: 14),
          SectionHeader('All Notes'),
          if (list.isEmpty)
            const GlassCard(padding: EdgeInsets.all(28), child: EmptyState(title: 'No notes yet', action: 'Capture your first thought'))
          else
            ...list.map((n) {
              final isQuick = n['type'] == 'quick';
              final attachments = (n['attachments'] as List?) ?? const [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => isQuick ? QuickNoteEditor(store: widget.store, existing: n) : LongNoteEditor(store: widget.store, existing: n),
                    ),
                  ).then((_) => setState(() {})),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBubble(isQuick ? MSym.bolt : MSym.article, size: 40, color: isQuick ? p.primary : p.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (n['title'] ?? '').toString().isEmpty ? 'Untitled' : n['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (n['content'] ?? '').toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Overline(_fmtDate(n['date']), color: p.textTertiary),
                                if (attachments.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  StatusPill('${attachments.length} media', icon: MSym.attachFile, color: p.secondary),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty && _content.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    final items = widget.store.getList('notes');
    final obj = <String, dynamic>{
      'id': widget.existing?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      'type': 'quick',
      'title': _title.text.trim(),
      'content': _content.text.trim(),
      'date': DateTime.now().toIso8601String(),
      'attachments': widget.existing?['attachments'] ?? [],
    };
    final i = items.indexWhere((e) => e['id'] == obj['id']);
    if (i >= 0) {
      items[i] = obj;
    } else {
      items.insert(0, obj);
    }
    await widget.store.saveList('notes', items);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final items = widget.store.getList('notes');
    items.removeWhere((e) => e['id'] == widget.existing?['id']);
    await widget.store.saveList('notes', items);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: 'Quick Note',
      showBack: true,
      actions: [
        if (widget.existing != null) TopBarAction(icon: MSym.delete, onTap: _delete),
      ],
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            child: Column(
              children: [
                TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 14),
                TextField(
                  controller: _content,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'Write your thought…', alignLabelWithHint: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(label: 'Save Note', icon: MSym.check, onPressed: _save),
        ],
      ),
    );
  }
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
  late List<Map<String, dynamic>> _attachments;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?['title']?.toString() ?? '');
    _content = TextEditingController(text: widget.existing?['content']?.toString() ?? '');
    _attachments = ((widget.existing?['attachments'] as List?) ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _attach() async {
    final p = Pal.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(MomentumTokens.radiusLg)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: MomentumTokens.blurXl, sigmaY: MomentumTokens.blurXl),
          child: Container(
            color: p.headerSurface,
            padding: EdgeInsets.fromLTRB(16, 14, 16, MediaQuery.of(ctx).padding.bottom + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: p.textTertiary.withValues(alpha: .4), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                MomentumRow(
                  icon: MSym.image,
                  title: 'Add Image',
                  subtitle: 'Pick from gallery',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final img = await _picker.pickImage(source: ImageSource.gallery);
                    if (img != null) setState(() => _attachments.add({'type': 'image', 'path': img.path}));
                  },
                ),
                MomentumRow(
                  icon: MSym.videocam,
                  title: 'Add Video',
                  subtitle: 'Pick from gallery',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final vid = await _picker.pickVideo(source: ImageSource.gallery);
                    if (vid != null) setState(() => _attachments.add({'type': 'video', 'path': vid.path}));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty && _content.text.trim().isEmpty && _attachments.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final items = widget.store.getList('notes');
    final obj = <String, dynamic>{
      'id': widget.existing?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      'type': 'long',
      'title': _title.text.trim(),
      'content': _content.text.trim(),
      'date': DateTime.now().toIso8601String(),
      'attachments': _attachments,
    };
    final i = items.indexWhere((e) => e['id'] == obj['id']);
    if (i >= 0) {
      items[i] = obj;
    } else {
      items.insert(0, obj);
    }
    await widget.store.saveList('notes', items);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final items = widget.store.getList('notes');
    items.removeWhere((e) => e['id'] == widget.existing?['id']);
    await widget.store.saveList('notes', items);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: 'Long Note',
      showBack: true,
      actions: [
        TopBarAction(icon: MSym.attachFile, onTap: _attach),
        if (widget.existing != null) TopBarAction(icon: MSym.delete, onTap: _delete),
      ],
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb2),
            child: Column(
              children: [
                TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 14),
                TextField(
                  controller: _content,
                  maxLines: 12,
                  decoration: const InputDecoration(labelText: 'Write freely…', alignLabelWithHint: true),
                ),
              ],
            ),
          ),
          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 14),
            SectionHeader('Attachments'),
            GlassCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _attachments.asMap().entries.map((entry) {
                  final a = entry.value;
                  final isImage = a['type'] == 'image';
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteMediaViewer(store: widget.store, media: a))),
                    onLongPress: () => setState(() => _attachments.removeAt(entry.key)),
                    child: Container(
                      width: 76,
                      height: 76,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(MomentumTokens.radiusSm),
                        color: p.cardSubtle,
                        border: Border.all(color: p.hairline),
                      ),
                      child: isImage
                          ? Image.file(File(a['path'] ?? ''), fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(MSym.brokenImage, color: p.textTertiary))
                          : Icon(MSym.videocam, color: p.textSecondary, size: 28),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),
            Center(child: Text('Tap to view • long-press to remove', style: Theme.of(context).textTheme.bodySmall)),
          ],
          const SizedBox(height: 18),
          GradientButton(label: 'Save Note', icon: MSym.check, onPressed: _save),
        ],
      ),
    );
  }
}

class NoteMediaViewer extends StatelessWidget {
  final Store store;
  final Map<String, dynamic> media;
  const NoteMediaViewer({super.key, required this.store, required this.media});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final isImage = media['type'] == 'image';
    return MomentumScaffold(
      store: store,
      title: isImage ? 'Image' : 'Video',
      showBack: true,
      body: Center(
        child: Padding(
          padding: pagePadding(context),
          child: isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(MomentumTokens.radiusMd),
                  child: Image.file(File(media['path'] ?? ''),
                      errorBuilder: (_, _, _) => Icon(MSym.brokenImage, size: 64, color: p.textTertiary)),
                )
              : GlassCard(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconBubble(MSym.videocam, size: 64, iconSize: 32, color: p.secondary),
                      const SizedBox(height: 12),
                      Text('Video attachment', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(media['path'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ============================================================================
// CALENDARS — Tri-Calendar hub + three standalone calendar pages
// ============================================================================

class CalendarsMain extends StatelessWidget {
  final Store store;
  const CalendarsMain({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final now = DateTime.now();
    final hijri = _gregorianToHijri(now);
    final jalali = _gregorianToJalali(now);
    return MomentumScaffold(
      store: store,
      title: 'Calendars',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          // Today across three calendars.
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Overline('Today • Three Worlds, One Day', color: p.textTertiary),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MetricColumn(
                        label: 'Gregorian',
                        value: '${now.day}',
                        footerIcon: MSym.public,
                        footerText: '${_months[now.month - 1].substring(0, 3)} ${now.year}',
                      ),
                    ),
                    const MetricDivider(),
                    Expanded(
                      child: MetricColumn(
                        label: 'Hijri',
                        value: '${hijri.$3}',
                        valueColor: p.accentText,
                        footerIcon: MSym.mosque,
                        footerText: '${_hijriMonths[hijri.$2 - 1]} ${hijri.$1}',
                      ),
                    ),
                    const MetricDivider(),
                    Expanded(
                      child: MetricColumn(
                        label: 'Shamsi',
                        value: '${jalali.$3}',
                        footerIcon: MSym.wbSunny,
                        footerText: '${_jalaliMonths[jalali.$2 - 1]} ${jalali.$1}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Open a Calendar'),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GregorianCalendarPage(store: store))),
            child: MomentumRow(
              icon: MSym.public,
              iconColor: p.primary,
              title: 'Gregorian Calendar',
              subtitle: 'International civil calendar',
              trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HijriCalendarPage(store: store))),
            child: MomentumRow(
              icon: MSym.mosque,
              iconColor: p.tertiary,
              title: 'Hijri Calendar',
              subtitle: 'Islamic lunar calendar',
              trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShamsiCalendarPage(store: store))),
            child: MomentumRow(
              icon: MSym.wbSunny,
              iconColor: p.secondary,
              title: 'Shamsi Calendar',
              subtitle: 'Solar Hijri calendar of Afghanistan & Iran',
              trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared month-grid shell used by the three standalone calendar pages.
Widget _calendarShell({
  required BuildContext context,
  required Store store,
  required String title,
  required String monthLabel,
  required VoidCallback onPrev,
  required VoidCallback onNext,
  required List<DateTime> days,
  required String Function(DateTime) toLabel,
  required bool Function(DateTime) isToday,
}) {
  final p = Pal.of(context);
  const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return MomentumScaffold(
    store: store,
    title: title,
    showBack: true,
    body: ListView(
      padding: pagePadding(context),
      children: [
        GlassCard.hero(
          glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
          child: Column(
            children: [
              Row(
                children: [
                  TopBarAction(icon: MSym.chevronLeft, onTap: onPrev),
                  Expanded(
                    child: Text(monthLabel, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  TopBarAction(icon: MSym.chevronRight, onTap: onNext),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: weekdays
                    .map((w) => Expanded(
                          child: Center(
                            child: Text(w,
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: p.textTertiary)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: days.map((d) {
                  final label = toLabel(d);
                  final today = isToday(d);
                  return Container(
                    alignment: Alignment.center,
                    decoration: today
                        ? BoxDecoration(shape: BoxShape.circle, gradient: p.primaryGradient, boxShadow: [
                            BoxShadow(color: p.primary.withValues(alpha: .4), blurRadius: 10),
                          ])
                        : null,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: today ? FontWeight.w700 : FontWeight.w400,
                        color: today
                            ? Colors.white
                            : label.isEmpty
                                ? Colors.transparent
                                : p.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class GregorianCalendarPage extends StatefulWidget {
  final Store store;
  const GregorianCalendarPage({super.key, required this.store});
  @override
  State<GregorianCalendarPage> createState() => _GregorianCalendarPageState();
}

class _GregorianCalendarPageState extends State<GregorianCalendarPage> {
  DateTime _anchor = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Widget build(BuildContext context) {
    final first = _anchor;
    final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
    final lead = (first.weekday + 6) % 7;
    final days = <DateTime>[
      for (var i = 0; i < lead; i++) DateTime(1, 1, 1),
      for (var d = 1; d <= daysInMonth; d++) DateTime(first.year, first.month, d),
    ];
    final now = DateTime.now();
    return _calendarShell(
      context: context,
      store: widget.store,
      title: 'Gregorian',
      monthLabel: '${_months[first.month - 1]} ${first.year}',
      onPrev: () => setState(() => _anchor = DateTime(first.year, first.month - 1, 1)),
      onNext: () => setState(() => _anchor = DateTime(first.year, first.month + 1, 1)),
      days: days,
      toLabel: (d) => d.year == 1 ? '' : '${d.day}',
      isToday: (d) => d.year == now.year && d.month == now.month && d.day == now.day,
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
  // Anchor on today's Gregorian; page by ~29.5-day lunations for display.
  DateTime _anchor = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final h = _gregorianToHijri(_anchor);
    // Find Gregorian date of hijri month start by walking back.
    var start = _anchor;
    while (_gregorianToHijri(start).$3 != 1) {
      start = _addDays(start, -1);
    }
    final monthLen = _gregorianToHijri(_addDays(start, 29)).$3 == 30 ? 30 : 29;
    final lead = (start.weekday + 6) % 7;
    final days = <DateTime>[
      for (var i = 0; i < lead; i++) DateTime(1, 1, 1),
      for (var d = 0; d < monthLen; d++) _addDays(start, d),
    ];
    final now = DateTime.now();
    return _calendarShell(
      context: context,
      store: widget.store,
      title: 'Hijri',
      monthLabel: '${_hijriMonths[h.$2 - 1]} ${h.$1} AH',
      onPrev: () => setState(() => _anchor = _addDays(start, -15)),
      onNext: () => setState(() => _anchor = _addDays(start, monthLen + 15)),
      days: days,
      toLabel: (d) => d.year == 1 ? '' : '${_gregorianToHijri(d).$3}',
      isToday: (d) => d.year == now.year && d.month == now.month && d.day == now.day,
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
  DateTime _anchor = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final j = _gregorianToJalali(_anchor);
    var start = _anchor;
    while (_gregorianToJalali(start).$3 != 1) {
      start = _addDays(start, -1);
    }
    final monthLen = j.$2 <= 6 ? 31 : (j.$2 <= 11 ? 30 : (_gregorianToJalali(_addDays(start, 29)).$3 == 30 ? 30 : 29));
    final lead = (start.weekday + 6) % 7;
    final days = <DateTime>[
      for (var i = 0; i < lead; i++) DateTime(1, 1, 1),
      for (var d = 0; d < monthLen; d++) _addDays(start, d),
    ];
    final now = DateTime.now();
    return _calendarShell(
      context: context,
      store: widget.store,
      title: 'Shamsi',
      monthLabel: '${_jalaliMonths[j.$2 - 1]} ${j.$1}',
      onPrev: () => setState(() => _anchor = _addDays(start, -15)),
      onNext: () => setState(() => _anchor = _addDays(start, monthLen + 15)),
      days: days,
      toLabel: (d) => d.year == 1 ? '' : '${_gregorianToJalali(d).$3}',
      isToday: (d) => d.year == now.year && d.month == now.month && d.day == now.day,
    );
  }
}

// ============================================================================
// MORE — full Momentum Hub page (replaces the old bottom sheet)
// ============================================================================

class MorePage extends StatelessWidget {
  final Store store;
  const MorePage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final tasks = store.getList('tasks');
    final doneTasks = tasks.where((e) => e['done'] == true).length;
    final notes = store.getList('notes');
    final dhikr = store.getList('tasbeehHistory').fold<int>(0, (s, e) => s + ((e['count'] ?? 0) as num).toInt());
    final initials = store.name.trim().isEmpty ? 'U' : store.name.trim()[0].toUpperCase();

    Widget module(IconData icon, Color color, String title, String subtitle, Widget page) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
            child: MomentumRow(
              icon: icon,
              iconColor: color,
              title: title,
              subtitle: subtitle,
              trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
            ),
          ),
        );

    return MomentumScaffold(
      store: store,
      title: 'More',
      showBottomNav: true,
      activeTab: 4,
      body: ListView(
        padding: pagePadding(context, dock: true),
        children: [
          // Hub header.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Overline('MOMENTUM HUB'),
                const SizedBox(height: 3),
                Text('Your Space', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 3),
                Text('Every tool for an intentional life, in one place', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Profile hero card.
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: p.triGradientDiagonal),
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: p.dark ? const Color(0xFF242A36) : Colors.white),
                        child: Center(
                          child: Text(initials,
                              style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 21, fontWeight: FontWeight.w700, color: p.accentText)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(store.name.isEmpty ? 'Friend' : store.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          StatusPill('${store.city} • ${store.currency}', icon: MSym.locationOn),
                        ],
                      ),
                    ),
                    TopBarAction(icon: MSym.arrowForward, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsProfile(store: store)))),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: p.divider, height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: MetricColumn(label: 'Tasks Done', value: '$doneTasks/${tasks.length}', footerIcon: MSym.taskAlt, footerText: 'today'),
                    ),
                    const MetricDivider(),
                    Expanded(
                      child: MetricColumn(label: 'Notes', value: '${notes.length}', footerIcon: MSym.notes, footerText: 'captured'),
                    ),
                    const MetricDivider(),
                    Expanded(
                      child: MetricColumn(label: 'Dhikr', value: '$dhikr', valueColor: p.accentText, footerIcon: MSym.spa, footerText: 'total'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SectionHeader('Ecosystem Essentials', trailing: '6 Modules'),
          module(MSym.trendingUp, p.success, 'Income Management', 'Salaries, freelance & business income', IncomeManagement(store: store)),
          module(MSym.mosque, p.tertiary, 'Prayer Times', 'Daily schedule for ${store.city}', PrayerTimesPage(store: store)),
          module(MSym.spa, p.primary, 'Tasbeeh Counter', 'Dhikr sessions with gentle haptics', TasbeehMain(store: store)),
          module(MSym.notes, p.secondary, 'Notes', 'Quick thoughts & long-form writing', NotesMain(store: store)),
          module(MSym.calendarMonth, p.primary, 'Calendars', 'Gregorian • Hijri • Shamsi', CalendarsMain(store: store)),
          module(MSym.settings, p.textSecondary, 'Settings & Profile', 'Appearance, security, regional & data', SettingsProfile(store: store)),

          const SizedBox(height: 6),
          // Created-by banner.
          GlassCard(
            tier: GlassTier.subtle,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text('MOMENTUM', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 3, color: p.textSecondary)),
                const SizedBox(height: 4),
                Text('Created by Milad Wardak', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SETTINGS & PROFILE
// ============================================================================

class SettingsProfile extends StatefulWidget {
  final Store store;
  const SettingsProfile({super.key, required this.store});
  @override
  State<SettingsProfile> createState() => _SettingsProfileState();
}

class _SettingsProfileState extends State<SettingsProfile> {
  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This permanently deletes every record on this device. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete Everything')),
        ],
      ),
    );
    if (ok == true) {
      await widget.store.clearAll();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MomentumApp(prefs: widget.store.prefs)),
          (_) => false,
        );
      }
    }
  }

  void _push(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) => setState(() {}));

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final initials = widget.store.name.trim().isEmpty ? 'U' : widget.store.name.trim()[0].toUpperCase();
    return MomentumScaffold(
      store: widget.store,
      title: 'Settings & Profile',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          // Profile header.
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            onTap: () => _push(EditProfile(store: widget.store)),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: p.triGradientDiagonal),
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: p.dark ? const Color(0xFF242A36) : Colors.white),
                    child: Center(
                      child: Text(initials,
                          style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 22, fontWeight: FontWeight.w700, color: p.accentText)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.store.name.isEmpty ? 'Friend' : widget.store.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 3),
                      Text('${widget.store.city}, Afghanistan • ${widget.store.currency}', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 6),
                      StatusPill('Edit Profile', icon: MSym.edit),
                    ],
                  ),
                ),
                Icon(MSym.chevronRight, size: 22, color: p.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SectionHeader('Regional'),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.paid,
                title: 'Currency',
                subtitle: '${widget.store.currency} (${widget.store.currencySymbol})',
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
                onTap: () => _push(CurrencySelectionPage(store: widget.store)),
              ),
              MomentumRow(
                icon: MSym.schedule,
                title: 'Timezone',
                subtitle: widget.store.timezone,
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
                onTap: () => _push(TimezoneSelectionPage(store: widget.store)),
              ),
              MomentumRow(
                icon: MSym.locationOn,
                title: 'City',
                subtitle: widget.store.city,
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
                onTap: () => _push(CitySelectionPage(store: widget.store)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SectionHeader('Appearance'),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.palette,
                title: 'Theme & Wallpaper',
                subtitle: 'Light, dark, wallpapers & blur',
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
                onTap: () => _push(AppearancePage(store: widget.store)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SectionHeader('Security'),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.lock,
                title: 'App Lock',
                subtitle: widget.store.appLockEnabled ? 'Enabled' : 'Disabled',
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
                onTap: () => _push(AppLockPage(store: widget.store)),
              ),
              MomentumRow(
                icon: MSym.fingerprint,
                title: 'Biometric Unlock',
                subtitle: widget.store.biometricEnabled ? 'Enabled' : 'Disabled',
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
                onTap: () => _push(BiometricPage(store: widget.store)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SectionHeader('Notifications'),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.notifications,
                title: 'Notification Preferences',
                subtitle: 'Tasks, prayers & reminders',
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
                onTap: () => _push(NotificationsPage(store: widget.store)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SectionHeader('Data'),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.deleteForever,
                title: 'Clear All Data',
                subtitle: 'Erase everything on this device',
                destructive: true,
                trailing: Icon(MSym.chevronRight, size: 20, color: p.danger),
                onTap: _clear,
              ),
            ],
          ),
          const SizedBox(height: 14),

          SectionHeader('About'),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.info,
                title: 'About Momentum',
                subtitle: 'Version 1.0.0',
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
                onTap: () => _push(AboutPage(store: widget.store)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(child: Text('Created by Milad Wardak', style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
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
  late String _currency;
  late String _timezone;
  late String _city;
  static const _symbols = {'AFN': '؋', 'USD': '\$', 'EUR': '€'};

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.store.name);
    _currency = widget.store.currency;
    _timezone = widget.store.timezone;
    _city = widget.store.city;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    await widget.store.setProfile(
      name: _name.text.trim(),
      currency: _currency,
      currencySymbol: _symbols[_currency] ?? '؋',
      timezone: _timezone,
      city: _city,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: 'Edit Profile',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            child: TextField(controller: _name, decoration: const InputDecoration(labelText: 'Your name')),
          ),
          const SizedBox(height: 14),
          SectionHeader('Currency'),
          GlassCard(
            child: Row(
              children: _symbols.keys
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: MChoicePill(
                          label: '$c ${_symbols[c]}',
                          selected: _currency == c,
                          onTap: () => setState(() => _currency = c),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('Timezone'),
          GlassCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const ['Asia/Kabul', 'Asia/Dubai', 'Asia/Karachi']
                  .map((t) => MChoicePill(label: t, selected: _timezone == t, onTap: () => setState(() => _timezone = t)))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader('City'),
          GlassCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const ['Kabul', 'Herat', 'Mazar-e-Sharif', 'Kandahar']
                  .map((c) => MChoicePill(label: c, selected: _city == c, onTap: () => setState(() => _city = c)))
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(label: 'Save Profile', icon: MSym.check, onPressed: _save),
        ],
      ),
    );
  }
}

// ============================================================================
// APPEARANCE / WALLPAPERS / BLUR
// ============================================================================

class AppearancePage extends StatefulWidget {
  final Store store;
  const AppearancePage({super.key, required this.store});
  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  late double _blur;

  @override
  void initState() {
    super.initState();
    _blur = widget.store.blur;
  }

  Future<void> _setTheme(String mode) async {
    await widget.store.prefs.setString('themeMode', mode);
    final themeMode = switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    await MomentumThemeBridge.callback?.call(themeMode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final mode = widget.store.prefs.getString('themeMode') ?? 'system';
    final wp = wallpapers[widget.store.wallpaperIndex.clamp(0, wallpapers.length - 1)];
    Widget radioRow(String value, String label, String subtitle, IconData icon) => MomentumRow(
          icon: icon,
          title: label,
          subtitle: subtitle,
          onTap: () => _setTheme(value),
          trailing: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mode == value ? p.primary : Colors.transparent,
              border: Border.all(color: mode == value ? p.primary : p.textTertiary, width: 2),
            ),
            child: mode == value ? const Icon(MSym.check, size: 14, color: Colors.white, weight: 700) : null,
          ),
        );

    return MomentumScaffold(
      store: widget.store,
      title: 'Appearance',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionHeader('Theme'),
          SettingsGroup(
            children: [
              radioRow('light', 'Light', 'Bright, airy glassmorphism', MSym.lightMode),
              radioRow('dark', 'Dark', 'Nocturne — deep indigo calm', MSym.darkMode),
              radioRow('system', 'System', 'Follow device setting', MSym.brightnessAuto),
            ],
          ),
          const SizedBox(height: 14),

          SectionHeader('Wallpaper'),
          GlassCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WallpaperLibrary(store: widget.store))).then((_) => setState(() {})),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MomentumTokens.radiusSm),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: p.dark ? wp.dark : wp.light,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(wp.name, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text('Source: ${widget.store.wallpaperSource}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 14),

          SectionHeader('Background Blur'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Frosted intensity', style: Theme.of(context).textTheme.titleSmall),
                    StatusPill('${_blur.toStringAsFixed(0)} px'),
                  ],
                ),
                Slider(
                  value: _blur,
                  min: 0,
                  max: 40,
                  divisions: 40,
                  onChanged: (v) => setState(() => _blur = v),
                  onChangeEnd: (v) => widget.store.setBlur(v),
                ),
                Text('Softens the wallpaper behind glass surfaces', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WallpaperLibrary extends StatefulWidget {
  final Store store;
  const WallpaperLibrary({super.key, required this.store});
  @override
  State<WallpaperLibrary> createState() => _WallpaperLibraryState();
}

class _WallpaperLibraryState extends State<WallpaperLibrary> {
  bool _checking = false;

  Future<bool> _checkInternet() async {
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
      final req = await client.getUrl(Uri.parse('https://example.com')).timeout(const Duration(seconds: 5));
      final res = await req.close().timeout(const Duration(seconds: 5));
      client.close();
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _setSource(String source) async {
    if (source == 'Online') {
      setState(() => _checking = true);
      final ok = await _checkInternet();
      setState(() => _checking = false);
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No internet connection. Staying offline.')));
        }
        return;
      }
    }
    await widget.store.setWallpaperSource(source);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final selected = widget.store.wallpaperIndex;
    final source = widget.store.wallpaperSource;
    return MomentumScaffold(
      store: widget.store,
      title: 'Wallpaper Library',
      showBack: true,
      actions: [
        TopBarAction(icon: MSym.blurOn, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WallpaperBlurPage(store: widget.store)))),
      ],
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Atmosphere Library', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('${wallpapers.length} curated gradients, tuned for glass', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: MChoicePill(
                        label: 'Default / Offline',
                        icon: MSym.cloudOff,
                        selected: source != 'Online',
                        onTap: () => _setSource('Default / Offline'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MChoicePill(
                        label: _checking ? 'Checking…' : 'Online',
                        icon: MSym.cloud,
                        selected: source == 'Online',
                        onTap: () => _setSource('Online'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .78,
            ),
            itemCount: wallpapers.length,
            itemBuilder: (_, i) {
              final w = wallpapers[i];
              final active = i == selected;
              return GestureDetector(
                onTap: () async {
                  await widget.store.setWallpaper(i);
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MomentumTokens.radiusLg),
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: p.dark ? w.dark : w.light),
                    border: Border.all(
                      color: active ? p.primary : p.hairline,
                      width: active ? 3 : 1,
                    ),
                    boxShadow: active ? [BoxShadow(color: p.primary.withValues(alpha: .35), blurRadius: 16)] : null,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.black.withValues(alpha: .30),
                          ),
                          child: Text(
                            w.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                      if (active)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: p.primary),
                            child: const Icon(MSym.check, size: 16, color: Colors.white, weight: 700),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class WallpaperBlurPage extends StatefulWidget {
  final Store store;
  const WallpaperBlurPage({super.key, required this.store});
  @override
  State<WallpaperBlurPage> createState() => _WallpaperBlurPageState();
}

class _WallpaperBlurPageState extends State<WallpaperBlurPage> {
  late double _blur;

  @override
  void initState() {
    super.initState();
    _blur = widget.store.blur;
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: 'Wallpaper Blur',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb2),
            child: Column(
              children: [
                IconBubble(MSym.blurOn, size: 52, iconSize: 26, color: p.secondary),
                const SizedBox(height: 10),
                Text('Depth of Field', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Drag to soften the atmosphere behind your glass', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Slider(
                  value: _blur,
                  min: 0,
                  max: 40,
                  divisions: 40,
                  onChanged: (v) {
                    setState(() => _blur = v);
                    widget.store.setBlur(v);
                  },
                ),
                StatusPill('${_blur.toStringAsFixed(0)} px blur'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECURITY — app lock, PIN setup, biometric, unlock gate
// ============================================================================

class AppLockPage extends StatefulWidget {
  final Store store;
  const AppLockPage({super.key, required this.store});
  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  Future<void> _toggle(bool v) async {
    if (v && !widget.store.hasPin()) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => PinSetupPage(store: widget.store)));
      if (widget.store.hasPin()) await widget.store.setAppLock(true);
    } else {
      await widget.store.setAppLock(v);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final enabled = widget.store.appLockEnabled;
    return MomentumScaffold(
      store: widget.store,
      title: 'App Lock',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          // Security banner.
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            child: Row(
              children: [
                IconBubble(MSym.shield, size: 40, iconSize: 21, fill: 1),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Private by Design', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text('Your PIN never leaves this device — stored as a salted hash.', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.lock,
                title: 'Require PIN',
                subtitle: enabled ? 'App locks when reopened' : 'App opens without a PIN',
                trailing: Switch(value: enabled, onChanged: _toggle),
              ),
              MomentumRow(
                icon: MSym.password,
                title: widget.store.hasPin() ? 'Change PIN' : 'Set PIN',
                subtitle: '4-digit code',
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PinSetupPage(store: widget.store))).then((_) => setState(() {})),
              ),
              MomentumRow(
                icon: MSym.fingerprint,
                title: 'Biometric Unlock',
                subtitle: widget.store.biometricEnabled ? 'Enabled' : 'Disabled',
                trailing: Icon(MSym.chevronRight, size: 20, color: p.textTertiary),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BiometricPage(store: widget.store))).then((_) => setState(() {})),
              ),
            ],
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
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final a = _pin.text.trim();
    final b = _confirm.text.trim();
    if (a.length != 4 || int.tryParse(a) == null) {
      setState(() => _error = 'PIN must be exactly 4 digits.');
      return;
    }
    if (a != b) {
      setState(() => _error = 'PINs do not match.');
      return;
    }
    await widget.store.setPin(a);
    if (mounted) Navigator.pop(context);
  }

  InputDecoration _dec(String label) => InputDecoration(labelText: label, counterText: '');

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final pinStyle = TextStyle(fontFamily: 'SpaceMono', fontSize: 22, letterSpacing: 12, color: p.textPrimary);
    Widget step(int n, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InsetRow(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: p.primary.withValues(alpha: p.dark ? .28 : .13)),
                  child: Center(
                      child: Text('$n', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 12, fontWeight: FontWeight.w700, color: p.accentText))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ),
        );

    return MomentumScaffold(
      store: widget.store,
      title: widget.store.hasPin() ? 'Change PIN' : 'Set PIN',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          Center(child: StatusPill('SECURE • LOCAL ONLY', icon: MSym.shield, solid: true)),
          const SizedBox(height: 14),
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb1),
            child: Column(
              children: [
                IconBubble(MSym.password, size: 52, iconSize: 26, fill: 1),
                const SizedBox(height: 14),
                TextField(
                  controller: _pin,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: pinStyle,
                  decoration: _dec('New PIN'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _confirm,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: pinStyle,
                  decoration: _dec('Confirm PIN'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: p.danger)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          step(1, 'Choose a 4-digit code you will remember.'),
          step(2, 'It is hashed with a random salt — never stored in plain text.'),
          step(3, 'Enable App Lock to require it on every launch.'),
          const SizedBox(height: 10),
          GradientButton(label: 'Save PIN', icon: MSym.check, onPressed: _save),
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
  final LocalAuthentication _auth = LocalAuthentication();
  bool? _supported;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final ok = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (mounted) setState(() => _supported = ok);
    } catch (_) {
      if (mounted) setState(() => _supported = false);
    }
  }

  Future<void> _toggle(bool v) async {
    if (v) {
      try {
        final ok = await _auth.authenticate(localizedReason: 'Confirm your identity to enable biometric unlock');
        if (!ok) return;
      } catch (_) {
        return;
      }
    }
    await widget.store.setBiometric(v);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: widget.store,
      title: 'Biometric Unlock',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topRight, color: p.orb2),
            child: Column(
              children: [
                IconBubble(MSym.fingerprint, size: 64, iconSize: 34, color: p.secondary),
                const SizedBox(height: 12),
                Text('Fingerprint & Face', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  _supported == null
                      ? 'Checking device support…'
                      : _supported!
                          ? 'This device supports biometric unlock.'
                          : 'Biometrics are not available on this device.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.fingerprint,
                title: 'Use Biometrics',
                subtitle: 'Unlock Momentum with fingerprint or face',
                trailing: Switch(
                  value: widget.store.biometricEnabled,
                  onChanged: _supported == true ? _toggle : null,
                ),
              ),
            ],
          ),
        ],
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
  final LocalAuthentication _auth = LocalAuthentication();
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.store.biometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _biometric());
    }
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  void _enter() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeDashboard(store: widget.store)));
  }

  Future<void> _biometric() async {
    try {
      final ok = await _auth.authenticate(localizedReason: 'Unlock Momentum');
      if (ok && mounted) _enter();
    } catch (_) {}
  }

  void _verify() {
    if (widget.store.verifyPin(_pin.text.trim())) {
      _enter();
    } else {
      setState(() => _error = 'Incorrect PIN. Try again.');
      _pin.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumBackdrop(
      wallpaperIndex: widget.store.wallpaperIndex,
      wallpaperBlur: widget.store.blur,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: GlassCard.hero(
                  glow: GlassGlow(alignment: Alignment.topCenter, color: p.orb1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconBubble(MSym.lock, size: 60, iconSize: 30, fill: 1),
                      const SizedBox(height: 14),
                      Text('Momentum Locked', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text('Enter your PIN to continue', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _pin,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'SpaceMono', fontSize: 24, letterSpacing: 14, color: p.textPrimary),
                        decoration: const InputDecoration(labelText: 'PIN', counterText: ''),
                        onSubmitted: (_) => _verify(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: p.danger)),
                      ],
                      const SizedBox(height: 16),
                      GradientButton(label: 'Unlock', icon: MSym.lockOpen, onPressed: _verify),
                      if (widget.store.biometricEnabled) ...[
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: _biometric,
                          icon: Icon(MSym.fingerprint, size: 20, color: p.accentText),
                          label: Text('Use biometrics', style: TextStyle(color: p.accentText)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NOTIFICATIONS / SELECTIONS / ABOUT
// ============================================================================

class NotificationsPage extends StatefulWidget {
  final Store store;
  const NotificationsPage({super.key, required this.store});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _tasks = true;
  bool _routines = true;
  bool _prayers = true;
  bool _quotes = false;

  @override
  Widget build(BuildContext context) {
    return MomentumScaffold(
      store: widget.store,
      title: 'Notifications',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionHeader('Reminders'),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.taskAlt,
                title: 'Task Reminders',
                subtitle: 'Alerts for scheduled tasks',
                trailing: Switch(value: _tasks, onChanged: (v) => setState(() => _tasks = v)),
              ),
              MomentumRow(
                icon: MSym.eventRepeat,
                title: 'Routine Nudges',
                subtitle: 'Daily rhythm check-ins',
                trailing: Switch(value: _routines, onChanged: (v) => setState(() => _routines = v)),
              ),
              MomentumRow(
                icon: MSym.mosque,
                title: 'Prayer Alerts',
                subtitle: 'Adhan notifications',
                trailing: Switch(value: _prayers, onChanged: (v) => setState(() => _prayers = v)),
              ),
              MomentumRow(
                icon: MSym.spa,
                title: 'Daily Reflection',
                subtitle: 'A mindful quote each morning',
                trailing: Switch(value: _quotes, onChanged: (v) => setState(() => _quotes = v)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(child: Text('Notification delivery follows system settings', style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _SelectionPage extends StatelessWidget {
  final Store store;
  final String title;
  final List<(String, String)> options; // (value, subtitle)
  final String current;
  final Future<void> Function(String) onSelect;
  final IconData icon;
  const _SelectionPage({
    required this.store,
    required this.title,
    required this.options,
    required this.current,
    required this.onSelect,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: store,
      title: title,
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          SettingsGroup(
            children: options.map((o) {
              final selected = o.$1 == current;
              return MomentumRow(
                icon: icon,
                iconColor: selected ? p.primary : p.textSecondary,
                title: o.$1,
                subtitle: o.$2,
                onTap: () async {
                  await onSelect(o.$1);
                  if (context.mounted) Navigator.pop(context);
                },
                trailing: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? p.primary : Colors.transparent,
                    border: Border.all(color: selected ? p.primary : p.textTertiary, width: 2),
                  ),
                  child: selected ? const Icon(MSym.check, size: 14, color: Colors.white, weight: 700) : null,
                ),
              );
            }).toList(),
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
        title: 'Currency',
        icon: MSym.paid,
        current: store.currency,
        options: const [('AFN', 'Afghan Afghani ؋'), ('USD', 'US Dollar \$'), ('EUR', 'Euro €')],
        onSelect: (v) => store.setProfile(
          currency: v,
          currencySymbol: v == 'AFN' ? '؋' : (v == 'USD' ? '\$' : '€'),
        ),
      );
}

class TimezoneSelectionPage extends StatelessWidget {
  final Store store;
  const TimezoneSelectionPage({super.key, required this.store});
  @override
  Widget build(BuildContext context) => _SelectionPage(
        store: store,
        title: 'Timezone',
        icon: MSym.schedule,
        current: store.timezone,
        options: const [
          ('Asia/Kabul', 'UTC+4:30 — Afghanistan'),
          ('Asia/Dubai', 'UTC+4:00 — United Arab Emirates'),
          ('Asia/Karachi', 'UTC+5:00 — Pakistan'),
        ],
        onSelect: (v) => store.setProfile(timezone: v),
      );
}

class CitySelectionPage extends StatelessWidget {
  final Store store;
  const CitySelectionPage({super.key, required this.store});
  @override
  Widget build(BuildContext context) => _SelectionPage(
        store: store,
        title: 'City',
        icon: MSym.locationOn,
        current: store.city,
        options: const [
          ('Kabul', 'Capital of Afghanistan'),
          ('Herat', 'Western Afghanistan'),
          ('Mazar-e-Sharif', 'Northern Afghanistan'),
          ('Kandahar', 'Southern Afghanistan'),
        ],
        onSelect: (v) => store.setProfile(city: v),
      );
}

class AboutPage extends StatelessWidget {
  final Store store;
  const AboutPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MomentumScaffold(
      store: store,
      title: 'About',
      showBack: true,
      body: ListView(
        padding: pagePadding(context),
        children: [
          GlassCard.hero(
            glow: GlassGlow(alignment: Alignment.topCenter, color: p.orb1),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: p.triGradientDiagonal,
                    boxShadow: p.fabGlow,
                  ),
                  child: const Icon(MSym.allInclusive, size: 34, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Text('MOMENTUM',
                    style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 4, color: p.textPrimary)),
                const SizedBox(height: 4),
                Text('Crafted for intentional living', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Text('v1.0.0',
                    style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, color: p.textTertiary)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SettingsGroup(
            children: [
              MomentumRow(
                icon: MSym.person,
                title: 'Created by',
                subtitle: 'Milad Wardak',
              ),
              MomentumRow(
                icon: MSym.cloudOff,
                title: 'Local-first',
                subtitle: 'All data stays on your device. No accounts, no cloud.',
              ),
              MomentumRow(
                icon: MSym.favorite,
                title: 'Philosophy',
                subtitle: 'Finance, focus and faith — one calm rhythm.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DATE HELPERS & CALENDAR CONVERTERS (logic preserved)
// ============================================================================

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const _hijriMonths = [
  'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani", 'Jumada al-Awwal', 'Jumada al-Thani',
  'Rajab', "Sha'ban", 'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
];

const _jalaliMonths = [
  'Hamal', 'Sawr', 'Jawza', 'Saratan', 'Asad', 'Sunbula',
  'Mizan', 'Aqrab', 'Qaws', 'Jadi', 'Dalw', 'Hut',
];

String _fmtDate(dynamic iso) {
  final d = DateTime.tryParse(iso?.toString() ?? '');
  if (d == null) return '';
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

DateTime _addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day).add(Duration(days: days));

/// Tabular Islamic calendar conversion (astronomical epoch).
(int, int, int) _gregorianToHijri(DateTime date) {
  final jdn = _gregorianToJdn(date.year, date.month, date.day);
  var l = jdn - 1948440 + 10632;
  final n = ((l - 1) / 10631).floor();
  l = l - 10631 * n + 354;
  final j = (((10985 - l) / 5316).floor()) * (((50 * l) / 17719).floor()) + ((l / 5670).floor()) * (((43 * l) / 15238).floor());
  l = l - (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) - ((j / 16).floor()) * (((15238 * j) / 43).floor()) + 29;
  final m = ((24 * l) / 709).floor();
  final d = l - ((709 * m) / 24).floor();
  final y = 30 * n + j - 30;
  return (y, m, d);
}

/// Gregorian → Jalali (Solar Hijri) conversion.
(int, int, int) _gregorianToJalali(DateTime date) {
  final gy = date.year;
  final gm = date.month;
  final gd = date.day;
  final gdm = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
  var jy = gy <= 1600 ? 0 : 979;
  final gy2 = gy <= 1600 ? gy - 621 : gy - 1600;
  final gy3 = gm > 2 ? gy2 + 1 : gy2;
  var days = 365 * gy2 +
      ((gy3 + 3) / 4).floor() -
      ((gy3 + 99) / 100).floor() +
      ((gy3 + 399) / 400).floor() -
      80 +
      gd +
      gdm[gm - 1];
  jy += 33 * (days / 12053).floor();
  days %= 12053;
  jy += 4 * (days / 1461).floor();
  days %= 1461;
  if (days > 365) {
    jy += ((days - 1) / 365).floor();
    days = (days - 1) % 365;
  }
  final jm = days < 186 ? 1 + (days / 31).floor() : 7 + ((days - 186) / 30).floor();
  final jd = 1 + (days < 186 ? days % 31 : (days - 186) % 30);
  return (jy, jm, jd);
}

int _gregorianToJdn(int y, int m, int d) {
  final a = ((14 - m) / 12).floor();
  final yy = y + 4800 - a;
  final mm = m + 12 * a - 3;
  return d + (((153 * mm) + 2) / 5).floor() + 365 * yy + (yy / 4).floor() - (yy / 100).floor() + (yy / 400).floor() - 32045;
}
