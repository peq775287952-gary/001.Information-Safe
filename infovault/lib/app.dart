import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/lock_screen.dart';
import 'screens/create_password_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';

class InfoVaultApp extends StatelessWidget {
  const InfoVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '信息保险箱',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'),
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (!auth.hasMasterPassword) {
            return const CreatePasswordScreen();
          }
          if (!auth.isUnlocked) {
            return const LockScreen();
          }
          return const MainShell();
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  final _storage = const FlutterSecureStorage();
  int _currentIndex = 0;
  Timer? _autoLockTimer;
  int _lockMinutes = 3;
  bool _autoLockEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLockTime();
  }

  Future<void> _loadLockTime() async {
    final stored = await _storage.read(key: 'auto_lock_minutes');
    if (stored != null) {
      setState(() => _lockMinutes = int.tryParse(stored) ?? 3);
    }
    final enabled = await _storage.read(key: 'auto_lock_enabled');
    setState(() => _autoLockEnabled = enabled != 'false');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoLockTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _autoLockEnabled) {
      _autoLockTimer = Timer(Duration(minutes: _lockMinutes), () {
        if (mounted) {
          context.read<AuthService>().lock();
        }
      });
    } else if (state == AppLifecycleState.resumed) {
      _autoLockTimer?.cancel();
      _autoLockTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const VaultScreen(),
      const SearchScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.security), label: '信息保险箱'),
          NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
          NavigationDestination(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
