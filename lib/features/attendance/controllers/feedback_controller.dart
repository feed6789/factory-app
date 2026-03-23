import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_provider.dart';
import '../../auth/controllers/auth_controller.dart';

// Provider lấy danh sách góp ý dành cho Quản lý
final feedbackListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final currentUserProfile = await ref.watch(currentProfileProvider.future);

  if (currentUserProfile == null) return [];

  var query = supabase
      .from('employee_feedbacks')
      .select('*, profiles:user_id(full_name, employee_code, department_id)');
  // Phân quyền xem: Admin/Giám đốc xem toàn bộ. Quản đốc/Tổ trưởng chỉ xem của xưởng/tổ mình.
  if (currentUserProfile.role != 'admin' &&
      currentUserProfile.role != 'director') {
    if (currentUserProfile.departmentId != null) {
      query = query.eq(
        'profiles.department_id',
        currentUserProfile.departmentId!,
      );
    } else {
      // Nếu không có department_id, không cho xem gì cả
      return [];
    }
  }

  final response = await query.order('created_at', ascending: false);

  // Xử lý che giấu thông tin nếu là ẩn danh ngay từ Logic thay vì UI để bảo mật
  final List<Map<String, dynamic>> processedList =
      List<Map<String, dynamic>>.from(response).map((item) {
        if (item['is_anonymous'] == true) {
          item['profiles'] = {
            'full_name': 'Người dùng ẩn danh',
            'employee_code': '***',
            'department_id': item['profiles']['department_id'],
          };
        }
        return item;
      }).toList();

  return processedList;
});

final feedbackActionProvider = Provider((ref) => FeedbackActionController(ref));

class FeedbackActionController {
  final Ref ref;
  FeedbackActionController(this.ref);

  Future<bool> submitFeedback({
    required String userId,
    required String type,
    required String content,
    required bool isAnonymous,
  }) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.from('employee_feedbacks').insert({
        'user_id': userId,
        'feedback_type': type,
        'content': content,
        'is_anonymous': isAnonymous,
        'status': 'pending', // pending, reviewed, resolved
      });
      // Làm mới danh sách sau khi gửi
      ref.invalidate(feedbackListProvider);
      return true;
    } catch (e) {
      print("Lỗi gửi ý kiến: $e");
      return false;
    }
  }

  Future<bool> updateFeedbackStatus(String feedbackId, String newStatus) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase
          .from('employee_feedbacks')
          .update({'status': newStatus})
          .eq('id', feedbackId);

      ref.invalidate(feedbackListProvider);
      return true;
    } catch (e) {
      print("Lỗi cập nhật trạng thái ý kiến: $e");
      return false;
    }
  }
}
