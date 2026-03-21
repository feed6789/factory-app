import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ung_dung_nm/features/auth/controllers/auth_controller.dart';
import 'package:ung_dung_nm/features/auth/views/login_page.dart';
import 'package:ung_dung_nm/features/home/views/main_navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load file .env
  await dotenv.load(fileName: "ungdung.env");

  // Khởi tạo Supabase an toàn
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Nhà Máy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(), // Sử dụng AuthGate làm cửa ngõ
    );
  }
}

// Widget này sẽ tự động chuyển đổi giữa Login và Home tùy trạng thái Supabase
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe trạng thái đăng nhập
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Lỗi: $err'))),
      data: (authState) {
        // Kiểm tra xem có session không (đã đăng nhập chưa)
        final session = authState.session;
        if (session != null) {
          return const MainNavigationPage(); // Vào app
        } else {
          return const LoginPage(); // Ra màn hình login
        }
      },
    );
  }
}
