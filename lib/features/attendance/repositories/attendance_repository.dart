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
  Future<List<TimesheetModel>> getTimesheetsByMonth(DateTime month) async {
    final startStr = DateTime(month.year, month.month, 1).toIso8601String();
    final endStr = DateTime(
      month.year,
      month.month + 1,
      0,
      23,
      59,
      59,
    ).toIso8601String();

    final response = await _supabase
        .from('daily_timesheets')
        .select()
        .gte('date', startStr)
        .lte('date', endStr);

    return response.map((json) => TimesheetModel.fromJson(json)).toList();
  }
}
