import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import '../../models/item_type.dart';
import '../../widgets/type_icon.dart';

Future<ItemType?> showAddItemTypeDialog(BuildContext context) {
  return showDialog<ItemType>(
    context: context,
    builder: (context) => fluent.ContentDialog(
      title: const Text('选择类型'),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ItemType.values.map((type) => _TypeCard(
            type: type,
            onTap: () => Navigator.pop(context, type),
          )).toList(),
        ),
      ),
      actions: [
        fluent.Button(
          child: const Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

class _TypeCard extends StatelessWidget {
  final ItemType type;
  final VoidCallback onTap;

  const _TypeCard({required this.type, required this.onTap});

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
      case ItemType.password:   return const Color(0xFFEFF6FF);
      case ItemType.bankCard:   return const Color(0xFFFFF7ED);
      case ItemType.idDocument: return const Color(0xFFECFDF5);
      case ItemType.secureNote: return const Color(0xFFF5F3FF);
      case ItemType.apiKey:    return const Color(0xFFF3F0FF);
    }
  }

  Color _borderColor() {
    switch (type) {
      case ItemType.password:   return const Color(0xFF3B82F6);
      case ItemType.bankCard:   return const Color(0xFFF59E0B);
      case ItemType.idDocument: return const Color(0xFF10B981);
      case ItemType.secureNote: return const Color(0xFF8B5CF6);
      case ItemType.apiKey:    return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = fluent.FluentTheme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: _bgColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor().withAlpha(isDark ? 80 : 100), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TypeIcon(type: type, size: 40),
            const SizedBox(height: 8),
            Text(type.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? _borderColor().withAlpha(200) : _borderColor(),
                )),
          ],
        ),
      ),
    );
  }
}
