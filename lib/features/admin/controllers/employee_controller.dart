import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_provider.dart';
import '../../attendance/models/profile_model.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

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

  Future<bool> updateCredentials(
    String userId,
    String? newEmail,
    String? newPassword,
  ) async {
    try {
      final supabase = ref.read(supabaseProvider);

      await supabase.functions.invoke(
        'update_credentials',
        body: {
          'user_id': userId,
          'new_email': newEmail,
          'new_password': newPassword,
        },
      );
      return true;
    } catch (e) {
      print("Lỗi cập nhật Auth: $e");
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

  Future<bool> approveEmployee(String id) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase
          .from('profiles')
          .update({'is_active': true, 'approval_status': 'approved'})
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

  Future<void> exportEmployeesToCsv(List<ProfileModel> employees) async {
    // Định nghĩa các cột cần xuất
    final List<String> headers = [
      'employee_code',
      'full_name',
      'email',
      'phone_number',
      'role',
      'is_active',
    ];

    List<List<dynamic>> rows = [];
    rows.add(headers);

    for (var emp in employees) {
      rows.add([
        emp.employeeCode,
        emp.fullName,
        emp.email ?? '',
        emp.phoneNumber ?? '',
        emp.role,
        emp.isActive,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // Xử lý tải file (hiện tại tối ưu cho Web)
    if (kIsWeb) {
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "danh_sach_nhan_vien.csv")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // TODO: Thêm logic lưu file cho mobile/desktop (dùng path_provider, permission_handler)
      print("Export for mobile/desktop is not implemented yet.");
    }
  }

  // ===============================================
  // HÀM MỚI: NHẬP DỮ LIỆU TỪ FILE CSV
  // ===============================================
  // Thay thế toàn bộ hàm cũ bằng hàm này:
  Future<String> importEmployeesFromCsv() async {
    try {
      final supabase = ref.read(supabaseProvider);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return "Hủy bỏ. Không có file nào được chọn.";

      Uint8List bytes = result.files.single.bytes!;
      // Sửa lỗi Encoding BOM
      if (bytes.length > 3 &&
          bytes[0] == 239 &&
          bytes[1] == 187 &&
          bytes[2] == 191) {
        bytes = bytes.sublist(3);
      }
      final csvString = utf8.decode(bytes, allowMalformed: true);

      // GỌI HÀM NGUYÊN BẢN (Không tự nhét headers vào nữa)
      final response = await supabase.functions.invoke(
        'bulk_upsert_employees',
        body: {'csvData': csvString},
      );

      if (response.status != 200) {
        final errorData = response.data;
        if (response.status == 403 &&
            errorData is Map &&
            errorData.containsKey('error')) {
          return "Từ chối truy cập: ${errorData['error']}";
        }
        if (errorData is Map && errorData.containsKey('error')) {
          throw Exception(errorData['error']);
        }
        throw Exception('Lỗi máy chủ: Status ${response.status}.');
      }

      ref.invalidate(employeeListProvider);
      return response.data['message'] ?? "Import thành công!";
    } catch (e) {
      print("CSV Error: $e");
      if (e.toString().contains('JWT') || e.toString().contains('401')) {
        return "Phiên đăng nhập không hợp lệ. Vui lòng đăng xuất và đăng nhập lại.";
      }
      return "Import thất bại: Cấu trúc file không đúng hoặc có lỗi kết nối.";
    }
  }
}
