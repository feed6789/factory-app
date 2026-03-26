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
    final AuthResponse res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) return;

    try {
      final profileRes = await _supabase
          .from('profiles')
          .select('is_active, approval_status')
          .eq('id', user.id)
          .single();

      final bool isActive = profileRes['is_active'] ?? false;
      final String approvalStatus = profileRes['approval_status'] ?? 'approved';

      // Kiểm tra trạng thái duyệt trước
      if (approvalStatus == 'pending') {
        await _supabase.auth.signOut();
        throw const AuthException(
          'Tài khoản của bạn đang chờ HR duyệt. Vui lòng quay lại sau.',
        );
      } else if (approvalStatus == 'rejected') {
        await _supabase.auth.signOut();
        throw const AuthException('Tài khoản của bạn đã bị từ chối cấp quyền.');
      } else if (!isActive) {
        await _supabase.auth.signOut();
        throw const AuthException(
          'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản lý.',
        );
      }
    } catch (e) {
      await _supabase.auth.signOut();
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
      // Khi user tự đăng ký trên app, mặc định is_active = false và approval_status = 'pending'
      await _supabase.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'employee_code': employeeCode,
        'email': email,
        'role': 'worker',
        'is_active': false, // Vô hiệu hóa cho đến khi được duyệt
        'approval_status': 'pending', // TRẠNG THÁI CHỜ DUYỆT
      });
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
