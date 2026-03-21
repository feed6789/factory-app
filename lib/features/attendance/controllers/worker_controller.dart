import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_provider.dart';
import '../models/timesheet_model.dart';

// Lấy lịch sử chấm công trong tháng hiện tại của User
final workerMonthlyTimesheetProvider =
    FutureProvider.family<List<TimesheetModel>, String>((ref, userId) async {
      final supabase = ref.read(supabaseProvider);
      final now = DateTime.now();

      // Lấy từ đầu tháng đến cuối tháng
      final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
      final endOfMonth = DateTime(
        now.year,
        now.month + 1,
        0,
        23,
        59,
        59,
      ).toIso8601String();

      final response = await supabase
          .from('daily_timesheets')
          .select()
          .eq('user_id', userId)
          .gte('date', startOfMonth)
          .lte('date', endOfMonth)
          .order('date', ascending: false);

      return response.map((json) => TimesheetModel.fromJson(json)).toList();
    });
