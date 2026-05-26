import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/models/folder.dart';

void main() {
  group('Folder', () {
    test('should create with default sortOrder', () {
      final folder = Folder(id: 'f1', name: 'Work');
      expect(folder.sortOrder, 0);
    });

    test('should create with default createdAt', () {
      final folder = Folder(id: 'f2', name: 'Personal');
      expect(folder.createdAt, isNotNull);
    });

    test('should set createdAt when provided', () {
      final date = DateTime(2025, 1, 15);
      final folder = Folder(id: 'f3', name: 'Archive', createdAt: date);
      expect(folder.createdAt, date);
    });

    test('should serialize to map and back', () {
      final folder = Folder(
        id: 'f4',
        name: 'Finance',
        sortOrder: 3,
        createdAt: DateTime(2025, 6, 1),
      );
      final map = folder.toMap();
      final restored = Folder.fromMap(map);
      expect(restored.id, folder.id);
      expect(restored.name, folder.name);
      expect(restored.sortOrder, folder.sortOrder);
      expect(restored.createdAt, folder.createdAt);
    });

    test('fromMap should use defaults for missing fields', () {
      final minimal = Folder.fromMap({
        'id': 'f5',
        'name': 'Minimal',
        'created_at': '2025-06-01T00:00:00.000',
      });
      expect(minimal.sortOrder, 0);
    });
  });
}
