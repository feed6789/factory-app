import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_provider.dart';
import '../../attendance/models/profile_model.dart';

// 1. Lấy danh sách TOÀN BỘ nhân viên (Sắp xếp người đang hoạt động lên đầu)
final employeeListProvider = FutureProvider<List<ProfileModel>>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase
      .from('profiles')
      .select()
      .order('is_active', ascending: false) // Active xếp trên
      .order('full_name', ascending: true);

  return response.map((json) => ProfileModel.fromJson(json)).toList();
});

// 2. Provider xử lý hành động (Sửa, Khóa tài khoản)
final employeeActionProvider = Provider((ref) => EmployeeActionController(ref));

// final roleHierarchyProvider = FutureProvider<List<Map<String, dynamic>>>((
//   ref,
// ) async {
//   final supabase = ref.read(supabaseProvider);
//   final response = await supabase.from('role_hierarchy').select();
//   return List<Map<String, dynamic>>.from(response);
// });

class EmployeeActionController {
  final Ref ref;
  EmployeeActionController(this.ref);

  // SỬA LẠI HÀM NÀY: Trả về Future<bool>, bỏ callback
  Future<bool> updateProfile({
    required String id,
    required String fullName,
    required String empCode,
    required String role,
    required bool isActive,
    String? departmentId,
    String? divisionId,
    String? managerId,
    String? email, // MỚI
    String? phoneNumber, // MỚI
  }) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase
          .from('profiles')
          .update({
            'full_name': fullName,
            'employee_code': empCode,
            'role': role,
            'is_active': isActive,
            'department_id': departmentId,
            'division_id': divisionId,
            'manager_id': managerId,
            'email': email,
            'phone_number': phoneNumber,
          })
          .eq('id', id);

      ref.invalidate(employeeListProvider);
      return true;
    } catch (e) {
      print("Lỗi cập nhật nhân viên: $e");
      return false;
    }
  }

  // SỬA LẠI HÀM NÀY: Trả về Future<bool>
  Future<bool> addEmployee({
    required String fullName,
    required String empCode,
    required String email,
    required String password,
    required String role,
    String? phoneNumber, // MỚI
  }) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.functions.invoke(
        'create_employee',
        body: {
          'fullName': fullName,
          'empCode': empCode,
          'email': email,
          'password': password,
          'role': role,
          'phoneNumber': phoneNumber, // MỚI
        },
      );
      ref.invalidate(employeeListProvider);
      return true;
    } catch (e) {
      print("Lỗi thêm nhân viên: $e");
      return false;
    }
  }

  // Hàm này đã đúng, giữ nguyên
  Future<bool> setEmployeeActiveStatus(String id, bool isActive) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase
          .from('profiles')
          .update({'is_active': isActive})
          .eq('id', id);
      ref.invalidate(employeeListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.functions.invoke('delete_employee', body: {'user_id': id});
      ref.invalidate(employeeListProvider);
      return true;
    } catch (e) {
      print("Lỗi xóa nhân viên: $e");
      return false;
    }
  }
}
