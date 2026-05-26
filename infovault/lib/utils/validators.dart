class Validators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return '邮箱格式不正确';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^\d{11}$');
    if (!regex.hasMatch(value.trim())) {
      return '手机号格式不正确';
    }
    return null;
  }

  static String? masterPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '主密码不能为空';
    }
    if (value.length < 4) {
      return '主密码至少4位';
    }
    return null;
  }

  static String? newPassword(String? value, String oldPassword) {
    if (value == null || value.trim().isEmpty) {
      return '新密码不能为空';
    }
    if (value.length < 4) {
      return '新密码至少4位';
    }
    if (value == oldPassword) {
      return '新密码不能与旧密码相同';
    }
    return null;
  }
}
