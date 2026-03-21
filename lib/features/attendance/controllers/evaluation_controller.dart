import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/supabase_provider.dart';
import '../models/evaluation_model.dart';
import '../../auth/controllers/auth_controller.dart';
import 'attendance_controller.dart';

// State lưu tháng đang chọn để đánh giá
final evaluationMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

// Provider lấy danh sách đánh giá của bộ phận trong tháng
final monthlyEvaluationsProvider = FutureProvider<List<EvaluationModel>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final month = ref.watch(evaluationMonthProvider);
  final monthYearStr = DateFormat('yyyy-MM').format(month);

  final currentUser = ref.watch(currentProfileProvider).valueOrNull;
  if (currentUser == null) return [];

  final response = await supabase
      .from('monthly_evaluations')
      .select()
      .eq('manager_id', currentUser.id)
      .eq('month_year', monthYearStr);

  return response.map((json) => EvaluationModel.fromJson(json)).toList();
});

// Controller xử lý các Action (Lưu nháp, Gửi HR)
final evaluationActionProvider = Provider(
  (ref) => EvaluationActionController(ref),
);

class EvaluationActionController {
  final Ref ref;
  EvaluationActionController(this.ref);

  Future<bool> saveEvaluation(EvaluationModel evaluation) async {
    try {
      final supabase = ref.read(supabaseProvider);

      final data = evaluation.toJson();
      data.remove('id'); // Supabase tự tạo ID nếu là insert mới

      await supabase
          .from('monthly_evaluations')
          .upsert(data, onConflict: 'user_id, month_year');

      // Refresh lại danh sách
      ref.invalidate(monthlyEvaluationsProvider);
      return true;
    } catch (e) {
      print("Lỗi lưu đánh giá: $e");
      return false;
    }
  }

  Future<bool> submitAllEvaluations() async {
    try {
      final supabase = ref.read(supabaseProvider);
      final month = ref.read(evaluationMonthProvider);
      final monthYearStr = DateFormat('yyyy-MM').format(month);
      final currentUser = ref.read(currentProfileProvider).valueOrNull;

      if (currentUser == null) return false;

      // Cập nhật tất cả các bản nháp của tháng này thành 'submitted'
      await supabase
          .from('monthly_evaluations')
          .update({'status': 'submitted'})
          .eq('manager_id', currentUser.id)
          .eq('month_year', monthYearStr)
          .eq('status', 'draft');

      ref.invalidate(monthlyEvaluationsProvider);
      return true;
    } catch (e) {
      print("Lỗi gửi đánh giá: $e");
      return false;
    }
  }
}
