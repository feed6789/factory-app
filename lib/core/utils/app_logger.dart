import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Hiển thị lỗi xuất phát từ hàm nào
      errorMethodCount: 8, // Hiển thị Stacktrace dài hơn khi có lỗi
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void i(String message) => _logger.i(message); // Info
  static void w(String message) => _logger.w(message); // Warning
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    // TODO: Tích hợp Sentry hoặc Firebase Crashlytics tại đây để báo lỗi về Server
  }
}
