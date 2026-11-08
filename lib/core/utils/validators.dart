class AppValidators {
  const AppValidators._();

  static String normalize(String? value) {
    if (value == null) return '';
    return value.trim().toLowerCase();
  }

  static String clean(String? value) {
    if (value == null) return '';
    return value.trim();
  }

  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName.';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    final cleaned = clean(value);
    if (cleaned.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập.';
    }
    if (cleaned.contains(' ')) {
      return 'Tên đăng nhập không được chứa dấu cách.';
    }
    if (cleaned.length < 3) {
      return 'Tên đăng nhập phải có ít nhất 3 ký tự.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final cleaned = clean(value);
    if (cleaned.isEmpty) {
      return 'Vui lòng nhập mật khẩu.';
    }
    if (cleaned.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String originalPassword) {
    final passError = validatePassword(value);
    if (passError != null) return passError;

    if (clean(value) != clean(originalPassword)) {
      return 'Mật khẩu xác nhận không khớp.';
    }
    return null;
  }
}