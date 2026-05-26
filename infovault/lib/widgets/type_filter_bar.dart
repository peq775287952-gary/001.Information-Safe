import 'package:flutter/material.dart';
import '../models/item_type.dart';

class TypeFilterBar extends StatelessWidget {
  final ItemType? selected;
  final Map<ItemType, int> counts;
  final ValueChanged<ItemType?> onSelected;

  const TypeFilterBar({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold<int>(0, (s, c) => s + c);
    final items = <_FilterItem>[
      _FilterItem(icon: null, label: '全部', count: total, type: null),
      for (final type in ItemType.values)
        _FilterItem(
          icon: type.icon,
          label: type.label,
          count: counts[type] ?? 0,
          type: type,
        ),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.type == selected;
          return FilterChip(
            label: Text(
              '${item.icon ?? ''} ${item.label} ${item.count}',
              style: const TextStyle(fontSize: 12),
            ),
            selected: isSelected,
            onSelected: (_) => onSelected(item.type),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

class _FilterItem {
  final String? icon;
  final String label;
  final int count;
  final ItemType? type;
  const _FilterItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.type,
  });
}
