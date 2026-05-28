import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

class ChangePasswordScreenWin extends StatefulWidget {
  const ChangePasswordScreenWin({super.key});
  @override
  State<ChangePasswordScreenWin> createState() =>
      _ChangePasswordScreenWinState();
}

class _ChangePasswordScreenWinState extends State<ChangePasswordScreenWin> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = fluent.TextEditingController();
  final _newPasswordController = fluent.TextEditingController();
  final _confirmController = fluent.TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPwd = _oldPasswordController.text.trim();
    final newPwd = _newPasswordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (oldPwd.isEmpty) {
      setState(() => _errorText = '请输入旧密码');
      return;
    }
    final newErr = Validators.newPassword(newPwd, oldPwd);
    if (newErr != null) {
      setState(() => _errorText = newErr);
      return;
    }
    if (newPwd != confirm) {
      setState(() => _errorText = '两次密码不一致');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => fluent.ContentDialog(
        title: const Text('确认修改密码'),
        content: const Text(
          '修改密码后，此前使用旧密码导出的备份文件将无法导入。\n\n'
          '如有需要，请在修改完成后重新导出备份。\n\n'
          '确定继续修改？',
        ),
        actions: [
          fluent.Button(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context, false),
          ),
          fluent.FilledButton(
            child: const Text('确认修改'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });

    final auth = context.read<AuthService>();
    final ok = await auth.changePassword(oldPwd, newPwd);

    if (!mounted) return;

    if (ok) {
      fluent.displayInfoBar(context, builder: (context, close) {
        return fluent.InfoBar(
          title: const Text('密码修改成功'),
          severity: fluent.InfoBarSeverity.success,
          action: IconButton(
            icon: const Icon(fluent.FluentIcons.clear),
            onPressed: close,
          ),
        );
      });
      Navigator.pop(context);
    } else {
      setState(() {
        _loading = false;
        _errorText = '旧密码不正确';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      header: const fluent.PageHeader(title: Text('修改主密码')),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fluent.TextBox(
                controller: _oldPasswordController,
                placeholder: '旧密码',
                obscureText: _obscureOld,
                suffix: IconButton(
                  icon: Icon(_obscureOld
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureOld = !_obscureOld),
                ),
              ),
              const SizedBox(height: 16),
              fluent.TextBox(
                controller: _newPasswordController,
                placeholder: '新密码（至少4位字符）',
                obscureText: _obscureNew,
                suffix: IconButton(
                  icon: Icon(_obscureNew
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              const SizedBox(height: 16),
              fluent.TextBox(
                controller: _confirmController,
                placeholder: '确认新密码',
                obscureText: _obscureConfirm,
                suffix: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(_errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: fluent.FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(_loading ? '修改中...' : '确认修改'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
