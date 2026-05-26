import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/vault_item.dart';
import '../models/item_type.dart';
import '../models/folder.dart';
import '../services/vault_service.dart';
import '../services/photo_service.dart';
import '../services/smart_category_service.dart';
import '../utils/validators.dart';
import '../widgets/quick_fill_chips.dart';

class AddEditItemScreen extends StatefulWidget {
  final ItemType itemType;
  final VaultItem? existingItem;

  const AddEditItemScreen({
    super.key,
    required this.itemType,
    this.existingItem,
  });

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryService = SmartCategoryService();
  late final ItemType _type;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _bankNameCtrl;
  late final TextEditingController _cardNumberCtrl;
  late final TextEditingController _cardHolderCtrl;
  late final TextEditingController _expiryDateCtrl;
  late final TextEditingController _cvvCtrl;
  late final TextEditingController _withdrawalPwdCtrl;
  late final TextEditingController _idTypeCtrl;
  late final TextEditingController _idNumberCtrl;
  late final TextEditingController _idNameCtrl;
  late final TextEditingController _issuingAuthorityCtrl;
  late final TextEditingController _validUntilCtrl;
  late final TextEditingController _noteContentCtrl;
  late final TextEditingController _apiKeyCtrl;
  late final TextEditingController _baseUrlCtrl;
  late final TextEditingController _modelNameCtrl;
  late final TextEditingController _notesCtrl;
  String _folderId = '';
  String? _folderName;
  String? _suggestedCategory;
  List<String> _photoPaths = [];

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    _type = widget.itemType;
    final i = widget.existingItem;
    _titleCtrl = TextEditingController(text: i?.title ?? '');
    _usernameCtrl = TextEditingController(text: i?.username ?? '');
    _passwordCtrl = TextEditingController(text: i?.password ?? '');
    _emailCtrl = TextEditingController(text: i?.email ?? '');
    _phoneCtrl = TextEditingController(text: i?.phone ?? '');
    _urlCtrl = TextEditingController(text: i?.url ?? '');
    _bankNameCtrl = TextEditingController(text: i?.bankName ?? '');
    _cardNumberCtrl = TextEditingController(text: i?.cardNumber ?? '');
    _cardHolderCtrl = TextEditingController(text: i?.cardHolder ?? '');
    _expiryDateCtrl = TextEditingController(text: i?.expiryDate ?? '');
    _cvvCtrl = TextEditingController(text: i?.cvv ?? '');
    _withdrawalPwdCtrl = TextEditingController(text: i?.withdrawalPassword ?? '');
    _idTypeCtrl = TextEditingController(text: i?.idType ?? '');
    _idNumberCtrl = TextEditingController(text: i?.idNumber ?? '');
    _idNameCtrl = TextEditingController(text: i?.idName ?? '');
    _issuingAuthorityCtrl = TextEditingController(text: i?.issuingAuthority ?? '');
    _validUntilCtrl = TextEditingController(text: i?.validUntil ?? '');
    _noteContentCtrl = TextEditingController(text: i?.noteContent ?? '');
    _apiKeyCtrl = TextEditingController(text: i?.apiKey ?? '');
    _baseUrlCtrl = TextEditingController(text: i?.baseUrl ?? '');
    _modelNameCtrl = TextEditingController(text: i?.modelName ?? '');
    _notesCtrl = TextEditingController(text: i?.notes ?? '');
    _folderId = i?.folderId ?? '';
    _folderName = i?.folderName;
    _photoPaths = List<String>.from(i?.photoPaths ?? []);

