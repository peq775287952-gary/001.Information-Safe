import 'package:flutter_test/flutter_test.dart';
import 'package:infovault/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('should return null for non-empty value', () {
      expect(Validators.required('hello', '名称'), isNull);
    });

    test('should return null for whitespace-trimmed value', () {
      expect(Validators.required('  hello  ', '名称'), isNull);
    });

    test('should return error for null', () {
      expect(Validators.required(null, '名称'), '名称不能为空');
    });

    test('should return error for empty string', () {
      expect(Validators.required('', '名称'), '名称不能为空');
    });

    test('should return error for whitespace-only', () {
      expect(Validators.required('   ', '名称'), '名称不能为空');
    });

    test('should include field name in error message', () {
      expect(Validators.required('', '密码'), '密码不能为空');
    });
  });

  group('Validators.email', () {
    test('should return null for valid email', () {
      expect(Validators.email('test@example.com'), isNull);
    });

    test('should return null for email with subdomain', () {
      expect(Validators.email('user@mail.example.co.uk'), isNull);
    });

    test('should return null for email with plus', () {
      expect(Validators.email('user+tag@example.com'), isNull);
    });

    test('should return null for null (optional field)', () {
      expect(Validators.email(null), isNull);
    });

    test('should return null for empty (optional field)', () {
      expect(Validators.email(''), isNull);
    });

    test('should return null for whitespace-only (optional field)', () {
      expect(Validators.email('   '), isNull);
    });

    test('should return error for missing @', () {
      expect(Validators.email('userexample.com'), '邮箱格式不正确');
    });

    test('should return error for missing domain', () {
      expect(Validators.email('user@'), '邮箱格式不正确');
    });

    test('should return error for missing TLD', () {
      expect(Validators.email('user@example'), '邮箱格式不正确');
    });

    test('should return error for double @', () {
      expect(Validators.email('user@@example.com'), '邮箱格式不正确');
    });
  });

  group('Validators.phone', () {
    test('should return null for valid 11-digit phone', () {
      expect(Validators.phone('13800138000'), isNull);
    });

    test('should return null for null (optional field)', () {
      expect(Validators.phone(null), isNull);
    });

    test('should return null for empty (optional field)', () {
      expect(Validators.phone(''), isNull);
    });

    test('should return error for non-digit characters', () {
      expect(Validators.phone('1380013800a'), '手机号格式不正确');
    });

    test('should return error for too short', () {
      expect(Validators.phone('1380013800'), '手机号格式不正确');
    });

    test('should return error for too long', () {
      expect(Validators.phone('138001380001'), '手机号格式不正确');
    });

    test('should return error for letters', () {
      expect(Validators.phone('abcdefghijk'), '手机号格式不正确');
    });
  });

  group('Validators.masterPassword', () {
    test('should return null for password >= 8 chars', () {
      expect(Validators.masterPassword('12345678'), isNull);
    });

    test('should return null for long password', () {
      expect(Validators.masterPassword('very_long_password_here'), isNull);
    });

    test('should return error for null', () {
      expect(Validators.masterPassword(null), '主密码不能为空');
    });

    test('should return error for empty', () {
      expect(Validators.masterPassword(''), '主密码不能为空');
    });

    test('should return error for whitespace-only', () {
      expect(Validators.masterPassword('        '), '主密码不能为空');
    });

    test('should return error for less than 8 chars', () {
      expect(Validators.masterPassword('1234567'), '主密码至少8位');
    });
  });
}
