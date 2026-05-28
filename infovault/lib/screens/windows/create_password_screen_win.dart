import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

class CreatePasswordScreenWin extends StatefulWidget {
  const CreatePasswordScreenWin({super.key});
  @override
  State<CreatePasswordScreenWin> createState() =>
      _CreatePasswordScreenWinState();
}

class _CreatePasswordScreenWinState extends State<CreatePasswordScreenWin> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = fluent.TextEditingController();
  final _confirmController = fluent.TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final pwd = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    final pwdErr = Validators.masterPassword(pwd);
    if (pwdErr != null) {
      setState(() => _errorText = pwdErr);
      return;
    }
    if (pwd != confirm) {
      setState(() => _errorText = '两次密码不一致');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await context.read<AuthService>().setMasterPassword(pwd);
    } catch (e) {
      if (mounted) {
        setState(() => _errorText = '创建失败: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = fluent.FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return fluent.ScaffoldPage(
      content: Center(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 64, color: Color(0xFF1565C0)),
                const SizedBox(height: 16),
                Text('创建主密码',
                    style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    )),
                const SizedBox(height: 8),
                Text(
                  '这是你解锁信息保险箱的唯一凭证\n忘记后数据将无法恢复',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 32),
                fluent.TextBox(
                  controller: _passwordController,
                  placeholder: '主密码（至少4位字符）',
                  obscureText: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),
                fluent.TextBox(
                  controller: _confirmController,
                  placeholder: '确认主密码',
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
                  width: double.infinity,
                  height: 48,
                  child: fluent.FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: fluent.ProgressRing(strokeWidth: 2))
                        : const Text('创建并进入'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
