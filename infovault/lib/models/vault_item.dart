import 'dart:convert';
import 'package:infovault/models/item_type.dart';
class VaultItem {
  final String id;
  final ItemType type;
  final String title;
  final String? username;
  final String? password;
  final String? email;
  final String? phone;
  final String? url;
  final String? bankName;
  final String? cardNumber;
  final String? cardHolder;
  final String? expiryDate;
  final String? cvv;
  final String? withdrawalPassword;
  final String? idType;
  final String? idNumber;
  final String? idName;
  final String? issuingAuthority;
  final String? validUntil;
  final String? apiKey;
  final String? baseUrl;
  final String? modelName;
  final String? noteContent;
  final String? notes;
  final String? folderName;
  final String folderId;
  final List<String> photoPaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaultItem({
    required this.id,
    required this.type,
    required this.title,
    this.username,
    this.password,
    this.email,
    this.phone,
    this.url,
    this.bankName,
    this.cardNumber,
    this.cardHolder,
    this.expiryDate,
    this.cvv,
    this.withdrawalPassword,
    this.idType,
    this.idNumber,
    this.idName,
    this.issuingAuthority,
    this.validUntil,
    this.noteContent,
    this.notes,
    this.apiKey,
    this.baseUrl,
    this.modelName,
    this.folderName,
    this.folderId = '',
    this.photoPaths = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get displaySubtitle {
    switch (type) {
      case ItemType.password:
        return username ?? email ?? '';
      case ItemType.bankCard:
        if (cardNumber == null || cardNumber!.isEmpty) return '';
        return cardNumber!.length >= 4
            ? '**** ${cardNumber!.substring(cardNumber!.length - 4)}'
            : '**** $cardNumber';
      case ItemType.idDocument:
        if (idNumber == null || idNumber!.isEmpty) return '';
        return idNumber!.length >= 4
            ? '**** ${idNumber!.substring(idNumber!.length - 4)}'
            : '**** $idNumber';
      case ItemType.secureNote:
        return noteContent != null ? '**** ****' : '';
      case ItemType.apiKey:
        if (apiKey == null || apiKey!.isEmpty) return '';
        return apiKey!.length >= 4
            ? '**** ${apiKey!.substring(apiKey!.length - 4)}'
            : '**** $apiKey';
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.value,
    'title': title,
    'username': username,
    'password': password,
    'email': email,
    'phone': phone,
    'url': url,
    'bank_name': bankName,
    'card_number': cardNumber,
    'card_holder': cardHolder,
    'expiry_date': expiryDate,
    'cvv': cvv,
    'withdrawal_password': withdrawalPassword,
    'id_type': idType,
    'id_number': idNumber,
    'id_name': idName,
    'issuing_authority': issuingAuthority,
    'valid_until': validUntil,
    'note_content': noteContent,
    'api_key': apiKey,
    'base_url': baseUrl,
    'model_name': modelName,
    'notes': notes,
    'folder_name': folderName,
    'folder_id': folderId,
    'photo_paths': json.encode(photoPaths),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory VaultItem.fromMap(Map<String, dynamic> map) => VaultItem(
    id: map['id'] as String,
    type: ItemType.fromValue(map['type'] as String),
    title: map['title'] as String,
    username: map['username'] as String?,
    password: map['password'] as String?,
    email: map['email'] as String?,
    phone: map['phone'] as String?,
    url: map['url'] as String?,
    bankName: map['bank_name'] as String?,
    cardNumber: map['card_number'] as String?,
    cardHolder: map['card_holder'] as String?,
    expiryDate: map['expiry_date'] as String?,
    cvv: map['cvv'] as String?,
    withdrawalPassword: map['withdrawal_password'] as String?,
    idType: map['id_type'] as String?,
    idNumber: map['id_number'] as String?,
    idName: map['id_name'] as String?,
    issuingAuthority: map['issuing_authority'] as String?,
    validUntil: map['valid_until'] as String?,
    noteContent: map['note_content'] as String?,
    apiKey: map['api_key'] as String?,
    baseUrl: map['base_url'] as String?,
    modelName: map['model_name'] as String?,
    notes: map['notes'] as String?,
    folderName: map['folder_name'] as String?,
    folderId: map['folder_id'] as String? ?? '',
    photoPaths: (json.decode(map['photo_paths'] as String? ?? '[]') as List<dynamic>).cast<String>(),
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );

  VaultItem copyWith({
    String? id,
    ItemType? type,
    String? title,
    String? username,
    String? password,
    String? email,
    String? phone,
    String? url,
    String? bankName,
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
    String? withdrawalPassword,
    String? idType,
    String? idNumber,
    String? idName,
    String? issuingAuthority,
    String? validUntil,
    String? noteContent,
    String? apiKey,
    String? baseUrl,
    String? modelName,
    String? notes,
    String? folderName,
    String? folderId,
    List<String>? photoPaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaultItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      url: url ?? this.url,
      bankName: bankName ?? this.bankName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolder: cardHolder ?? this.cardHolder,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      withdrawalPassword: withdrawalPassword ?? this.withdrawalPassword,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      idName: idName ?? this.idName,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      validUntil: validUntil ?? this.validUntil,
      noteContent: noteContent ?? this.noteContent,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      modelName: modelName ?? this.modelName,
      notes: notes ?? this.notes,
      folderName: folderName ?? this.folderName,
      folderId: folderId ?? this.folderId,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
