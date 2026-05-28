import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LockScreenWin extends StatefulWidget {
  const LockScreenWin({super.key});
  @override
  State<LockScreenWin> createState() => _LockScreenWinState();
}

class _LockScreenWinState extends State<LockScreenWin> {
  final _passwordController = fluent.TextEditingController();
  String? _errorText;
  bool _isChecking = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_passwordController.text.isEmpty) return;

    setState(() => _isChecking = true);
    final auth = context.read<AuthService>();
    final ok = await auth.verifyMasterPassword(_passwordController.text.trim());
    if (!mounted) return;

    setState(() => _isChecking = false);

    if (!ok) {
      setState(() {
        _errorText = auth.isLockedOut
            ? '错误次数过多，请5分钟后重试'
            : '主密码错误，请重试 (${auth.failedAttempts}次)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isLocked = auth.isLockedOut;
    final theme = fluent.FluentTheme.of(context);

    return fluent.ScaffoldPage(
      content: Center(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 64, color: Color(0xFF1565C0)),
              const SizedBox(height: 16),
              Text('信息保险箱',
                  style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white : const Color(0xFF0F172A),
                  )),
              const SizedBox(height: 8),
              Text('请输入主密码解锁',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  )),
              const SizedBox(height: 32),
              fluent.TextBox(
                controller: _passwordController,
                placeholder: '主密码',
                obscureText: true,
                enabled: !isLocked && !_isChecking,
                onSubmitted: (_) => _unlock(),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(_errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: fluent.FilledButton(
                  onPressed: isLocked || _isChecking ? null : _unlock,
                  child: _isChecking
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: fluent.ProgressRing(strokeWidth: 2))
                      : const Text('解锁'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
