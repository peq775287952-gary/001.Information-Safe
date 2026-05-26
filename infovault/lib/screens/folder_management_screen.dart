import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vault_service.dart';

class FolderManagementScreen extends StatelessWidget {
  const FolderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('管理文件夹')),
      body: Consumer<VaultService>(
        builder: (context, vault, _) {
          return ListView.builder(
            itemCount: vault.folders.length,
            itemBuilder: (context, index) {
              final folder = vault.folders[index];
              return ListTile(
                leading: const Icon(Icons.folder),
                title: Text(folder.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('删除文件夹'),
                        content: Text('确定要删除"${folder.name}"吗？文件夹内的条目不会被删除。'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                          FilledButton(
                            onPressed: () {
                              context.read<VaultService>().deleteFolder(folder.id);
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('删除'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
