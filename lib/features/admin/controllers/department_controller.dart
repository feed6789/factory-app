// File: lib/features/admin/controllers/department_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_provider.dart';

// --- PROVIDERS LẤY DỮ LIỆU ---

// Khôi phục lại ở đầu file
final Map<String, String> GROUP_NAMES = {
  "nhan_su": "Quản lý Nhân sự",
  "phong_ban": "Cơ Cấu Tổ Chức & Cấu Hình",
  "cham_cong": "Chấm Công & Xếp Loại",
  "duyet_don": "Duyệt Đơn Từ",
  "nhap_lieu": "Nhập Số Liệu & Cấu Hình Máy",
  "bao_cao": "Báo cáo & Thống kê",
  "vat_tu": "Quản Lý Vật Tư & Đề Xuất",
  "gop_y": "Đóng Góp & Tiện Ích",
};

final Map<String, Map<String, String>> ALL_FEATURES_NESTED = {
  "nhan_su": {
    "nhan_su_view": "Xem danh sách & Tìm kiếm",
    "nhan_su_add": "Thêm nhân viên",
    "nhan_su_edit": "Sửa/Khóa nhân viên",
    "nhan_su_delete": "Xóa vĩnh viễn",
  },
  "phong_ban": {
    "phong_ban_bo_phan": "Quản lý Bộ Phận",
    "phong_ban_phong_ban": "Quản lý Phòng Ban",
    "phong_ban_chuc_vu": "Quản lý Chức Vụ & Cấp Bậc",
    "phong_ban_phan_quyen": "Phân Quyền App",
  },
  "cham_cong": {
    "cham_cong_ngay": "Chấm Công Ngày",
    "cham_cong_thang": "Bảng Công Tháng",
    "cham_cong_danh_gia": "Đánh Giá Xếp Loại",
    "cham_cong_cau_hinh": "Cấu hình Ca/Trạng thái",
  },
  "duyet_don": {
    "duyet_don_cho": "Chờ duyệt",
    "duyet_don_lich_su": "Lịch sử đã duyệt",
  },
  "nhap_lieu": {
    "nhap_lieu_dien": "Nhập số điện tiêu thụ",
    "nhap_lieu_cau_hinh": "Cấu hình Máy móc / Tủ điện",
  },
  "bao_cao": {"bao_cao_view_stats": "Xem Thống Kê & Biểu Đồ"},
  "vat_tu": {
    "vat_tu_xem_kho": "Xem Tồn kho & Nhập/Xuất", // Của tính năng Kho cũ
    "vat_tu_de_xuat": "Tạo phiếu & Xem phiếu cá nhân", // Của tính năng Đề xuất
    "vat_tu_duyet": "Duyệt phiếu đề xuất",
    "vat_tu_lich_su": "Xem lịch sử phiếu đề xuất",
    "vat_tu_danh_muc": "Quản lý danh mục Mã VTPT",
  },
  "gop_y": {"gop_y": "Đóng góp Ý kiến"},
};

final shiftConfigsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase
      .from('shift_configs')
      .select()
      .order('created_at', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});

final attendanceStatusConfigsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final supabase = ref.read(supabaseProvider);
      final response = await supabase
          .from('attendance_status_configs')
          .select()
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    });

final divisionListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase
      .from('divisions')
      .select()
      .order('name', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});

final roleListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase
      .from('roles')
      .select()
      .order('created_at', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});

final departmentListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase
      .from('departments')
      .select('id, name, description, division_id')
      .order('name', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});

final rolePermissionsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase.from('role_permissions').select();
  return List<Map<String, dynamic>>.from(response);
});

final approvalWorkflowsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase
      .from('approval_workflows')
      .select()
      .order('created_at', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});

// --- CONTROLLER XỬ LÝ HÀNH ĐỘNG ---

final systemActionProvider = Provider((ref) => SystemActionController(ref));

class SystemActionController {
  final Ref ref;
  SystemActionController(this.ref);

