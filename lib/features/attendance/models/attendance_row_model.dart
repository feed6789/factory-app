import 'profile_model.dart';
import 'timesheet_model.dart';

// Class này đại diện cho 1 dòng trên màn hình chấm công
class AttendanceRowModel {
  final ProfileModel profile;
  final TimesheetModel timesheet;

  AttendanceRowModel({required this.profile, required this.timesheet});

  // Hàm copyWith để copy và cập nhật giá trị mới một cách dễ dàng (đặc sản của Riverpod)
  AttendanceRowModel copyWith({
    ProfileModel? profile,
    TimesheetModel? timesheet,
  }) {
    return AttendanceRowModel(
      profile: profile ?? this.profile,
      timesheet: timesheet ?? this.timesheet,
    );
  }
}
