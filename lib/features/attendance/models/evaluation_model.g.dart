// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EvaluationModelImpl _$$EvaluationModelImplFromJson(
  Map<String, dynamic> json,
) => _$EvaluationModelImpl(
  id: json['id'] as String?,
  userId: json['user_id'] as String,
  managerId: json['manager_id'] as String,
  monthYear: json['month_year'] as String,
  skillRating: json['skill_rating'] as String,
  attitudeRating: json['attitude_rating'] as String,
  workingDays: (json['working_days'] as num?)?.toDouble() ?? 0,
  leaveDays: (json['leave_days'] as num?)?.toDouble() ?? 0,
  unpaidLeaveDays: (json['unpaid_leave_days'] as num?)?.toDouble() ?? 0,
  unexcusedDays: (json['unexcused_days'] as num?)?.toDouble() ?? 0,
  violations: json['violations'] as String,
  monthlyGrade: json['monthly_grade'] as String,
  proposedAction: json['proposed_action'] as String,
  status: json['status'] as String? ?? 'draft',
);

Map<String, dynamic> _$$EvaluationModelImplToJson(
  _$EvaluationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'manager_id': instance.managerId,
  'month_year': instance.monthYear,
  'skill_rating': instance.skillRating,
  'attitude_rating': instance.attitudeRating,
  'working_days': instance.workingDays,
  'leave_days': instance.leaveDays,
  'unpaid_leave_days': instance.unpaidLeaveDays,
  'unexcused_days': instance.unexcusedDays,
  'violations': instance.violations,
  'monthly_grade': instance.monthlyGrade,
  'proposed_action': instance.proposedAction,
  'status': instance.status,
};
