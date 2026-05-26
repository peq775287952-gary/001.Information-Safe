import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/vault_item.dart';
import '../models/item_type.dart';
import '../services/vault_service.dart';
import '../services/photo_service.dart';
import '../widgets/field_row.dart';
import '../widgets/platform_icon.dart';
import 'add_edit_item_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});
  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late final VaultItem _item;

  @override
  void initState() {
    super.initState();
    final vault = context.read<VaultService>();
    _item = vault.items.firstWhere(
      (i) => i.id == widget.itemId,
      orElse: () => throw StateError('Item not found'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => AddEditItemScreen(itemType: _item.type, existingItem: _item),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, _item),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                PlatformIcon(item: _item, size: 56),
                const SizedBox(height: 8),
                Text(_item.title, style: Theme.of(context).textTheme.headlineSmall),
                if (_item.folderName != null) ...[
                  const SizedBox(height: 4),
                  Chip(label: Text(_item.folderName!, style: const TextStyle(fontSize: 12))),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          ..._buildFields(_item, context),
        ],
      ),
    );
  }

  List<Widget> _buildFields(VaultItem item, BuildContext context) {
    final hasPhotos = item.type == ItemType.bankCard || item.type == ItemType.idDocument;
    return <Widget>[
      if (item.type == ItemType.password) ...[
        FieldRow(label: '用户名', value: item.username),
        FieldRow(label: '密码', value: item.password, isPassword: true),
        FieldRow(label: '邮箱', value: item.email),
        FieldRow(label: '手机号', value: item.phone),
        FieldRow(label: '网址', value: item.url),
        FieldRow(label: '备注', value: item.notes),
      ],
      if (item.type == ItemType.bankCard) ...[
        FieldRow(label: '银行', value: item.bankName),
        FieldRow(label: '卡号', value: item.cardNumber, isPassword: true),
        FieldRow(label: '持卡人', value: item.cardHolder),
        FieldRow(label: '有效期', value: item.expiryDate),
        FieldRow(label: 'CVV', value: item.cvv, isPassword: true),
        FieldRow(label: '取款密码', value: item.withdrawalPassword, isPassword: true),
        FieldRow(label: '备注', value: item.notes),
      ],
      if (item.type == ItemType.idDocument) ...[
        FieldRow(label: '类型', value: item.idType),
        FieldRow(label: '证件号', value: item.idNumber, isPassword: true),
        FieldRow(label: '姓名', value: item.idName),
        FieldRow(label: '签发机关', value: item.issuingAuthority),
        FieldRow(label: '有效期', value: item.validUntil),
        FieldRow(label: '备注', value: item.notes),
      ],
      if (hasPhotos && item.photoPaths.isNotEmpty) ...[
        const SizedBox(height: 16),
        _buildPhotoGrid(item.photoPaths),
      ],
      if (item.type == ItemType.apiKey) ...[
        FieldRow(label: '供应商', value: item.title),
        FieldRow(label: 'API Key', value: item.apiKey, isPassword: true),
        FieldRow(label: '接口地址', value: item.baseUrl),
        FieldRow(label: '模型', value: item.modelName),
        FieldRow(label: '备注', value: item.notes),
      ],
      if (item.type == ItemType.secureNote) ...[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(item.noteContent ?? ''),
          ),
        ),
      ],
    ];
  }

  Widget _buildPhotoGrid(List<String> photoPaths) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('照片附件 (${photoPaths.length})',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photoPaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) => _buildPhotoThumb(photoPaths[index], index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumb(String path, int index) {
    final vault = context.watch<VaultService>();
    final key = vault.encryptionKey;
    if (key == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showFullScreenPhoto(path),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 80, height: 80,
          child: FutureBuilder<Uint8List?>(
            future: context.read<PhotoService>().load(path, key),
            builder: (ctx, snap) {
              if (snap.hasData && snap.data != null) {
                return Image.memory(snap.data!, fit: BoxFit.cover);
              }
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }
              return Container(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                child: Icon(Icons.broken_image,
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFullScreenPhoto(String path) {
    final vault = context.read<VaultService>();
    final key = vault.encryptionKey;
    if (key == null) return;

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _FullScreenPhoto(path: path, encryptionKey: key),
    ));
  }

  void _confirmDelete(BuildContext context, VaultItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${item.title}"吗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              context.read<VaultService>().deleteItem(item.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _FullScreenPhoto extends StatelessWidget {
  final String path;
  final Uint8List encryptionKey;
  const _FullScreenPhoto({required this.path, required this.encryptionKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: FutureBuilder<Uint8List?>(
          future: context.read<PhotoService>().load(path, encryptionKey),
          builder: (ctx, snap) {
            if (snap.hasData && snap.data != null) {
              return InteractiveViewer(
                maxScale: 5,
                child: Image.memory(snap.data!, fit: BoxFit.contain),
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: Colors.white);
            }
            return const Icon(Icons.broken_image, color: Colors.white54, size: 64);
          },
        ),
      ),
    );
  }
}
