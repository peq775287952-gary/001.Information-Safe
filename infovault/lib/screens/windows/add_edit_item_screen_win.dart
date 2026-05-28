import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/vault_item.dart';
import '../../models/item_type.dart';
import '../../models/folder.dart' as models;
import '../../services/vault_service.dart';
import '../../services/photo_service.dart';
import '../../services/smart_category_service.dart';
import '../../utils/validators.dart';
import '../../widgets/quick_fill_chips.dart';

class AddEditItemScreenWin extends StatefulWidget {
  final ItemType itemType;
  final VaultItem? existingItem;

  const AddEditItemScreenWin({
    super.key,
    required this.itemType,
    this.existingItem,
  });

  @override
  State<AddEditItemScreenWin> createState() => _AddEditItemScreenWinState();
}

class _AddEditItemScreenWinState extends State<AddEditItemScreenWin> {
  final _categoryService = SmartCategoryService();
  late final ItemType _type;
  late final fluent.TextEditingController _titleCtrl;
  late final fluent.TextEditingController _usernameCtrl;
  late final fluent.TextEditingController _passwordCtrl;
  late final fluent.TextEditingController _emailCtrl;
  late final fluent.TextEditingController _phoneCtrl;
  late final fluent.TextEditingController _urlCtrl;
  late final fluent.TextEditingController _bankNameCtrl;
  late final fluent.TextEditingController _cardNumberCtrl;
  late final fluent.TextEditingController _cardHolderCtrl;
  late final fluent.TextEditingController _expiryDateCtrl;
  late final fluent.TextEditingController _cvvCtrl;
  late final fluent.TextEditingController _withdrawalPwdCtrl;
  late final fluent.TextEditingController _idTypeCtrl;
  late final fluent.TextEditingController _idNumberCtrl;
  late final fluent.TextEditingController _idNameCtrl;
  late final fluent.TextEditingController _issuingAuthorityCtrl;
  late final fluent.TextEditingController _validUntilCtrl;
  late final fluent.TextEditingController _noteContentCtrl;
  late final fluent.TextEditingController _apiKeyCtrl;
  late final fluent.TextEditingController _baseUrlCtrl;
  late final fluent.TextEditingController _modelNameCtrl;
  late final fluent.TextEditingController _notesCtrl;
  String _folderId = '';
  String? _folderName;
  String? _suggestedCategory;
  List<String> _photoPaths = [];
  String? _errorText;
  final _focusNode = FocusNode();

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    _type = widget.itemType;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    final i = widget.existingItem;
    _titleCtrl = fluent.TextEditingController(text: i?.title ?? '');
    _usernameCtrl = fluent.TextEditingController(text: i?.username ?? '');
    _passwordCtrl = fluent.TextEditingController(text: i?.password ?? '');
    _emailCtrl = fluent.TextEditingController(text: i?.email ?? '');
    _phoneCtrl = fluent.TextEditingController(text: i?.phone ?? '');
    _urlCtrl = fluent.TextEditingController(text: i?.url ?? '');
    _bankNameCtrl = fluent.TextEditingController(text: i?.bankName ?? '');
    _cardNumberCtrl = fluent.TextEditingController(text: i?.cardNumber ?? '');
    _cardHolderCtrl = fluent.TextEditingController(text: i?.cardHolder ?? '');
    _expiryDateCtrl = fluent.TextEditingController(text: i?.expiryDate ?? '');
    _cvvCtrl = fluent.TextEditingController(text: i?.cvv ?? '');
    _withdrawalPwdCtrl =
        fluent.TextEditingController(text: i?.withdrawalPassword ?? '');
    _idTypeCtrl = fluent.TextEditingController(text: i?.idType ?? '');
    _idNumberCtrl = fluent.TextEditingController(text: i?.idNumber ?? '');
    _idNameCtrl = fluent.TextEditingController(text: i?.idName ?? '');
    _issuingAuthorityCtrl =
        fluent.TextEditingController(text: i?.issuingAuthority ?? '');
    _validUntilCtrl = fluent.TextEditingController(text: i?.validUntil ?? '');
    _noteContentCtrl =
        fluent.TextEditingController(text: i?.noteContent ?? '');
    _apiKeyCtrl = fluent.TextEditingController(text: i?.apiKey ?? '');
    _baseUrlCtrl = fluent.TextEditingController(text: i?.baseUrl ?? '');
    _modelNameCtrl = fluent.TextEditingController(text: i?.modelName ?? '');
    _notesCtrl = fluent.TextEditingController(text: i?.notes ?? '');
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
    _focusNode.dispose();
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
    var folder = vault.folders.cast<models.Folder?>().firstWhere(
      (f) => f!.name == cat, orElse: () => null,
    );
    if (folder == null) {
      await vault.addFolder(models.Folder(id: '', name: cat));
      if (!mounted) return;
      folder = vault.folders.cast<models.Folder?>().firstWhere(
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

  bool _validate() {
    final title = _titleCtrl.text.trim();
    if (Validators.required(title, '名称') != null) {
      setState(() => _errorText = '名称不能为空');
      return false;
    }
    if (_type == ItemType.secureNote) {
      final content = _noteContentCtrl.text.trim();
      if (Validators.required(content, '内容') != null) {
        setState(() => _errorText = '内容不能为空');
        return false;
      }
    }
    setState(() => _errorText = null);
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;

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

  // ── Photo helpers ──

  Future<void> _addPhoto() async {
    if (_photoPaths.length >= 3) return;

    final vault = context.read<VaultService>();
    final key = vault.encryptionKey;
    final photoService = context.read<PhotoService>();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => fluent.ContentDialog(
        title: const Text('添加照片'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!Platform.isWindows)
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
        actions: [
          fluent.Button(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
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
        setState(() => _errorText = '添加照片失败: $e');
      }
    }
  }

  Future<void> _removePhoto(int index) async {
    final path = _photoPaths[index];
    await context.read<PhotoService>().deleteFile(path);
    setState(() => _photoPaths.removeAt(index));
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final isDark = fluent.FluentTheme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(context);
        } else if (event.logicalKey == LogicalKeyboardKey.keyS &&
            (HardwareKeyboard.instance.isControlPressed ||
             HardwareKeyboard.instance.isMetaPressed)) {
          _save();
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
          title: Text(_isEditing ? '编辑${_type.label}' : '添加${_type.label}'),
          commandBar: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              fluent.Button(
                child: const Text('取消'),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              fluent.FilledButton(
                child: const Text('保存'),
                onPressed: _save,
              ),
            ],
          ),
        ),
        content: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(mutedColor),
            _buildSuggestionChip(mutedColor),
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
            ..._buildTypeFields(mutedColor),
            const SizedBox(height: 16),
            if (_type == ItemType.bankCard ||
                _type == ItemType.idDocument) ...[
              _buildPhotoSection(mutedColor),
              const SizedBox(height: 16),
            ],
            _buildFolderSelector(),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(_errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _titleLabel() {
    switch (_type) {
      case ItemType.password:   return '平台/名称 *';
      case ItemType.bankCard:   return '卡片名称 *';
      case ItemType.idDocument: return '证件名称 *';
      case ItemType.secureNote: return '标题';
      case ItemType.apiKey:    return '供应商/平台 *';
    }
  }

  Widget _buildTitleField(Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: fluent.TextBox(
        controller: _titleCtrl,
        placeholder: _titleLabel(),
      ),
    );
  }

  Widget _buildSuggestionChip(Color mutedColor) {
    if (_suggestedCategory == null) return const SizedBox.shrink();
    final isDark = fluent.FluentTheme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2A3A) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF2563EB).withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(fluent.FluentIcons.auto_enhance_on, size: 16),
                const SizedBox(width: 4),
                Text('分类建议: $_suggestedCategory'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _applyCategory,
            child: const Text('采纳'),
          ),
          TextButton(
            onPressed: _dismissSuggestion,
            child: const Text('忽略'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTypeFields(Color mutedColor) {
    switch (_type) {
      case ItemType.password:
        return [
          _buildField('用户名/账号', _usernameCtrl),
          _buildField('密码', _passwordCtrl, isPassword: true),
          _buildField('绑定邮箱', _emailCtrl),
          _buildField('绑定手机号', _phoneCtrl),
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
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: fluent.TextBox(
              controller: _noteContentCtrl,
              placeholder: '输入任何需要安全保存的文本...',
              maxLines: 8,
              expands: true,
            ),
          ),
        ];
      case ItemType.apiKey:
        return [
          _buildField('API Key', _apiKeyCtrl, isPassword: true),
          _buildField('接口地址 (Base URL)', _baseUrlCtrl,
              hint: 'https://api.openai.com/v1'),
          _buildField('模型名称', _modelNameCtrl, hint: 'gpt-4o / claude-opus-4-7'),
          _buildField('备注', _notesCtrl, maxLines: 2),
        ];
    }
  }

  Widget _buildField(String label, fluent.TextEditingController controller,
      {bool isPassword = false, String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: fluent.TextBox(
        controller: controller,
        placeholder: label,
        obscureText: isPassword,
        maxLines: maxLines > 1 ? maxLines : 1,
        expands: maxLines > 1,
      ),
    );
  }

  Widget _buildPhotoSection(Color mutedColor) {
    return fluent.Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('照片附件',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text('(${_photoPaths.length}/3)',
                    style: TextStyle(fontSize: 12, color: mutedColor)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: Row(
                children: [
                  for (int i = 0; i < _photoPaths.length; i++)
                    _buildPhotoThumb(i),
                  if (_photoPaths.length < 3) _buildAddPhotoBtn(mutedColor),
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
              width: 80,
              height: 80,
              child: _PhotoThumbnailWin(path: _photoPaths[index]),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoBtn(Color mutedColor) {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: mutedColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo, size: 22, color: mutedColor),
              const SizedBox(height: 2),
              Text('添加', style: TextStyle(fontSize: 11, color: mutedColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderSelector() {
    final folders = context.read<VaultService>().folders;
    return fluent.Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('文件夹（可选）',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            fluent.ComboBox<String>(
              value: _folderId.isEmpty ? null : _folderId,
              placeholder: const Text('选择文件夹'),
              items: [
                fluent.ComboBoxItem(value: '', child: const Text('无文件夹')),
                for (final f in folders)
                  fluent.ComboBoxItem(
                      value: f.id, child: Text(f.name)),
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
          ],
        ),
      ),
    );
  }
}

/// Loads and decrypts a single photo thumbnail.
class _PhotoThumbnailWin extends StatelessWidget {
  final String path;
  const _PhotoThumbnailWin({required this.path});

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultService>();
    final key = vault.encryptionKey;
    if (key == null) return const SizedBox.shrink();

    return FutureBuilder<Uint8List?>(
      future: context.read<PhotoService>().load(path, key),
      builder: (ctx, snap) {
        if (snap.hasData && snap.data != null) {
          return Image.memory(snap.data!, fit: BoxFit.cover,
              width: 80, height: 80);
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 80, height: 80,
            child: Center(child: SizedBox(width:20,height:20,
                child:fluent.ProgressRing(strokeWidth:2))),
          );
        }
        return Container(
          width: 80, height: 80,
          color: const Color(0xFFE2E8F0),
          child: const Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
        );
      },
    );
  }
}
