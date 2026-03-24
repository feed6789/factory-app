import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/supabase_provider.dart';
import 'package:ung_dung_nm/features/auth/controllers/auth_controller.dart';

// 1. Lấy danh sách đơn CỦA CÁ NHÂN (Dành cho Worker)
final myLeaveRequestsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      final supabase = ref.read(supabaseProvider);
      final response = await supabase
          .from('leave_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    });

// 2. Lấy danh sách đơn ĐANG CHỜ DUYỆT (Dành cho Admin/Manager)
final pendingLeaveRequestsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final supabase = ref.read(supabaseProvider);
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return [];

    final response = await supabase
        .from('leave_requests')
        .select('*, profiles:user_id!inner(full_name, employee_code)')
        .eq('current_approver_id', currentUser.id) // CHỈ LẤY ĐƠN CẦN MÌNH DUYỆT
        .filter(
          'status',
          'in',
          '("pending_leader","pending_manager")',
        ) // Lấy tất cả các trạng thái bắt đầu bằng pending_
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  },
);

final processedLeaveRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final currentUserProfile = await ref.watch(currentProfileProvider.future);
  if (currentUserProfile == null) return [];

  var query = supabase
      .from('leave_requests')
      .select(
        '*, profiles:user_id!inner(full_name, employee_code, department_id, division_id)',
      )
      .inFilter('status', ['approved', 'rejected']);

  // Nếu không phải Admin/Giám đốc, chỉ lấy lịch sử của nhân viên thuộc bộ phận/phòng ban mình
  if (currentUserProfile.role != 'admin' &&
      currentUserProfile.role != 'director') {
    if (currentUserProfile.departmentId != null) {
      query = query.eq(
        'profiles.department_id',
        currentUserProfile.departmentId!,
      );
    }
  }

  final response = await query.order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

// 3. Controller thao tác Gửi / Duyệt
final leaveActionProvider = Provider((ref) => LeaveActionController(ref));

class LeaveActionController {
  final Ref ref;
  LeaveActionController(this.ref);

  // Worker gửi đơn
  Future<bool> submitLeaveRequest({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String reason,
    required String placeOfLeave, // MỚI
    required String approverId, // MỚI (Lấy trực tiếp từ Dropdown của UI)
    required String leaveType,
  }) async {
    try {
      final supabase = ref.read(supabaseProvider);

      // Không cần tự tìm approver nữa vì UI đã chọn
      String initialStatus = 'pending_leader';
      // Kiểm tra xem người duyệt có phải giám đốc không để đổi status
      final approverProfile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', approverId)
          .single();
      if (approverProfile['role'] == 'director' ||
          approverProfile['role'] == 'admin') {
        initialStatus = 'pending_manager';
      }

      await supabase.from('leave_requests').insert({
        'user_id': userId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'reason': reason,
        'place_of_leave': placeOfLeave, // Lưu vào db
        'leave_type': leaveType,
        'status': initialStatus,
        'current_approver_id': approverId,
        'approval_history': [],
      });

      ref.invalidate(myLeaveRequestsProvider(userId));
      ref.invalidate(pendingLeaveRequestsProvider);
      return true;
    } catch (e) {
      print("Lỗi gửi đơn: $e");
      return false;
    }
  }

  // HÀM DUYỆT/TỪ CHỐI ĐƠN ĐÃ NÂNG CẤP
  Future<bool> updateRequestStatus(String requestId, String newStatus) async {
    try {
      final supabase = ref.read(supabaseProvider);
      final currentUserProfile = await ref.read(currentProfileProvider.future);
      if (currentUserProfile == null) return false;

      // 1. Lấy thông tin đơn hiện tại
      final request = await supabase
          .from('leave_requests')
          .select()
          .eq('id', requestId)
          .single();
      final currentHistory = List.from(request['approval_history'] ?? []);

      // 2. Cập nhật lịch sử duyệt
      currentHistory.add({
        'approver_id': currentUserProfile.id,
        'approver_name': currentUserProfile.fullName,
        'approver_role': currentUserProfile.role,
        'status': newStatus, // 'approved' or 'rejected'
        'timestamp': DateTime.now().toIso8601String(),
      });

      String? nextApproverId;
      String finalStatus = request['status'];

      if (newStatus == 'rejected') {
        finalStatus = 'rejected';
        nextApproverId = null;
      } else {
        // 'approved'
        // Nếu người duyệt là quản lý cấp trung (tổ trưởng)
        if (currentUserProfile.role == 'team_leader' ||
            currentUserProfile.role == 'section_head') {
          // Chuyển lên cấp giám đốc
          final directorRes = await supabase
              .from('profiles')
              .select('id')
              .eq('role', 'director')
              .limit(1)
              .single();
          nextApproverId = directorRes['id'];
          finalStatus = 'pending_manager';
        } else {
          finalStatus = 'approved';
          nextApproverId = null;

          // ---- ĐÃ SỬA LỖI TẠI ĐÂY ----
          // Trích xuất ngày từ start_time để lưu vào bảng chấm công
          final startTimeDate = DateTime.parse(request['start_time']);
          final dateStr = DateFormat('yyyy-MM-dd').format(startTimeDate);

          await supabase.from('daily_timesheets').upsert({
            'user_id': request['user_id'],
            'date': dateStr, // Dùng ngày vừa trích xuất
            'status': request['leave_type'],
            'shift_type': 'Không chấm',
            'notes': 'Đã duyệt nghỉ',
          }, onConflict: 'user_id, date');
        }
      }

      // 3. Cập nhật đơn
      await supabase
          .from('leave_requests')
          .update({
            'status': finalStatus,
            'current_approver_id': nextApproverId,
            'approval_history': currentHistory,
          })
          .eq('id', requestId);

      ref.invalidate(pendingLeaveRequestsProvider);
      return true;
    } catch (e) {
      print("Lỗi duyệt đơn: $e");
      return false;
    }
  }
}
