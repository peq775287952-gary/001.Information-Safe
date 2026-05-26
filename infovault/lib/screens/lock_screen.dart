import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(Theme.of(context).brightness),
      child: Scaffold(
        body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 64, color: Color(0xFF1565C0)),
                const SizedBox(height: 16),
                Text('信息保险箱',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('请输入主密码解锁',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 32),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  enabled: !isLocked && !_isChecking,
                  decoration: InputDecoration(
                    labelText: '主密码',
                    errorText: _errorText,
                    prefixIcon: const Icon(Icons.key),
                  ),
                  onSubmitted: (_) => _unlock(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: isLocked || _isChecking ? null : _unlock,
                    child: _isChecking
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('解锁'),
                  ),
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
