import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../../models/item_type.dart';
import '../../models/folder.dart';
import '../../services/vault_service.dart';
import '../../widgets/platform_icon.dart';
import 'add_item_dialog.dart';
import 'add_edit_item_screen_win.dart';
import 'item_detail_screen_win.dart';

class VaultScreenWin extends StatefulWidget {
  const VaultScreenWin({super.key});
  @override
  State<VaultScreenWin> createState() => _VaultScreenWinState();
}

class _VaultScreenWinState extends State<VaultScreenWin> {
  final _searchController = fluent.TextEditingController();
  final _folderController = fluent.TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.keyN, control: true): _NewIntent(),
      },
      child: Actions(
        actions: {
          _NewIntent: CallbackAction<_NewIntent>(
            onInvoke: (_) => _showAddTypeDialog(context),
          ),
        },
        child: Consumer<VaultService>(
      builder: (context, vault, _) {
        return fluent.ScaffoldPage(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toolbar: search + add button
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: fluent.TextBox(
                        controller: _searchController,
                        placeholder: '搜索平台名、用户名、卡号...',
                        onChanged: (q) => vault.setSearchQuery(q),
                      ),
                    ),
                    const SizedBox(width: 8),
                    fluent.FilledButton(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(fluent.FluentIcons.add, size: 16),
                            SizedBox(width: 6),
                            Text('添加'),
                          ],
                        ),
                      ),
                      onPressed: () => _showAddTypeDialog(context),
                    ),
                  ],
                ),
              ),
              // Type filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    _buildTypeChip(context, null, '全部', vault.selectedType == null,
                        vault.items.length),
                    for (final type in ItemType.values)
                      _buildTypeChip(context, type, type.label,
                          vault.selectedType == type,
                          vault.getTypeCounts()[type] ?? 0),
                  ],
                ),
              ),
              // Folder filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  children: [
                    _buildFolderChip(context, '', '全部文件夹',
                        vault.selectedFolderId == ''),
                    for (final folder in vault.folders)
                      _buildFolderChip(context, folder.id, folder.name,
                          vault.selectedFolderId == folder.id),
                    _buildFolderChip(context, 'new', '+ 新建', false,
                        onTap: () => _showAddFolderDialog(context, vault)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Item list
              Expanded(
                child: vault.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(fluent.FluentIcons.inbox,
                                size: 64, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 8),
                            Text('还没有任何条目',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: vault.items.length,
                        itemBuilder: (context, index) {
                          final item = vault.items[index];
                          return _ItemCard(
                            item: item,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ItemDetailScreenWin(itemId: item.id),
                                ),
                              );
                            },
                            onDelete: () => vault.deleteItem(item.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    ),
        ),
      );
  }

  Widget _buildTypeChip(BuildContext context, ItemType? type, String label,
      bool selected, int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: fluent.ToggleButton(
        checked: selected,
        onChanged: (_) {
          final vault = context.read<VaultService>();
          vault.setTypeFilter(selected ? null : type);
        },
        child: Text('$label ($count)'),
      ),
    );
  }

  Widget _buildFolderChip(BuildContext context, String folderId, String label,
      bool selected,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: fluent.ToggleButton(
        checked: selected,
        onChanged: (_) {
          if (onTap != null) {
            onTap();
          } else {
            context.read<VaultService>().setFolderFilter(folderId);
          }
        },
        child: Text(label),
      ),
    );
  }

  void _showAddTypeDialog(BuildContext context) async {
    final type = await showAddItemTypeDialog(context);
    if (type != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEditItemScreenWin(itemType: type),
        ),
      );
    }
  }

  void _showAddFolderDialog(BuildContext context, VaultService vault) {
    showDialog(
      context: context,
      builder: (_) => fluent.ContentDialog(
        title: const Text('新建文件夹'),
        content: SizedBox(
          height: 36,
          child: fluent.TextBox(
            controller: _folderController,
            placeholder: '文件夹名称',
          ),
        ),
        actions: [
          fluent.Button(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          fluent.FilledButton(
            child: const Text('创建'),
            onPressed: () {
              if (_folderController.text.trim().isNotEmpty) {
                vault.addFolder(
                    Folder(id: '', name: _folderController.text.trim()));
                _folderController.clear();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = fluent.FluentTheme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: GestureDetector(
        onTap: onTap,
        child: fluent.Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                PlatformIcon(item: item, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                )),
                          ),
                          if (item.folderName != null && item.folderName!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF3B82F6).withAlpha(80) : const Color(0xFF2563EB).withAlpha(80),
                                ),
                              ),
                              child: Text(item.folderName!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                                  )),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(item.type.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          )),
                      if (item.username != null && item.username!.isNotEmpty)
                        Text(item.username!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            )),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(fluent.FluentIcons.delete,
                      color: isDark ? Colors.red[300] : Colors.red,
                      size: 18),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => fluent.ContentDialog(
                        title: const Text('确认删除'),
                        content: const Text('确定要删除这个条目吗？'),
                        actions: [
                          fluent.Button(
                            child: const Text('取消'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          fluent.FilledButton(
                            child: const Text('删除'),
                            onPressed: () {
                              onDelete();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewIntent extends Intent {
  const _NewIntent();
}
