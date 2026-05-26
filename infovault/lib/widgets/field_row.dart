import 'package:flutter/material.dart';
import '../services/clipboard_service.dart';

class FieldRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool isPassword;
  final bool isSensitive;
  final Future<bool> Function()? onRequireAuth;

  const FieldRow({
    super.key,
    required this.label,
    required this.value,
    this.isPassword = false,
    this.isSensitive = false,
    this.onRequireAuth,
  });

  Future<void> _handleCopy(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (isSensitive && onRequireAuth != null) {
      final ok = await onRequireAuth!();
      if (!ok) return;
    }
    if (value == null || value!.isEmpty) return;
    ClipboardService.instance.copy(value!);
    messenger?.showSnackBar(
      const SnackBar(content: Text('已复制，60秒后自动清空'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
          ),
          Expanded(
            child: _PasswordField(value: value!, isPassword: isPassword),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: '复制',
            onPressed: () => _handleCopy(context),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final String value;
  final bool isPassword;
  const _PasswordField({required this.value, required this.isPassword});
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;
  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword;
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isPassword ? () => setState(() => _obscured = !_obscured) : null,
      child: Text(
        widget.isPassword && _obscured ? '••••••••' : widget.value,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
