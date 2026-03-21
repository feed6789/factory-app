import 'package:supabase_flutter/supabase_flutter.dart';

class AuthExceptionHandler {
  static String handle(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Tài khoản của bạn đã bị tạm khóa. Vui lòng liên hệ quản lý.':
          return 'Tài khoản của bạn đã bị tạm khóa. Vui lòng liên hệ quản lý.';
        case 'Invalid login credentials':
          return 'Email hoặc mật khẩu không chính xác.';
        case 'User already registered':
          return 'Email này đã được đăng ký trong hệ thống.';
        case 'Password should be at least 6 characters':
          return 'Mật khẩu phải có ít nhất 6 ký tự.';
        default:
          return 'Lỗi xác thực: ${error.message}';
      }
    }
    return 'Lỗi kết nối máy chủ. Vui lòng kiểm tra lại mạng.';
  }
}
