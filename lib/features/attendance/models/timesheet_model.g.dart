// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timesheet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimesheetModelImpl _$$TimesheetModelImplFromJson(Map<String, dynamic> json) =>
    _$TimesheetModelImpl(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      shiftType: json['shift_type'] as String? ?? 'Ca Ngày',
      status: json['status'] as String? ?? 'Có mặt',
      overtimeStart: json['overtime_start'] as String?,
      overtimeEnd: json['overtime_end'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$TimesheetModelImplToJson(
  _$TimesheetModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'date': instance.date.toIso8601String(),
  'shift_type': instance.shiftType,
  'status': instance.status,
  'overtime_start': instance.overtimeStart,
  'overtime_end': instance.overtimeEnd,
  'notes': instance.notes,
};
