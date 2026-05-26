enum ItemType {
  password('login_password', '🔑', '登录密码'),
  bankCard('bank_card', '💳', '银行卡'),
  idDocument('id_document', '🪪', '证件'),
  secureNote('secure_note', '📝', '安全笔记'),
  apiKey('api_key', '🤖', 'API密钥');

  final String value;
  final String icon;
  final String label;
  const ItemType(this.value, this.icon, this.label);

  static ItemType fromValue(String value) {
    return ItemType.values.firstWhere((t) => t.value == value);
  }
}
