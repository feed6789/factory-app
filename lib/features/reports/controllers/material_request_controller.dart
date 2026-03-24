import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_provider.dart';

// 1. Lấy danh mục VTPT để chọn
final materialCatalogsProvider = FutureProvider((ref) async {
  final res = await ref
      .read(supabaseProvider)
      .from('material_catalogs')
      .select()
      .eq('is_active', true)
      .order('name');
  return res;
});

// 2. Lịch sử xin của cá nhân (Nhân viên)
final myMaterialRequestsProvider = FutureProvider.family<List<dynamic>, String>(
  (ref, userId) async {
    final res = await ref
        .read(supabaseProvider)
        .from('material_requests')
        .select('*, departments(name)')
        .eq('requester_id', userId)
        .order('created_at', ascending: false);
    return res;
  },
);

// 3. Danh sách phiếu chờ duyệt (Dành cho Quản lý)
final pendingMaterialRequestsProvider = FutureProvider((ref) async {
  final res = await ref
      .read(supabaseProvider)
      .from('material_requests')
      .select('*, profiles:requester_id(full_name), departments(name)')
      .eq('status', 'pending_leader')
      .order('created_at', ascending: false);
  return res;
});

final materialRequestActionProvider = Provider(
  (ref) => MaterialRequestActionController(ref),
);

class MaterialRequestActionController {
  final Ref ref;
  MaterialRequestActionController(this.ref);

  // Thêm danh mục VTPT mới
  Future<bool> addCatalog(String name, String origin, String unit) async {
    try {
      await ref.read(supabaseProvider).from('material_catalogs').insert({
        'name': name,
        'origin': origin,
        'unit': unit,
      });
      ref.invalidate(materialCatalogsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Nhân viên Gửi đề xuất
  Future<bool> submitRequest(
    String userId,
    String deptId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      // Tự sinh mã phiếu tạm thời: DX-UnixTime
      final tempNumber =
          "DX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

      await ref.read(supabaseProvider).from('material_requests').insert({
        'requester_id': userId,
        'department_id': deptId,
        'request_number': tempNumber,
        'items': items,
        'status': 'pending_leader',
      });
      ref.invalidate(myMaterialRequestsProvider(userId));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateCatalog(
    String id,
    String name,
    String origin,
    String unit,
  ) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('material_catalogs')
          .update({'name': name, 'origin': origin, 'unit': unit})
          .eq('id', id);
      ref.invalidate(materialCatalogsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  // THÊM: Xóa danh mục
  Future<String> deleteCatalog(String id) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('material_catalogs')
          .delete()
          .eq('id', id);
      ref.invalidate(materialCatalogsProvider);
      return "OK";
    } catch (e) {
      return "Không thể xóa do vật tư này đã được dùng trong các phiếu đề xuất cũ.";
    }
  }

  // Quản lý Duyệt / Từ chối
  Future<bool> processRequest(
    String requestId,
    String status,
    String officialNumber,
    String notes,
    List<dynamic> updatedItems,
  ) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('material_requests')
          .update({
            'status': status, // 'approved' hoặc 'rejected'
            'request_number': officialNumber,
            'manager_notes': notes,
            'items': updatedItems,
          })
          .eq('id', requestId);

      ref.invalidate(pendingMaterialRequestsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}
