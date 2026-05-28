import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/vault_service.dart';
import '../../services/export_import_service.dart';
import 'folder_management_screen_win.dart';
import 'change_password_screen_win.dart';

class SettingsScreenWin extends StatefulWidget {
  const SettingsScreenWin({super.key});
  @override
  State<SettingsScreenWin> createState() => _SettingsScreenWinState();
}

class _SettingsScreenWinState extends State<SettingsScreenWin> {
  final _storage = const FlutterSecureStorage();
  static const _lockTimeKey = 'auto_lock_minutes';
  static const _lockEnabledKey = 'auto_lock_enabled';
  int _autoLockMinutes = 3;
  bool _autoLockEnabled = true;
  bool _clipboardEnabled = true;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final stored = await _storage.read(key: _lockTimeKey);
    if (stored != null) {
      setState(() => _autoLockMinutes = int.tryParse(stored) ?? 3);
    }
    final enabled = await _storage.read(key: _lockEnabledKey);
    setState(() => _autoLockEnabled = enabled != 'false');
    final pkg = await PackageInfo.fromPlatform();
    setState(() => _version = pkg.version);
  }

  Future<void> _setAutoLockEnabled(bool enabled) async {
    await _storage.write(key: _lockEnabledKey, value: enabled.toString());
    if (!mounted) return;
    setState(() => _autoLockEnabled = enabled);
  }

  Future<void> _setClipboard(bool enabled) async {
    await _storage.write(key: 'clipboard_enabled', value: enabled.toString());
    if (!mounted) return;
    setState(() => _clipboardEnabled = enabled);
  }

  Future<void> _setAutoLock(int minutes) async {
    await _storage.write(key: _lockTimeKey, value: minutes.toString());
    if (!mounted) return;
    setState(() => _autoLockMinutes = minutes);
    if (mounted) Navigator.pop(context);
  }

  void _showAutoLockPicker() {
    final options = [1, 3, 5, 10, 15, 30];
    showDialog(
      context: context,
      builder: (_) => fluent.ContentDialog(
        title: const Text('选择自动锁定时间'),
        content: fluent.RadioGroup<int>(
          groupValue: _autoLockMinutes,
          onChanged: (v) { if (v != null) _setAutoLock(v); },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final m in options)
                fluent.RadioButton<int>(
                  value: m,
                  content: Text('$m 分钟'),
                ),
            ],
          ),
        ),
        actions: [
          fluent.Button(
            child: const Text('关闭'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => fluent.ContentDialog(
        title: const Text('关于信息保险箱'),
        content: Text('信息保险箱 v$_version\n\n'
            '你的个人信息安全管家。\n'
            'AES-256-GCM 加密，数据仅存本地。\n\n'
            '作者：N7\n\n'
            'Flutter ${Platform.operatingSystem}'),
        actions: [
          fluent.Button(
            child: const Text('关闭'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSecurityInfo() {
    showDialog(
      context: context,
      builder: (_) => fluent.ContentDialog(
        title: const Text('安全说明'),
        content: const Text('🔐 你的数据如何被保护：\n\n'
            '• 主密码通过 PBKDF2（10万次迭代）派生出 AES-256-GCM 加密密钥\n'
            '• 所有数据以密文形式储存，密钥仅存于设备安全区域\n'
            '• 复制到剪贴板的敏感信息 60 秒后自动清空\n'
            '• 忘记主密码 = 数据永久无法恢复\n\n'
            '⚠️ 请务必记住你的主密码！'),
        actions: [
          fluent.Button(
            child: const Text('我知道了'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    final vault = context.read<VaultService>();
    final key = vault.encryptionKey;
    if (key == null) return;

    final exportService = context.read<ExportImportService>();

    try {
      final path = await exportService.exportData(key);
      if (!mounted) return;
      if (path != null) {
        _showInfoBar('备份已导出到: $path', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showInfoBar('导出失败: $e', isError: true);
      }
    }
  }

  Future<void> _importData() async {
    final vault = context.read<VaultService>();
    final key = vault.encryptionKey;
    if (key == null) return;

    final exportService = context.read<ExportImportService>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => fluent.ContentDialog(
        title: const Text('确认导入'),
        content: const Text('导入备份将覆盖同名数据，确定继续？'),
        actions: [
          fluent.Button(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context, false),
          ),
          fluent.FilledButton(
            child: const Text('导入'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final count = await exportService.importData(key);
      if (!mounted) return;
      _showInfoBar('成功导入 $count 条记录', isError: false);
    } catch (e) {
      if (mounted) {
        _showInfoBar('导入失败: 文件格式不正确或密钥不匹配', isError: true);
      }
    }
  }

  void _showInfoBar(String message, {required bool isError}) {
    if (!mounted) return;
    fluent.displayInfoBar(context, builder: (context, close) {
      return fluent.InfoBar(
        title: Text(message),
        severity: isError ? fluent.InfoBarSeverity.error : fluent.InfoBarSeverity.success,
        action: IconButton(
          icon: const Icon(fluent.FluentIcons.clear),
          onPressed: close,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = fluent.FluentTheme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return fluent.ScaffoldPage(
      header: const fluent.PageHeader(title: Text('我的')),
      content: ListView(
        children: [
          _SectionHeader(title: '安全'),
          _SettingsTile(
            icon: fluent.FluentIcons.lock,
            title: '自动锁定',
            subtitle: _autoLockEnabled
                ? '切换到后台 $_autoLockMinutes 分钟后锁定'
                : '关闭后不会自动锁定',
            trailing: fluent.ToggleSwitch(
              checked: _autoLockEnabled,
              onChanged: _setAutoLockEnabled,
            ),
          ),
          if (_autoLockEnabled)
            _SettingsTile(
              icon: fluent.FluentIcons.clock,
              title: '锁定时间',
              trailing: Text('$_autoLockMinutes 分钟',
                  style: TextStyle(color: mutedColor)),
              onTap: _showAutoLockPicker,
            ),
          _SettingsTile(
            icon: fluent.FluentIcons.history,
            title: '剪贴板自动清空',
            subtitle: '复制后30秒自动清空',
            trailing: fluent.ToggleSwitch(
              checked: _clipboardEnabled,
              onChanged: _setClipboard,
            ),
          ),
          _SettingsTile(
            icon: fluent.FluentIcons.sync,
            title: '修改主密码',
            trailing: Icon(fluent.FluentIcons.chevron_right, size: 16, color: mutedColor),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreenWin()),
            ),
          ),

          const SizedBox(height: 8),
          _SectionHeader(title: '数据'),
          _SettingsTile(
            icon: fluent.FluentIcons.folder,
            title: '管理文件夹',
            trailing: Icon(fluent.FluentIcons.chevron_right, size: 16, color: mutedColor),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FolderManagementScreenWin()),
            ),
          ),
          _SettingsTile(
            icon: fluent.FluentIcons.upload,
            title: '导出数据',
            subtitle: '导出加密备份文件',
            trailing: Icon(fluent.FluentIcons.chevron_right, size: 16, color: mutedColor),
            onTap: _exportData,
          ),
          _SettingsTile(
            icon: fluent.FluentIcons.download,
            title: '导入数据',
            subtitle: '从备份文件恢复',
            trailing: Icon(fluent.FluentIcons.chevron_right, size: 16, color: mutedColor),
            onTap: _importData,
          ),

          const SizedBox(height: 8),
          _SectionHeader(title: '关于'),
          _SettingsTile(
            icon: fluent.FluentIcons.info,
            title: '关于信息保险箱',
            subtitle: _version.isNotEmpty ? '版本 $_version' : '版本加载中...',
            trailing: Icon(fluent.FluentIcons.chevron_right, size: 16, color: mutedColor),
            onTap: _showAbout,
          ),
          _SettingsTile(
            icon: fluent.FluentIcons.shield,
            title: '安全说明',
            subtitle: '了解你的数据如何被保护',
            trailing: Icon(fluent.FluentIcons.chevron_right, size: 16, color: mutedColor),
            onTap: _showSecurityInfo,
          ),

          const SizedBox(height: 24),
          Center(
            child: fluent.Button(
              child: const Text('🔒  立即锁定', style: TextStyle(color: Colors.red)),
              onPressed: () => context.read<AuthService>().lock(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
      child: Text(title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.accentColor.normal,
          )),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = fluent.FluentTheme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: fluent.Card(
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: mutedColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(fontSize: 15, color: textColor)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: TextStyle(fontSize: 12, color: mutedColor)),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
