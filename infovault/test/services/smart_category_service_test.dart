import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/services/smart_category_service.dart';

void main() {
  final service = SmartCategoryService();

  group('SmartCategoryService', () {
    test('should classify WeChat as 社交', () {
      expect(service.suggest('微信'), '社交');
      expect(service.suggest('wechat'), '社交');
    });

    test('should classify Alipay as 金融', () {
      expect(service.suggest('支付宝'), '金融');
      expect(service.suggest('alipay'), '金融');
    });

    test('should classify GitHub as 开发', () {
      expect(service.suggest('GitHub'), '开发');
      expect(service.suggest('github.com'), '开发');
    });

    test('should return null for unknown platform', () {
      expect(service.suggest('某不知名平台'), null);
    });

    test('should match by URL only', () {
      expect(service.suggestByUrl('taobao.com'), '购物');
      expect(service.suggestByUrl('gmail.com'), '邮箱');
    });

    test('should match bank names', () {
      expect(service.suggest('招商银行'), '金融');
      expect(service.suggest('工商银行'), '金融');
    });

    test('should match via fuzzy search', () {
      expect(service.suggest('GitHub Enterprise'), '开发');
    });
  });
}
