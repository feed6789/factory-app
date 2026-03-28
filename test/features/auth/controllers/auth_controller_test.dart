import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ung_dung_nm/features/auth/controllers/auth_controller.dart';
import 'package:ung_dung_nm/features/auth/repositories/auth_repository.dart';

// 1. Tạo Class Mock
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late AuthActionController authController;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    authController = AuthActionController(mockAuthRepo);
  });

  group('AuthActionController Tests', () {
    test('Login thành công cập nhật trạng thái AsyncData', () async {
      // Arrange (Giả lập)
      when(() => mockAuthRepo.signIn(any(), any())).thenAnswer((_) async {});

      // Act (Hành động)
      final future = authController.login('test@gmail.com', '123456');

      // Trạng thái lúc đang chạy phải là Loading
      expect(authController.debugState, const AsyncLoading<void>());

      await future;

      // Assert (Kiểm tra)
      expect(authController.debugState, const AsyncData<void>(null));
      verify(() => mockAuthRepo.signIn('test@gmail.com', '123456')).called(1);
    });

    test('Login thất bại cập nhật trạng thái AsyncError', () async {
      // Arrange
      when(
        () => mockAuthRepo.signIn(any(), any()),
      ).thenThrow(Exception('Sai mật khẩu'));

      // Act
      await authController.login('test@gmail.com', 'wrong_pass');

      // Assert
      expect(authController.debugState, isA<AsyncError>());
    });
  });
}
