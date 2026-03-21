import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ung_dung_nm/features/auth/repositories/auth_repository.dart';
import '../../../core/services/supabase_provider.dart';
import '../../attendance/models/profile_model.dart';
import '../../../core/exceptions/auth_exception_handler.dart';

// Theo dõi trạng thái đăng nhập của Supabase
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.read(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

// Lấy thông tin Profile của User hiện tại
final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final session = supabase.auth.currentSession;
  if (session == null) return null;

  try {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', session.user.id)
        .single();
    return ProfileModel.fromJson(response);
  } catch (e) {
    return null;
  }
});

// --- THÊM MỚI: Controller xử lý Đăng Nhập / Đăng Ký ---
final authActionControllerProvider =
    StateNotifierProvider<AuthActionController, AsyncValue<void>>((ref) {
      return AuthActionController(ref.read(authRepositoryProvider));
    });

class AuthActionController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository; // Tiêm Repository vào đây

  AuthActionController(this._repository) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repository.signIn(email, password);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(AuthExceptionHandler.handle(e), StackTrace.current);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String employeeCode,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.signUp(email, password, fullName, employeeCode);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(AuthExceptionHandler.handle(e), StackTrace.current);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _repository.signOut();
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(AuthExceptionHandler.handle(e), StackTrace.current);
    }
  }
}
