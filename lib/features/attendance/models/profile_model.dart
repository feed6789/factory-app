import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    @JsonKey(name: 'employee_code') required String employeeCode,
    @JsonKey(name: 'full_name') required String fullName,
    required String role,
    @JsonKey(name: 'department_id') String? departmentId,
    @JsonKey(name: 'division_id') String? divisionId,
    @JsonKey(name: 'manager_id') String? managerId,
    String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'approval_status')
    @Default('approved')
    String? approvalStatus,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}
