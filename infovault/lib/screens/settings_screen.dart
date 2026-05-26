import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/vault_service.dart';
import '../services/export_import_service.dart';
import 'folder_management_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    setState(() => _autoLockEnabled = enabled);
  }

  Future<void> _setClipboard(bool enabled) async {
    await _storage.write(key: 'clipboard_enabled', value: enabled.toString());
    setState(() => _clipboardEnabled = enabled);
  }

  Future<void> _setAutoLock(int minutes) async {
    await _storage.write(key: _lockTimeKey, value: minutes.toString());
    setState(() => _autoLockMinutes = minutes);
    if (mounted) Navigator.pop(context);
  }

  void _showAutoLockPicker() {
    final options = [1, 3, 5, 10, 15, 30];
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('选择自动锁定时间'),
        children: [
          RadioGroup<int>(
            groupValue: _autoLockMinutes,
            onChanged: (v) { if (v != null) _setAutoLock(v); },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final m in options)
                  RadioListTile<int>(
                    title: Text('$m 分钟'),
                    value: m,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('关于信息保险箱'),
        content: Text('信息保险箱 v$_version\n\n'
            '你的个人信息安全管家。\n'
            'AES-256-GCM 加密，数据仅存本地。\n\n'
            '作者：N7\n\n'
            'Flutter ${Platform.operatingSystem}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
        ],
      ),
    );
  }

  void _showSecurityInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('安全说明'),
        content: const Text('🔐 你的数据如何被保护：\n\n'
            '• 主密码通过 PBKDF2（10万次迭代）派生出 AES-256-GCM 加密密钥\n'
            '• 所有数据以密文形式储存，密钥仅存于设备安全区域\n'
            '• 复制到剪贴板的敏感信息 60 秒后自动清空\n'
            '• 忘记主密码 = 数据永久无法恢复\n\n'
            '⚠️ 请务必记住你的主密码！'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('我知道了')),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    final vault = context.read<VaultService>();
    final key = vault.encryptionKey;
    if (key == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final exportService = context.read<ExportImportService>();

    try {
      final path = await exportService.exportData(key);
      if (!mounted) return;
      if (path != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('备份已导出到: $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('导出失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _importData() async {
    final vault = context.read<VaultService>();
    final key = vault.encryptionKey;
    if (key == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final exportService = context.read<ExportImportService>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认导入'),
        content: const Text('导入备份将覆盖同名数据，确定继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('导入')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final count = await exportService.importData(key);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('成功导入 $count 条记录')),
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('导入失败: 文件格式不正确或密钥不匹配'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          const _SectionHeader(title: '安全'),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: const Text('自动锁定'),
            subtitle: Text(_autoLockEnabled
                ? '切换到后台 $_autoLockMinutes 分钟后锁定'
                : '关闭后不会自动锁定'),
            value: _autoLockEnabled,
            onChanged: _setAutoLockEnabled,
          ),
          if (_autoLockEnabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('锁定时间'),
              trailing: Text('$_autoLockMinutes 分钟'),
              onTap: _showAutoLockPicker,
            ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('剪贴板自动清空'),
            subtitle: const Text('复制后60秒自动清空'),
            trailing: Switch(value: _clipboardEnabled, onChanged: _setClipboard),
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('修改主密码'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          const Divider(),
          const _SectionHeader(title: '数据'),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('管理文件夹'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FolderManagementScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('导出数据'),
            subtitle: const Text('导出加密备份文件'),
            onTap: () => _exportData(),
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('导入数据'),
            subtitle: const Text('从备份文件恢复'),
            onTap: () => _importData(),
          ),
          const Divider(),
          const _SectionHeader(title: '关于'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于信息保险箱'),
            subtitle: Text(_version.isNotEmpty ? '版本 $_version' : '版本加载中...'),
            onTap: _showAbout,
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('安全说明'),
            subtitle: const Text('了解你的数据如何被保护'),
            onTap: _showSecurityInfo,
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () => context.read<AuthService>().lock(),
              child: const Text('🔒  立即锁定', style: TextStyle(color: Colors.red)),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      )),
    );
  }
}
