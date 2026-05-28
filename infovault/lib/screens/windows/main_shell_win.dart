import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'vault_screen_win.dart';
import 'search_screen_win.dart';
import 'settings_screen_win.dart';

class MainShellWin extends StatefulWidget {
  const MainShellWin({super.key});
  @override
  State<MainShellWin> createState() => _MainShellWinState();
}

class _MainShellWinState extends State<MainShellWin>
    with WidgetsBindingObserver {
  final _storage = const FlutterSecureStorage();
  int _selectedIndex = 0;
  Timer? _autoLockTimer;
  int _lockMinutes = 3;
  bool _autoLockEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLockTime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoLockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLockTime() async {
    final stored = await _storage.read(key: 'auto_lock_minutes');
    if (stored != null && mounted) {
      setState(() => _lockMinutes = int.tryParse(stored) ?? 3);
    }
    if (!mounted) return;
    final enabled = await _storage.read(key: 'auto_lock_enabled');
    if (mounted) {
      setState(() => _autoLockEnabled = enabled != 'false');
    }
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
    return NavigationView(
      titleBar: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('信息保险箱',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      pane: NavigationPane(
        selected: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
        displayMode: PaneDisplayMode.auto,
        size: const NavigationPaneSize(
          openWidth: 240,
        ),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.shield),
            title: const Text('信息保险箱'),
            body: const VaultScreenWin(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.search),
            title: const Text('搜索'),
            body: const SearchScreenWin(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.contact),
            title: const Text('我的'),
            body: const SettingsScreenWin(),
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItemAction(
            icon: const Icon(FluentIcons.lock),
            title: const Text('锁定'),
            onTap: () => context.read<AuthService>().lock(),
          ),
        ],
      ),
    );
  }
}