  // 1. CRUD BỘ PHẬN (DIVISIONS)
  Future<bool> addDivision(String name, String? description) async {
    try {
      await ref.read(supabaseProvider).from('divisions').insert({
        'name': name,
        'description': description,
      });
      ref.invalidate(divisionListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateDivision(
    String id,
    String name,
    String? description,
  ) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('divisions')
          .update({'name': name, 'description': description})
          .eq('id', id);
      ref.invalidate(divisionListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> deleteDivision(String id) async {
    try {
      await ref.read(supabaseProvider).from('divisions').delete().eq('id', id);
      ref.invalidate(divisionListProvider);
      return "OK";
    } catch (e) {
      return "Không thể xóa bộ phận này vì đang có phòng ban thuộc về nó.";
    }
  }

  // 2. CRUD PHÒNG BAN (DEPARTMENTS)
  Future<bool> addDepartment({
    required String name,
    String? description,
    String? divisionId,
  }) async {
    try {
      await ref.read(supabaseProvider).from('departments').insert({
        'name': name,
        'description': description,
        'division_id': divisionId,
      });
      ref.invalidate(departmentListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateDepartment({
    required String id,
    required String name,
    String? description,
    String? divisionId,
  }) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('departments')
          .update({
            'name': name,
            'description': description,
            'division_id': divisionId,
          })
          .eq('id', id);
      ref.invalidate(departmentListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> deleteDepartment(String id) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('departments')
          .delete()
          .eq('id', id);
      ref.invalidate(departmentListProvider);
      return "OK";
    } catch (e) {
      return "Không thể xóa phòng ban này vì vẫn còn nhân viên.";
    }
  }

  // 3. CẬP NHẬT PHÂN QUYỀN
  Future<bool> updateRolePermissions(String role, List<String> features) async {
    try {
      await ref.read(supabaseProvider).from('role_permissions').upsert({
        'role': role,
        'allowed_features': features,
      });
      ref.invalidate(rolePermissionsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addApprovalWorkflow(
    String roleCode,
    String workflowName,
    String moduleType,
    List<String> steps,
  ) async {
    try {
      await ref.read(supabaseProvider).from('approval_workflows').insert({
        'role_code': roleCode,
        'workflow_name': workflowName,
        'module_type': moduleType, // <--- LƯU VÀO DB
        'steps': steps,
      });
      ref.invalidate(approvalWorkflowsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> deleteApprovalWorkflow(String id) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('approval_workflows')
          .delete()
          .eq('id', id);
      ref.invalidate(approvalWorkflowsProvider);
      return "Đã xóa quy trình";
    } catch (e) {
      return "Lỗi khi xóa quy trình";
    }
  }

  Future<bool> addRole(
    String code,
    String name,
    String? desc,
    int levelRank,
  ) async {
    try {
      await ref.read(supabaseProvider).from('roles').insert({
        'code': code,
        'name': name,
        'description': desc,
        'level_rank': levelRank,
      });
      ref.invalidate(roleListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRole(
    String code,
    String name,
    String? desc,
    int levelRank,
  ) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('roles')
          .update({'name': name, 'description': desc, 'level_rank': levelRank})
          .eq('code', code);
      ref.invalidate(roleListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> deleteRole(String code) async {
    if (code == 'admin') return "Không thể xóa chức vụ Admin mặc định!";
    try {
      await ref.read(supabaseProvider).from('roles').delete().eq('code', code);
      ref.invalidate(roleListProvider);
      return "OK";
    } catch (e) {
      return "Không thể xóa do có nhân viên đang giữ chức vụ này.";
    }
  }

  // --- 1. PROVIDERS ĐỂ LẤY DỮ LIỆU CẤU HÌNH ĐỘNG ---
  final shiftConfigsProvider = FutureProvider<List<Map<String, dynamic>>>((
    ref,
  ) async {
    final supabase = ref.read(supabaseProvider);
    final response = await supabase
        .from('shift_configs')
        .select()
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  });

  final attendanceStatusConfigsProvider =
      FutureProvider<List<Map<String, dynamic>>>((ref) async {
        final supabase = ref.read(supabaseProvider);
        final response = await supabase
            .from('attendance_status_configs')
            .select()
            .order('created_at', ascending: true);
        return List<Map<String, dynamic>>.from(response);
      });

  // --- 2. THÊM CÁC HÀM CRUD VÀO SystemActionController ---
  // (Tìm class SystemActionController và thêm vào trong đó)

  // Quản lý Ca làm việc (Shift)
  Future<bool> addShiftConfig(String name, String symbol) async {
    try {
      await ref.read(supabaseProvider).from('shift_configs').insert({
        'name': name,
        'symbol': symbol,
        'is_active': true,
      });
      ref.invalidate(shiftConfigsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateShiftConfig(
    String id,
    String name,
    String symbol,
    bool isActive,
  ) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('shift_configs')
          .update({'name': name, 'symbol': symbol, 'is_active': isActive})
          .eq('id', id);
      ref.invalidate(shiftConfigsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> deleteShiftConfig(String id) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('shift_configs')
          .delete()
          .eq('id', id);
      ref.invalidate(shiftConfigsProvider);
      return "OK";
    } catch (e) {
      return "Lỗi: Không thể xóa vì ca này đã được dùng để chấm công.";
    }
  }

  // Quản lý Trạng thái công (Attendance Status)
  Future<bool> addAttendanceStatusConfig(String name, String symbol) async {
    try {
      await ref.read(supabaseProvider).from('attendance_status_configs').insert(
        {'name': name, 'symbol': symbol, 'is_active': true},
      );
      ref.invalidate(attendanceStatusConfigsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAttendanceStatusConfig(
    String id,
    String name,
    String symbol,
    bool isActive,
  ) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('attendance_status_configs')
          .update({'name': name, 'symbol': symbol, 'is_active': isActive})
          .eq('id', id);
      ref.invalidate(attendanceStatusConfigsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> deleteAttendanceStatusConfig(String id) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('attendance_status_configs')
          .delete()
          .eq('id', id);
      ref.invalidate(attendanceStatusConfigsProvider);
      return "OK";
    } catch (e) {
      return "Lỗi: Không thể xóa vì trạng thái này đã được dùng.";
    }
  }
}
