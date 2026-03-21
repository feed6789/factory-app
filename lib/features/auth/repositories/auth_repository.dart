import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(supabaseProvider));
});

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Future<void> signIn(String email, String password) async {
    // Bước 1: Đăng nhập bằng Supabase Auth như bình thường
    final AuthResponse res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;

    // Nếu đăng nhập thất bại, Supabase đã tự ném ra lỗi, chúng ta không cần xử lý
    if (user == null) {
      return;
    }

    // Bước 2: KIỂM TRA BẮT BUỘC TRẠNG THÁI TÀI KHOẢN
    try {
      final profileRes = await _supabase
          .from('profiles')
          .select('is_active')
          .eq('id', user.id)
          .single();

      final bool isActive = profileRes['is_active'] ?? false;

      // Bước 3: Nếu tài khoản bị khóa (is_active == false)
      if (!isActive) {
        // Buộc đăng xuất ngay lập tức
        await _supabase.auth.signOut();
        // Ném ra một lỗi tùy chỉnh để thông báo cho người dùng
        throw const AuthException(
          'Tài khoản của bạn đã bị tạm khóa. Vui lòng liên hệ quản lý.',
        );
      }
      // Nếu isActive là true, hàm kết thúc và người dùng được phép vào app
    } catch (e) {
      // Nếu có lỗi khi lấy profile (ví dụ: profile chưa được tạo), cũng nên đăng xuất cho an toàn
      await _supabase.auth.signOut();
      // Ném lại lỗi để controller xử lý
      rethrow;
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String fullName,
    String employeeCode,
  ) async {
    final res = await _supabase.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user != null) {
      await _supabase.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'employee_code': employeeCode,
        'role': 'worker',
        'is_active': true,
      });
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
