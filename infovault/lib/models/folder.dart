class Folder {
  final String id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'sort_order': sortOrder,
    'created_at': createdAt.toIso8601String(),
  };

  factory Folder.fromMap(Map<String, dynamic> map) => Folder(
    id: map['id'] as String,
    name: map['name'] as String,
    sortOrder: map['sort_order'] as int? ?? 0,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
