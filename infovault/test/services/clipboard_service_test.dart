import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/services/clipboard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ClipboardService', () {
    final service = ClipboardService.instance;

    setUp(() {
      service.dispose();
    });

    test('should track copied value', () {
      service.copy('my_secret');
      expect(service.lastCopiedValue, 'my_secret');
    });

    test('should have pending clear after copy', () {
      service.copy('test_value');
      expect(service.hasPendingClear, true);
    });

    test('should cancel previous timer on new copy', () {
      service.copy('first');
      service.copy('second');
      expect(service.lastCopiedValue, 'second');
    });

    test('should handle empty string copy', () {
      service.copy('');
      expect(service.lastCopiedValue, '');
    });

    test('should dispose without error', () {
      service.copy('test');
      service.dispose();
      expect(service.lastCopiedValue, null);
    });
  });
}
