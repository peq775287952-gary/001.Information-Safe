import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../../services/vault_service.dart';

class FolderManagementScreenWin extends StatelessWidget {
  const FolderManagementScreenWin({super.key});

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      header: const fluent.PageHeader(title: Text('管理文件夹')),
      content: Consumer<VaultService>(
        builder: (context, vault, _) {
          return ListView.builder(
            itemCount: vault.folders.length,
            itemBuilder: (context, index) {
              final folder = vault.folders[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: fluent.Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(fluent.FluentIcons.folder, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(folder.name,
                              style: const TextStyle(fontSize: 15)),
                        ),
                        IconButton(
                          icon: const Icon(fluent.FluentIcons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => fluent.ContentDialog(
                                title: const Text('删除文件夹'),
                                content: Text(
                                    '确定要删除"${folder.name}"吗？文件夹内的条目不会被删除。'),
                                actions: [
                                  fluent.Button(
                                    child: const Text('取消'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  fluent.FilledButton(
                                    child: const Text('删除'),
                                    onPressed: () {
                                      context
                                          .read<VaultService>()
                                          .deleteFolder(folder.id);
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
              );
            },
          );
        },
      ),
    );
  }
}
