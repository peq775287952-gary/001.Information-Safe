import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item_type.dart';
import '../models/folder.dart';
import '../services/vault_service.dart';
import '../widgets/type_filter_bar.dart';
import '../widgets/folder_filter_bar.dart';
import '../widgets/item_list_tile.dart';
import '../widgets/type_icon.dart';
import '../widgets/staggered_list.dart';
import 'add_edit_item_screen.dart';
import 'item_detail_screen.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VaultService>(
      builder: (context, vault, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
          appBar: AppBar(title: const Text('信息保险箱')),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索平台名、用户名、卡号...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withAlpha(100),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (q) => vault.setSearchQuery(q),
                ),
              ),
              // Type filter
              TypeFilterBar(
                selected: vault.selectedType,
                counts: vault.getTypeCounts(),
                onSelected: (type) => vault.setTypeFilter(type),
              ),
              const SizedBox(height: 4),
              // Folder filter
              FolderFilterBar(
                folders: vault.folders,
                selectedId: vault.selectedFolderId,
                onSelected: (id) => vault.setFolderFilter(id),
                onAddFolder: () => _showAddFolderDialog(context),
              ),
              const SizedBox(height: 8),
              // Item list
              Expanded(
                child: vault.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            Text('还没有任何条目',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: vault.items.length,
                        itemBuilder: (context, index) {
                          final item = vault.items[index];
                          return StaggeredItem(
                            index: index,
                            child: ItemListTile(
                              item: item,
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ItemDetailScreen(itemId: item.id),
                                  ),
                                ).then((_) {
                                  if (context.mounted) {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTypeSheet(context),
            child: const Icon(Icons.add),
          ),
          ),
        );
      },
    );
  }

  void _showAddTypeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('选择类型',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              for (final type in ItemType.values)
                ListTile(
                  leading: TypeIcon(type: type, size: 32),
                  title: Text(type.label),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditItemScreen(itemType: type),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新建文件夹'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '文件夹名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context
                    .read<VaultService>()
                    .addFolder(Folder(id: '', name: controller.text.trim()));
                Navigator.pop(context);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}
