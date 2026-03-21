// File: lib/features/admin/controllers/department_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_provider.dart';

// --- PROVIDERS LẤY DỮ LIỆU ---

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
      return false;
    }
  }
}
