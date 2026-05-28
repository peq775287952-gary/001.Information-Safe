import 'package:flutter/material.dart';
import '../models/item_type.dart';
import '../theme/app_theme.dart';

class TypeIcon extends StatelessWidget {
  final ItemType type;
  final double size;

  const TypeIcon({super.key, required this.type, this.size = 36});

  IconData get _iconData {
    switch (type) {
      case ItemType.password:   return Icons.lock_rounded;
      case ItemType.bankCard:   return Icons.credit_card_rounded;
      case ItemType.idDocument: return Icons.badge_rounded;
      case ItemType.secureNote: return Icons.note_alt_rounded;
      case ItemType.apiKey:    return Icons.smart_toy_rounded;
    }
  }

  Color _bgColor(bool isDark) {
    if (isDark) {
      switch (type) {
        case ItemType.password:   return const Color(0xFF1E2A3A);
        case ItemType.bankCard:   return const Color(0xFF2A2318);
        case ItemType.idDocument: return const Color(0xFF1A2E23);
        case ItemType.secureNote: return const Color(0xFF231E2E);
        case ItemType.apiKey:    return const Color(0xFF211E2E);
      }
    }
    switch (type) {
      case ItemType.password:   return AppTheme.surfaceBlue;
      case ItemType.bankCard:   return const Color(0xFFFFF7ED);
      case ItemType.idDocument: return const Color(0xFFECFDF5);
      case ItemType.secureNote: return const Color(0xFFF5F3FF);
      case ItemType.apiKey:    return const Color(0xFFF3F0FF);
    }
  }

  Color get _iconColor {
    switch (type) {
      case ItemType.password:   return AppTheme.passwordAccent;
      case ItemType.bankCard:   return AppTheme.bankAccent;
      case ItemType.idDocument: return AppTheme.idAccent;
      case ItemType.secureNote: return AppTheme.noteAccent;
      case ItemType.apiKey:    return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _bgColor(isDark),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(_iconData, size: size * 0.55, color: _iconColor),
    );
  }
}
