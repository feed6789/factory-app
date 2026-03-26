// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) {
  return _ProfileModel.fromJson(json);
}

/// @nodoc
mixin _$ProfileModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'employee_code')
  String get employeeCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'department_id')
  String? get departmentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'division_id')
  String? get divisionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'manager_id')
  String? get managerId => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'approval_status')
  String? get approvalStatus => throw _privateConstructorUsedError;

  /// Serializes this ProfileModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileModelCopyWith<ProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileModelCopyWith<$Res> {
  factory $ProfileModelCopyWith(
    ProfileModel value,
    $Res Function(ProfileModel) then,
  ) = _$ProfileModelCopyWithImpl<$Res, ProfileModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'employee_code') String employeeCode,
    @JsonKey(name: 'full_name') String fullName,
    String role,
    @JsonKey(name: 'department_id') String? departmentId,
    @JsonKey(name: 'division_id') String? divisionId,
    @JsonKey(name: 'manager_id') String? managerId,
    String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'approval_status') String? approvalStatus,
  });
}

/// @nodoc
class _$ProfileModelCopyWithImpl<$Res, $Val extends ProfileModel>
    implements $ProfileModelCopyWith<$Res> {
  _$ProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeCode = null,
    Object? fullName = null,
    Object? role = null,
    Object? departmentId = freezed,
    Object? divisionId = freezed,
    Object? managerId = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? isActive = null,
    Object? approvalStatus = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeCode: null == employeeCode
                ? _value.employeeCode
                : employeeCode // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            departmentId: freezed == departmentId
                ? _value.departmentId
                : departmentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            divisionId: freezed == divisionId
                ? _value.divisionId
                : divisionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            managerId: freezed == managerId
                ? _value.managerId
                : managerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            approvalStatus: freezed == approvalStatus
                ? _value.approvalStatus
                : approvalStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileModelImplCopyWith<$Res>
    implements $ProfileModelCopyWith<$Res> {
  factory _$$ProfileModelImplCopyWith(
    _$ProfileModelImpl value,
    $Res Function(_$ProfileModelImpl) then,
  ) = __$$ProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'employee_code') String employeeCode,
    @JsonKey(name: 'full_name') String fullName,
    String role,
    @JsonKey(name: 'department_id') String? departmentId,
    @JsonKey(name: 'division_id') String? divisionId,
    @JsonKey(name: 'manager_id') String? managerId,
    String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'approval_status') String? approvalStatus,
  });
}

/// @nodoc
class __$$ProfileModelImplCopyWithImpl<$Res>
    extends _$ProfileModelCopyWithImpl<$Res, _$ProfileModelImpl>
    implements _$$ProfileModelImplCopyWith<$Res> {
  __$$ProfileModelImplCopyWithImpl(
    _$ProfileModelImpl _value,
    $Res Function(_$ProfileModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeCode = null,
    Object? fullName = null,
    Object? role = null,
    Object? departmentId = freezed,
    Object? divisionId = freezed,
    Object? managerId = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? isActive = null,
    Object? approvalStatus = freezed,
  }) {
    return _then(
      _$ProfileModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeCode: null == employeeCode
            ? _value.employeeCode
            : employeeCode // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        departmentId: freezed == departmentId
            ? _value.departmentId
            : departmentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        divisionId: freezed == divisionId
            ? _value.divisionId
            : divisionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        managerId: freezed == managerId
            ? _value.managerId
            : managerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        approvalStatus: freezed == approvalStatus
            ? _value.approvalStatus
            : approvalStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileModelImpl implements _ProfileModel {
  const _$ProfileModelImpl({
    required this.id,
    @JsonKey(name: 'employee_code') required this.employeeCode,
    @JsonKey(name: 'full_name') required this.fullName,
    required this.role,
    @JsonKey(name: 'department_id') this.departmentId,
    @JsonKey(name: 'division_id') this.divisionId,
    @JsonKey(name: 'manager_id') this.managerId,
    this.email,
    @JsonKey(name: 'phone_number') this.phoneNumber,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'approval_status') this.approvalStatus = 'approved',
  });

  factory _$ProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'employee_code')
  final String employeeCode;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String role;
  @override
  @JsonKey(name: 'department_id')
  final String? departmentId;
  @override
  @JsonKey(name: 'division_id')
  final String? divisionId;
  @override
  @JsonKey(name: 'manager_id')
  final String? managerId;
  @override
  final String? email;
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'approval_status')
  final String? approvalStatus;

  @override
  String toString() {
    return 'ProfileModel(id: $id, employeeCode: $employeeCode, fullName: $fullName, role: $role, departmentId: $departmentId, divisionId: $divisionId, managerId: $managerId, email: $email, phoneNumber: $phoneNumber, isActive: $isActive, approvalStatus: $approvalStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeCode, employeeCode) ||
                other.employeeCode == employeeCode) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.departmentId, departmentId) ||
                other.departmentId == departmentId) &&
            (identical(other.divisionId, divisionId) ||
                other.divisionId == divisionId) &&
            (identical(other.managerId, managerId) ||
                other.managerId == managerId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.approvalStatus, approvalStatus) ||
                other.approvalStatus == approvalStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    employeeCode,
    fullName,
    role,
    departmentId,
    divisionId,
    managerId,
    email,
    phoneNumber,
    isActive,
    approvalStatus,
  );

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileModelImplCopyWith<_$ProfileModelImpl> get copyWith =>
      __$$ProfileModelImplCopyWithImpl<_$ProfileModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileModelImplToJson(this);
  }
}

abstract class _ProfileModel implements ProfileModel {
  const factory _ProfileModel({
    required final String id,
    @JsonKey(name: 'employee_code') required final String employeeCode,
    @JsonKey(name: 'full_name') required final String fullName,
    required final String role,
    @JsonKey(name: 'department_id') final String? departmentId,
    @JsonKey(name: 'division_id') final String? divisionId,
    @JsonKey(name: 'manager_id') final String? managerId,
    final String? email,
    @JsonKey(name: 'phone_number') final String? phoneNumber,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'approval_status') final String? approvalStatus,
  }) = _$ProfileModelImpl;

  factory _ProfileModel.fromJson(Map<String, dynamic> json) =
      _$ProfileModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'employee_code')
  String get employeeCode;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  String get role;
  @override
  @JsonKey(name: 'department_id')
  String? get departmentId;
  @override
  @JsonKey(name: 'division_id')
  String? get divisionId;
  @override
  @JsonKey(name: 'manager_id')
  String? get managerId;
  @override
  String? get email;
  @override
  @JsonKey(name: 'phone_number')
  String? get phoneNumber;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'approval_status')
  String? get approvalStatus;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileModelImplCopyWith<_$ProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
