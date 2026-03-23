import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_nm/core/services/sync_service.dart';
import 'package:ung_dung_nm/features/attendance/models/profile_model.dart';
import 'package:ung_dung_nm/features/auth/controllers/auth_controller.dart';
import '../models/attendance_row_model.dart';
import '../models/timesheet_model.dart';
import '../repositories/attendance_repository.dart';

// Lưu trữ ngày đang được chọn (mặc định là hôm nay)
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Lưu trữ phòng ban đang được chọn (giả sử mã bộ phận là chuỗi này)
final selectedDepartmentProvider = StateProvider<String?>((ref) {
  // Lấy giá trị data (nếu có) từ profile của người đang đăng nhập
  final profile = ref.watch(currentProfileProvider).valueOrNull;
  // Trả về department_id của người đó (Tổ trưởng)
  return profile?.departmentId;
});

// Controller chính quản lý danh sách chấm công
final attendanceControllerProvider =
    AsyncNotifierProvider<AttendanceController, List<AttendanceRowModel>>(() {
      return AttendanceController();
    });

// 1. Provider lưu trữ Tháng đang chọn
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 2. Provider lấy danh sách Nhân viên theo phòng ban (Chỉ lấy 1 lần, không cần stream liên tục cho nhẹ máy)
final departmentEmployeesProvider = FutureProvider<List<ProfileModel>>((
  ref,
) async {
  final repo = ref.read(attendanceRepositoryProvider);
  final deptId = ref.watch(selectedDepartmentProvider);
  return repo.getEmployeesByDepartment(deptId!);
});

// 3. Provider Stream Bảng Tháng (Bộ não của Tab 2)
// Trả về một Map lồng nhau: Map<UserID, Map<Ngày, TimesheetModel>> để tra cứu cực nhanh O(1)
final monthlyAttendanceStreamProvider =
    StreamProvider<Map<String, Map<int, TimesheetModel>>>((ref) async* {
      final repo = ref.read(attendanceRepositoryProvider);
      final month = ref.watch(selectedMonthProvider);

      // Lắng nghe stream từ Supabase
      final stream = repo.streamTimesheetsByMonth(month);

      // Mỗi khi Supabase có thay đổi (ai đó vừa insert/update), đoạn code trong await for sẽ chạy lại
      await for (final timesheets in stream) {
        final map = <String, Map<int, TimesheetModel>>{};

        for (final t in timesheets) {
          final day = t.date.day; // Lấy ra ngày (1 -> 31)

          // Nếu user_id chưa có trong map thì tạo map rỗng, sau đó nhét ngày vào
          map.putIfAbsent(t.userId, () => {})[day] = t;
        }

        yield map; // Bắn dữ liệu mới ra cho UI cập nhật
      }
    });

class AttendanceController extends AsyncNotifier<List<AttendanceRowModel>> {
  @override
  Future<List<AttendanceRowModel>> build() async {
    // Hàm này tự động chạy khi UI được load lần đầu
    return _fetchData();
  }

  // Kéo dữ liệu nhân viên và bảng công ghép lại với nhau
  Future<List<AttendanceRowModel>> _fetchData() async {
    final repo = ref.read(attendanceRepositoryProvider);
    final date = ref.read(selectedDateProvider);
    final deptId = ref.read(selectedDepartmentProvider); // Kiểu String?

    // NẾU CHƯA CÓ MÃ BỘ PHẬN: Trả về danh sách rỗng ngay lập tức
    if (deptId == null) return [];

    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // Chạy 2 lệnh gọi DB song song để tăng tốc độ
    final results = await Future.wait([
      repo.getEmployeesByDepartment(deptId), // Truyền String bình thường
      repo.getTimesheetsByDate(dateStr),
    ]);

    final employees = results[0] as List<ProfileModel>;
    final timesheets = results[1] as List<TimesheetModel>;

    // Chuyển timesheets thành Map để tra cứu O(1)
    final timesheetMap = {for (var t in timesheets) t.userId: t};

    // Ghép dữ liệu
    return employees.map((emp) {
      final existingTimesheet = timesheetMap[emp.id];

      return AttendanceRowModel(
        profile: emp,
        timesheet:
            existingTimesheet ??
            TimesheetModel(
              userId: emp.id,
              date: date,
              shiftType: 'Ca Ngày',
              status: 'Có mặt',
            ),
      );
    }).toList();
  }

  // Thay đổi ngày và load lại
  void changeDate(DateTime newDate) {
    ref.read(selectedDateProvider.notifier).state = newDate;
    ref.invalidateSelf(); // Lệnh này bảo Riverpod chạy lại hàm build() -> hiển thị Loading -> có Data mới
  }

  // CẬP NHẬT GIAO DIỆN NGAY LẬP TỨC KHI CHỌN DROPDOWN (Optimistic UI)
  void updateLocalRow(String userId, TimesheetModel updatedTimesheet) {
    // Lấy state hiện tại (nếu đang có data)
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Tìm và thay thế dòng của nhân viên vừa được sửa
    final newState = currentState.map((row) {
      if (row.profile.id == userId) {
        return row.copyWith(timesheet: updatedTimesheet);
      }
      return row;
    }).toList();

    // Cập nhật giao diện ngay lập tức
    state = AsyncData(newState);
  }

  // Hàm Lưu (Bắn lên Supabase)
  Future<String> submitData(String currentUserId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return "Lỗi: Không có dữ liệu.";

    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final syncService = ref.read(syncServiceProvider);

      final timesheetsToSave = currentState
          .map((row) => row.timesheet)
          .toList();

      // KIỂM TRA MẠNG
      final isOnline = await syncService.hasNetwork();

      if (isOnline) {
        // CÓ MẠNG: Đẩy thẳng lên Supabase
        await repo.upsertTimesheets(timesheetsToSave);
        ref.invalidate(monthlyAttendanceStreamProvider);

        // Đồng thời đẩy luôn các dữ liệu cũ bị kẹt (nếu có)
        await syncService.syncPendingData();
        return "online_success";
      } else {
        // MẤT MẠNG: Lưu tạm vào máy
        await syncService.saveOfflineTimesheets(timesheetsToSave);
        return "offline_saved";
      }
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return "error";
    }
  }
}
