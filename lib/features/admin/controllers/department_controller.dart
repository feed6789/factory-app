// File: lib/features/admin/controllers/department_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_provider.dart';

// --- PROVIDERS LẤY DỮ LIỆU ---

final Map<String, String> GROUP_NAMES = {
  "nhan_su": "Quản lý Nhân sự",
  "phong_ban": "Cơ Cấu Tổ Chức & Cấu Hình",
  "cham_cong": "Chấm Công & Xếp Loại",
  "duyet_don": "Duyệt Đơn Từ",
  "bao_cao": "Báo cáo & Thống kê",
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
    "phong_ban_chuc_vu": "Quản lý Chức Vụ",
    "phong_ban_phan_quyen": "Phân Quyền App",
    "phong_ban_cap_bac": "Cấp Bậc Quản Lý",
  },
  "cham_cong": {
    "cham_cong_ngay": "Chấm Công Ngày",
    "cham_cong_thang": "Bảng Công Tháng",
    "cham_cong_danh_gia": "Đánh Giá Xếp Loại",
  },
  "duyet_don": {
    "duyet_don_cho": "Chờ duyệt",
    "duyet_don_lich_su": "Lịch sử đã duyệt",
  },
  "bao_cao": {
    "bao_cao_view_stats": "Xem Thống Kê & Biểu Đồ",
    "bao_cao_enter_data": "Nhập liệu báo cáo hàng ngày",
    "bao_cao_config_cabinet": "Cấu hình (Thêm/Sửa/Xóa Tủ điện)",
  },
  "gop_y": {"gop_y": "Đóng góp Ý kiến"},
};

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

final roleHierarchyProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase.from('role_hierarchy').select();
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

  // 4. THÊM/XÓA PHÂN CẤP
  Future<bool> addRoleHierarchy(String role, String managedBy) async {
    try {
      await ref.read(supabaseProvider).from('role_hierarchy').insert({
        'role': role,
        'managed_by_role': managedBy,
      });
      ref.invalidate(roleHierarchyProvider);
      return true;
    } catch (e) {
      // Ghi log lỗi để debug
      print("Lỗi thêm cấp bậc: $e");
      // Trả về false để UI biết và thông báo
      return false;
    }
  }

  Future<bool> deleteRoleHierarchy(String role, String managedBy) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('role_hierarchy')
          .delete()
          .eq('role', role)
          .eq('managed_by_role', managedBy);
      ref.invalidate(roleHierarchyProvider);
      return true;
    } catch (e) {
      print("Lỗi xóa cấp bậc: $e");
      return false;
    }
  }

  Future<bool> addRole(String code, String name, String? desc) async {
    try {
      await ref.read(supabaseProvider).from('roles').insert({
        'code': code,
        'name': name,
        'description': desc,
      });
      ref.invalidate(roleListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRole(String code, String name, String? desc) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('roles')
          .update({'name': name, 'description': desc})
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
}
