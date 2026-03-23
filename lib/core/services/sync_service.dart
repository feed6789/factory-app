import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/attendance/models/timesheet_model.dart';
import '../../features/attendance/repositories/attendance_repository.dart';

// Biến lưu trạng thái số lượng bản ghi đang kẹt dưới máy (để hiển thị lên UI)
final pendingSyncCountProvider = StateProvider<int>((ref) => 0);

final syncServiceProvider = Provider((ref) => SyncService(ref));

class SyncService {
  final Ref ref;
  static const String _offlineQueueKey = 'offline_timesheet_queue';

  SyncService(this.ref) {
    _loadPendingCount();
  }

  // 1. Kiểm tra xem có mạng không
  Future<bool> hasNetwork() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity()
        .checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  // 2. Lưu data xuống máy khi mất mạng
  Future<void> saveOfflineTimesheets(List<TimesheetModel> timesheets) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy danh sách cũ đang kẹt
    List<String> existingQueue = prefs.getStringList(_offlineQueueKey) ?? [];

    // Thêm data mới vào dạng JSON String
    for (var t in timesheets) {
      existingQueue.add(jsonEncode(t.toJson()));
    }

    await prefs.setStringList(_offlineQueueKey, existingQueue);
    ref.read(pendingSyncCountProvider.notifier).state = existingQueue.length;
  }

  // 3. Đọc số lượng đang kẹt để báo cho UI
  Future<void> _loadPendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_offlineQueueKey) ?? [];
    ref.read(pendingSyncCountProvider.notifier).state = queue.length;
  }

  // 4. Đồng bộ dữ liệu bị kẹt lên Supabase
  Future<bool> syncPendingData() async {
    final isOnline = await hasNetwork();
    if (!isOnline) return false;

    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_offlineQueueKey) ?? [];

    if (queue.isEmpty) return true; // Không có gì để đồng bộ

    try {
      // Decode dữ liệu từ local
      List<TimesheetModel> timesheetsToSync = queue.map((jsonStr) {
        return TimesheetModel.fromJson(jsonDecode(jsonStr));
      }).toList();

      // Đẩy lên Supabase (Hàm upsert có sẵn của bạn xử lý trùng lặp tự động rất tốt)
      final repo = ref.read(attendanceRepositoryProvider);
      await repo.upsertTimesheets(timesheetsToSync);

      // Nếu thành công, xóa hàng đợi ở local
      await prefs.remove(_offlineQueueKey);
      ref.read(pendingSyncCountProvider.notifier).state = 0;

      return true;
    } catch (e) {
      print("Lỗi khi đồng bộ dữ liệu: $e");
      return false; // Lỗi mạng giữa chừng, giữ lại data chờ lần sau
    }
  }
}
