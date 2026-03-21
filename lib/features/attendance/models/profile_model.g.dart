// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileModelImpl _$$ProfileModelImplFromJson(Map<String, dynamic> json) =>
    _$ProfileModelImpl(
      id: json['id'] as String,
      employeeCode: json['employee_code'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      departmentId: json['department_id'] as String?,
      divisionId: json['division_id'] as String?,
      managerId: json['manager_id'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$ProfileModelImplToJson(_$ProfileModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_code': instance.employeeCode,
      'full_name': instance.fullName,
      'role': instance.role,
      'department_id': instance.departmentId,
      'division_id': instance.divisionId,
      'manager_id': instance.managerId,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'is_active': instance.isActive,
    };
