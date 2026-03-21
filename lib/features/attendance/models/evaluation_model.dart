import 'package:freezed_annotation/freezed_annotation.dart';

part 'evaluation_model.freezed.dart';
part 'evaluation_model.g.dart';

@freezed
class EvaluationModel with _$EvaluationModel {
  const factory EvaluationModel({
    String? id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'manager_id') required String managerId,
    @JsonKey(name: 'month_year') required String monthYear,
    @JsonKey(name: 'skill_rating') required String skillRating,
    @JsonKey(name: 'attitude_rating') required String attitudeRating,
    @JsonKey(name: 'working_days') @Default(0) double workingDays,
    @JsonKey(name: 'leave_days') @Default(0) double leaveDays,
    @JsonKey(name: 'unpaid_leave_days') @Default(0) double unpaidLeaveDays,
    @JsonKey(name: 'unexcused_days') @Default(0) double unexcusedDays,
    required String violations,
    @JsonKey(name: 'monthly_grade') required String monthlyGrade,
    @JsonKey(name: 'proposed_action') required String proposedAction,
    @Default('draft') String status,
  }) = _EvaluationModel;

  factory EvaluationModel.fromJson(Map<String, dynamic> json) =>
      _$EvaluationModelFromJson(json);
}