    _titleCtrl.addListener(_updateSuggestion);
    if (_type == ItemType.password) {
      _urlCtrl.addListener(_updateSuggestion);
    }
    _updateSuggestion();
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_updateSuggestion);
    _urlCtrl.removeListener(_updateSuggestion);
    _titleCtrl.dispose(); _usernameCtrl.dispose(); _passwordCtrl.dispose();
    _emailCtrl.dispose(); _phoneCtrl.dispose(); _urlCtrl.dispose();
    _bankNameCtrl.dispose(); _cardNumberCtrl.dispose(); _cardHolderCtrl.dispose();
    _expiryDateCtrl.dispose(); _cvvCtrl.dispose(); _withdrawalPwdCtrl.dispose();
    _idTypeCtrl.dispose(); _idNumberCtrl.dispose(); _idNameCtrl.dispose();
    _issuingAuthorityCtrl.dispose(); _validUntilCtrl.dispose();
    _noteContentCtrl.dispose(); _apiKeyCtrl.dispose(); _baseUrlCtrl.dispose();
    _modelNameCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  void _updateSuggestion() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _suggestedCategory = null);
      return;
    }
    var cat = _categoryService.suggest(title);
    if (cat == null && _type == ItemType.password) {
      final url = _urlCtrl.text.trim();
      if (url.isNotEmpty) cat = _categoryService.suggestByUrl(url);
    }
    setState(() => _suggestedCategory = cat);
  }

  Future<void> _applyCategory() async {
    if (_suggestedCategory == null) return;
    final vault = context.read<VaultService>();
    final cat = _suggestedCategory!;
    var folder = vault.folders.cast<Folder?>().firstWhere(
      (f) => f!.name == cat, orElse: () => null,
    );
    if (folder == null) {
      await vault.addFolder(Folder(id: '', name: cat));
      if (!mounted) return;
      folder = vault.folders.cast<Folder?>().firstWhere(
        (f) => f!.name == cat, orElse: () => null,
      );
    }
    if (folder != null) {
      final f = folder;
      setState(() {
        _folderId = f.id;
        _folderName = f.name;
        _suggestedCategory = null;
      });
    }
  }

  void _dismissSuggestion() => setState(() => _suggestedCategory = null);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = VaultItem(
      id: widget.existingItem?.id ?? '',
      type: _type,
      title: _titleCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      url: _urlCtrl.text.trim(),
      bankName: _bankNameCtrl.text.trim(),
      cardNumber: _cardNumberCtrl.text.trim(),
      cardHolder: _cardHolderCtrl.text.trim(),
      expiryDate: _expiryDateCtrl.text.trim(),
      cvv: _cvvCtrl.text.trim(),
      withdrawalPassword: _withdrawalPwdCtrl.text.trim(),
      idType: _idTypeCtrl.text.trim(),
      idNumber: _idNumberCtrl.text.trim(),
      idName: _idNameCtrl.text.trim(),
      issuingAuthority: _issuingAuthorityCtrl.text.trim(),
      validUntil: _validUntilCtrl.text.trim(),
      noteContent: _noteContentCtrl.text.trim(),
      apiKey: _apiKeyCtrl.text.trim(),
      baseUrl: _baseUrlCtrl.text.trim(),
      modelName: _modelNameCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      folderId: _folderId,
      folderName: _folderName,
      photoPaths: _photoPaths,
    );

    final vault = context.read<VaultService>();
    if (_isEditing) {
      await vault.updateItem(item);
    } else {
      await vault.addItem(item);
    }

    if (mounted) Navigator.pop(context);
  }

  // ── Photo helpers ───────────────────────────────────────────────

  Future<void> _addPhoto() async {
    if (_photoPaths.length >= 3) return;

    final vault = context.read<VaultService>();
    final key = vault.encryptionKey;
    final photoService = context.read<PhotoService>();
    final messenger = ScaffoldMessenger.of(context);

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    if (key == null) return;

    try {
      final path = await photoService.pickAndSave(key, source: source);
      if (path != null && mounted) {
        setState(() => _photoPaths.add(path));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('添加照片失败: $e')),
        );
      }
    }
  }

  Future<void> _removePhoto(int index) async {
    final path = _photoPaths[index];
    await context.read<PhotoService>().deleteFile(path);
    setState(() => _photoPaths.removeAt(index));
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑${_type.label}' : '添加${_type.label}'),
        actions: [
          TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(),
            _buildSuggestionChip(),
            if (widget.existingItem == null)
              QuickFillChips(
                type: _type,
                currentValue: _titleCtrl.text,
                onSelected: (name) {
                  setState(() {
                    switch (_type) {
                      case ItemType.bankCard:
                        _bankNameCtrl.text = name;
                      case ItemType.idDocument:
                        _idTypeCtrl.text = name;
                      case ItemType.apiKey:
                        _titleCtrl.text = name;
                      case ItemType.password:
                      case ItemType.secureNote:
                        _titleCtrl.text = name;
                    }
                  });
                },
              ),
            ..._buildTypeFields(),
            const SizedBox(height: 16),
            if (_type == ItemType.bankCard || _type == ItemType.idDocument) ...[
              _buildPhotoSection(),
              const SizedBox(height: 16),
            ],
            _buildFolderSelector(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    String titleLabel() {
      switch (_type) {
        case ItemType.password:   return '平台/名称 *';
        case ItemType.bankCard:   return '卡片名称 *';
        case ItemType.idDocument: return '证件名称 *';
        case ItemType.secureNote: return '标题';
        case ItemType.apiKey:    return '供应商/平台 *';
      }
    }
    return TextFormField(
      controller: _titleCtrl,
      decoration: InputDecoration(labelText: titleLabel()),
      validator: (v) => Validators.required(v, '名称'),
    );
  }

  Widget _buildSuggestionChip() {
    if (_suggestedCategory == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Chip(
            avatar: const Icon(Icons.auto_awesome, size: 16),
            label: Text('分类建议: $_suggestedCategory'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            onDeleted: _dismissSuggestion,
            deleteIcon: const Icon(Icons.close, size: 14),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _applyCategory,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('采纳', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTypeFields() {
    switch (_type) {
      case ItemType.password:
        return [
          _buildField('用户名/账号', _usernameCtrl),
          _buildField('密码', _passwordCtrl, isPassword: true),
          _buildField('绑定邮箱', _emailCtrl, validator: (v) => Validators.email(v)),
          _buildField('绑定手机号', _phoneCtrl, validator: (v) => Validators.phone(v)),
          _buildField('网址', _urlCtrl),
          _buildField('备注', _notesCtrl, maxLines: 2),
        ];
      case ItemType.bankCard:
        return [
          _buildField('银行名称', _bankNameCtrl),
          _buildField('卡号', _cardNumberCtrl),
          _buildField('持卡人姓名', _cardHolderCtrl),
          _buildField('有效期', _expiryDateCtrl, hint: 'MM/YY'),
          _buildField('CVV安全码', _cvvCtrl, isPassword: true),
          _buildField('取款密码', _withdrawalPwdCtrl, isPassword: true),
          _buildField('备注', _notesCtrl, maxLines: 2),
        ];
      case ItemType.idDocument:
        return [
          _buildField('证件类型', _idTypeCtrl, hint: '身份证/护照/驾照/社保卡...'),
          _buildField('证件号', _idNumberCtrl),
          _buildField('姓名', _idNameCtrl),
          _buildField('签发机关', _issuingAuthorityCtrl),
          _buildField('有效期', _validUntilCtrl),
          _buildField('备注', _notesCtrl, maxLines: 2),
        ];
      case ItemType.secureNote:
        return [
          TextFormField(
            controller: _noteContentCtrl,
            decoration: const InputDecoration(
              labelText: '内容',
              hintText: '输入任何需要安全保存的文本...',
              alignLabelWithHint: true,
            ),
            maxLines: 8,
            validator: (v) => Validators.required(v, '内容'),
          ),
        ];
      case ItemType.apiKey:
        return [
          _buildField('API Key', _apiKeyCtrl, isPassword: true),
          _buildField('接口地址 (Base URL)', _baseUrlCtrl, hint: 'https://api.openai.com/v1'),
          _buildField('模型名称', _modelNameCtrl, hint: 'gpt-4o / claude-opus-4-7'),
          _buildField('备注', _notesCtrl, maxLines: 2),
        ];
    }
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool isPassword = false, String? hint, int maxLines = 1,
       String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(labelText: label, hintText: hint),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('照片附件', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text('(${_photoPaths.length}/3)',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: Row(
                children: [
                  for (int i = 0; i < _photoPaths.length; i++)
                    _buildPhotoThumb(i),
                  if (_photoPaths.length < 3)
                    _buildAddPhotoBtn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumb(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80, height: 80,
              child: _PhotoThumbnail(path: _photoPaths[index]),
            ),
          ),
          Positioned(
            top: -6, right: -6,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                width: 22, height: 22,
                decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoBtn() {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo, size: 22,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 2),
              Text('添加', style: TextStyle(fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderSelector() {
    final folders = context.read<VaultService>().folders;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButtonFormField<String>(
          initialValue: _folderId.isEmpty ? null : _folderId,
          decoration: const InputDecoration(
            labelText: '文件夹',
            border: InputBorder.none,
          ),
          hint: const Text('选择文件夹（可选）'),
          items: [
            for (final f in folders)
              DropdownMenuItem(value: f.id, child: Text(f.name)),
          ],
          onChanged: (id) {
            setState(() {
              _folderId = id ?? '';
              _folderName = id != null
                  ? folders.firstWhere((f) => f.id == id).name
                  : null;
            });
          },
        ),
      ),
    );
  }
}

/// Loads and decrypts a single photo thumbnail.
class _PhotoThumbnail extends StatelessWidget {
  final String path;
  const _PhotoThumbnail({required this.path});

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultService>();
    final key = vault.encryptionKey;
    if (key == null) return const SizedBox.shrink();

    return FutureBuilder<Uint8List?>(
      future: context.read<PhotoService>().load(path, key),
      builder: (ctx, snap) {
        if (snap.hasData && snap.data != null) {
          return Image.memory(snap.data!, fit: BoxFit.cover, width: 80, height: 80);
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 80, height: 80,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return Container(
          width: 80, height: 80,
          color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image, color: Theme.of(ctx).colorScheme.onSurfaceVariant),
        );
      },
    );
  }
}
