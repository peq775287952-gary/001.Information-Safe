import 'package:flutter/material.dart';
import '../models/folder.dart';

class FolderFilterBar extends StatelessWidget {
  final List<Folder> folders;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final VoidCallback onAddFolder;

  const FolderFilterBar({
    super.key,
    required this.folders,
    required this.selectedId,
    required this.onSelected,
    required this.onAddFolder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FolderChip(
            label: '📁 全部',
            isSelected: selectedId.isEmpty,
            onTap: () => onSelected(''),
          ),
          ...folders.map((f) => _FolderChip(
                label: f.name,
                isSelected: selectedId == f.id,
                onTap: () => onSelected(f.id),
              )),
          GestureDetector(
            onTap: onAddFolder,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                label: Text('+ 新建', style: TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FolderChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
    );
  }
}
