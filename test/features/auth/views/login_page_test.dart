import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ung_dung_nm/features/auth/views/login_page.dart';

void main() {
  testWidgets('Login Page phải có ô nhập Email, Password và Nút Đăng nhập', (
    WidgetTester tester,
  ) async {
    // Build widget với ProviderScope
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );

    // Kiểm tra UI có render đúng không
    expect(find.text("ĐĂNG NHẬP HỆ THỐNG"), findsOneWidget);

    // Tìm TextField bằng Label/Hint
    final emailField = find.widgetWithText(TextField, "Email");
    final passwordField = find.widgetWithText(TextField, "Mật khẩu");
    final loginButton = find.widgetWithText(ElevatedButton, "ĐĂNG NHẬP");

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    // Giả lập hành động nhập Text
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, '123456');
    await tester.pump();

    // Giả lập hành động bấm nút
    await tester.tap(loginButton);
    await tester.pump(); // Pump lại UI sau khi bấm

    // Test xem có hiện Indicator xoay xoay lúc Loading không
    // (Tuỳ thuộc vào cách bạn viết UI bắt trạng thái authState.isLoading)
  });
}
