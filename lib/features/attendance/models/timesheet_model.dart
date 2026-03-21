import 'package:freezed_annotation/freezed_annotation.dart';

part 'timesheet_model.freezed.dart';
part 'timesheet_model.g.dart';

@freezed
class TimesheetModel with _$TimesheetModel {
  const factory TimesheetModel({
    String? id, // Sẽ có khi lấy từ DB về, null khi tạo mới
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'date')
    required DateTime date, // Tự động parse từ kiểu date của SQL
    @JsonKey(name: 'shift_type') @Default('Ca Ngày') String shiftType,
    @Default('Có mặt') String status,
    @JsonKey(name: 'overtime_start')
    String? overtimeStart, // Lưu dạng giờ phút '17:00'
    @JsonKey(name: 'overtime_end') String? overtimeEnd,
    String? notes,
  }) = _TimesheetModel;

  factory TimesheetModel.fromJson(Map<String, dynamic> json) =>
      _$TimesheetModelFromJson(json);
}
