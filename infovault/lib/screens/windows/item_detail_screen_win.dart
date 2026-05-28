import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import '../../models/vault_item.dart';
import '../../models/item_type.dart';
import '../../services/vault_service.dart';
import '../../services/photo_service.dart';
import '../../services/clipboard_service.dart';
import '../../widgets/platform_icon.dart';
import 'add_edit_item_screen_win.dart';

class ItemDetailScreenWin extends StatefulWidget {
  final String itemId;
  const ItemDetailScreenWin({super.key, required this.itemId});
  @override
  State<ItemDetailScreenWin> createState() => _ItemDetailScreenWinState();
}

class _ItemDetailScreenWinState extends State<ItemDetailScreenWin> {
  VaultItem? _item;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _findItem();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _findItem() {
    final vault = context.read<VaultService>();
    _item = vault.items.cast<VaultItem?>().firstWhere(
      (i) => i!.id == widget.itemId,
      orElse: () => null,
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;
    fluent.displayInfoBar(context, builder: (context, close) {
      return fluent.InfoBar(
        title: Text(message),
        severity: fluent.InfoBarSeverity.success,
        action: IconButton(
          icon: const Icon(fluent.FluentIcons.clear),
          onPressed: close,
        ),
      );
    });
  }

  void _copyValue(String? value) {
    if (value == null || value.isEmpty) return;
    ClipboardService.instance.copy(value);
    _showInfo('已复制，30秒后自动清空');
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    if (item == null) {
      return fluent.ScaffoldPage(
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(fluent.FluentIcons.error, size: 48),
              const SizedBox(height: 8),
              const Text('条目未找到或已被删除'),
              const SizedBox(height: 16),
              fluent.Button(
                child: const Text('返回'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = fluent.FluentTheme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final hasPhotos =
        item.type == ItemType.bankCard || item.type == ItemType.idDocument;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(context);
        }
      },
      child: fluent.ScaffoldPage(
        header: fluent.PageHeader(
          leading: fluent.Tooltip(
            message: '返回',
            child: fluent.IconButton(
              icon: const Icon(fluent.FluentIcons.back, size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(item.title),
          commandBar: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(fluent.FluentIcons.edit),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditItemScreenWin(
                      itemType: item.type,
                      existingItem: item,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(fluent.FluentIcons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(),
              ),
            ],
          ),
        ),
        content: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  PlatformIcon(item: item, size: 56),
                  const SizedBox(height: 8),
                  Text(item.title,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                  if (item.folderName != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Color(0xFF2563EB).withAlpha(80)),
                      ),
                      child: Text(item.folderName!,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Fields
            ..._buildFields(item, textColor, mutedColor),
            // Photos
            if (hasPhotos && item.photoPaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              _PhotoGridWin(photoPaths: item.photoPaths),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFields(
      VaultItem item, Color textColor, Color mutedColor) {
    return <Widget>[
      if (item.type == ItemType.password) ...[
        _FieldRowWin(label: '用户名', value: item.username,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '密码', value: item.password, isPassword: true,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '邮箱', value: item.email,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '手机号', value: item.phone,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '网址', value: item.url,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '备注', value: item.notes,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
      ],
      if (item.type == ItemType.bankCard) ...[
        _FieldRowWin(label: '银行', value: item.bankName,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '卡号', value: item.cardNumber, isPassword: true,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '持卡人', value: item.cardHolder,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '有效期', value: item.expiryDate,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: 'CVV', value: item.cvv, isPassword: true,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '取款密码', value: item.withdrawalPassword,
            isPassword: true, textColor: textColor, mutedColor: mutedColor,
            onCopy: _copyValue),
        _FieldRowWin(label: '备注', value: item.notes,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
      ],
      if (item.type == ItemType.idDocument) ...[
        _FieldRowWin(label: '类型', value: item.idType,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '证件号', value: item.idNumber, isPassword: true,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '姓名', value: item.idName,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '签发机关', value: item.issuingAuthority,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '有效期', value: item.validUntil,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '备注', value: item.notes,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
      ],
      if (item.type == ItemType.apiKey) ...[
        _FieldRowWin(label: '供应商', value: item.title,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: 'API Key', value: item.apiKey, isPassword: true,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '接口地址', value: item.baseUrl,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '模型', value: item.modelName,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
        _FieldRowWin(label: '备注', value: item.notes,
            textColor: textColor, mutedColor: mutedColor, onCopy: _copyValue),
      ],
      if (item.type == ItemType.secureNote) ...[
        fluent.Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(item.noteContent ?? ''),
          ),
        ),
      ],
    ];
  }

  void _confirmDelete() {
    final item = _item;
    if (item == null) return;
    showDialog(
      context: context,
      builder: (_) => fluent.ContentDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${item.title}"吗？此操作不可撤销。'),
        actions: [
          fluent.Button(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          fluent.FilledButton(
            child: const Text('删除'),
            onPressed: () {
              context.read<VaultService>().deleteItem(item.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _FieldRowWin extends StatelessWidget {
  final String label;
  final String? value;
  final bool isPassword;
  final Color textColor;
  final Color mutedColor;
  final void Function(String?) onCopy;

  const _FieldRowWin({
    required this.label,
    required this.value,
    this.isPassword = false,
    required this.textColor,
    required this.mutedColor,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: TextStyle(color: mutedColor, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PasswordFieldWin(
                value: value!, isPassword: isPassword, textColor: textColor),
          ),
          IconButton(
            icon: const Icon(fluent.FluentIcons.copy, size: 16),
            onPressed: () => onCopy(value),
          ),
        ],
      ),
    );
  }
}

class _PasswordFieldWin extends StatefulWidget {
  final String value;
  final bool isPassword;
  final Color textColor;
  const _PasswordFieldWin(
      {required this.value,
      required this.isPassword,
      required this.textColor});
  @override
  State<_PasswordFieldWin> createState() => _PasswordFieldWinState();
}

class _PasswordFieldWinState extends State<_PasswordFieldWin> {
  bool _obscured = true;
  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isPassword
          ? () => setState(() => _obscured = !_obscured)
          : null,
      child: Text(
        widget.isPassword && _obscured ? '••••••••' : widget.value,
        style: TextStyle(fontWeight: FontWeight.w500, color: widget.textColor),
      ),
    );
  }
}

class _PhotoGridWin extends StatelessWidget {
  final List<String> photoPaths;
  const _PhotoGridWin({required this.photoPaths});

  @override
  Widget build(BuildContext context) {
    return fluent.Card(
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
                itemBuilder: (ctx, index) =>
                    _PhotoThumbWin(path: photoPaths[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbWin extends StatelessWidget {
  final String path;
  const _PhotoThumbWin({required this.path});

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultService>();
    final key = vault.encryptionKey;
    if (key == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showFullScreen(context, path, key),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 80,
          height: 80,
          child: FutureBuilder<Uint8List?>(
            future: context.read<PhotoService>().load(path, key),
            builder: (ctx, snap) {
              if (snap.hasData && snap.data != null) {
                return Image.memory(snap.data!, fit: BoxFit.cover);
              }
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: fluent.ProgressRing(strokeWidth: 2)));
              }
              return Container(
                color: const Color(0xFFE2E8F0),
                child:
                    const Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFullScreen(
      BuildContext context, String path, Uint8List encryptionKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenPhotoWin(
            path: path, encryptionKey: encryptionKey),
      ),
    );
  }
}

class _FullScreenPhotoWin extends StatelessWidget {
  final String path;
  final Uint8List encryptionKey;
  const _FullScreenPhotoWin(
      {required this.path, required this.encryptionKey});

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      header: const fluent.PageHeader(),
      content: Center(
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
              return const fluent.ProgressRing();
            }
            return const Icon(Icons.broken_image, color: Colors.white54, size: 64);
          },
        ),
      ),
    );
  }
}
