import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_provider.dart';
import '../models/profile_model.dart';
import '../models/timesheet_model.dart';

// Khai báo Repository Provider
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.read(supabaseProvider));
});

class AttendanceRepository {
  final SupabaseClient _supabase;

  AttendanceRepository(this._supabase);

  // 1. Lấy danh sách nhân viên theo Bộ phận (Department)
  Future<List<ProfileModel>> getEmployeesByDepartment(
    String? departmentId,
  ) async {
    // Nếu chưa load được departmentId (hoặc admin chưa chọn), trả về mảng rỗng
    if (departmentId == null) return [];

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('department_id', departmentId)
        .eq('is_active', true)
        .order('full_name', ascending: true);

    return response.map((json) => ProfileModel.fromJson(json)).toList();
  }

  // 2. Lấy dữ liệu chấm công của cả tổ trong 1 ngày
  Future<List<TimesheetModel>> getTimesheetsByDate(String dateStr) async {
    final response = await _supabase
        .from('daily_timesheets')
        .select()
        .eq('date', dateStr);

    return response.map((json) => TimesheetModel.fromJson(json)).toList();
  }

  // 3. Upsert (Thêm mới hoặc Cập nhật) dữ liệu chấm công
  // Điểm mạnh cực lớn của Supabase: Upsert 1 mảng dữ liệu cùng lúc
  Future<void> upsertTimesheets(List<TimesheetModel> timesheets) async {
    final List<Map<String, dynamic>> dataToInsert = timesheets.map((t) {
      final json = t.toJson();
      json.remove('id'); // Xóa ID để Supabase tự sinh ID mới nếu là insert
      return json;
    }).toList();

    await _supabase
        .from('daily_timesheets')
        .upsert(
          dataToInsert,
          onConflict:
              'user_id, date', // NẾU TRÙNG user_id VÀ date THÌ SẼ UPDATE THAY VÌ INSERT
        );
  }

  // 4. Lấy dữ liệu chấm công của cả THÁNG theo dạng Stream (Thời gian thực)
  Stream<List<TimesheetModel>> streamTimesheetsByMonth(DateTime month) {
    // 1. Xác định khoảng thời gian cần lọc
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(
      month.year,
      month.month + 1,
      0,
      23,
      59,
      59,
    ); // Cuối ngày cuối tháng

    return _supabase.from('daily_timesheets').stream(primaryKey: ['id'])
    // Lưu ý: Nếu có cột user_id, hãy thêm .eq('user_id', ...) ở đây để bảo mật
    .map((List<Map<String, dynamic>> data) {
      return data.map((json) => TimesheetModel.fromJson(json)).where((item) {
          // 2. Chuyển đổi string date từ DB thành DateTime để so sánh
          // Giả sử item.date trong Model là kiểu String (yyyy-MM-dd) hoặc DateTime
          final itemDate = DateTime.parse(item.date.toString());

          // 3. Logic lọc: start <= itemDate <= end
          return (itemDate.isAtSameMomentAs(start) ||
                  itemDate.isAfter(start)) &&
              (itemDate.isAtSameMomentAs(end) || itemDate.isBefore(end));
        }).toList()
        // 4. Sắp xếp lại danh sách theo ngày cho đẹp giao diện
        ..sort((a, b) => a.date.compareTo(b.date));
    });
  }
}
