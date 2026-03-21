// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evaluation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EvaluationModel _$EvaluationModelFromJson(Map<String, dynamic> json) {
  return _EvaluationModel.fromJson(json);
}

/// @nodoc
mixin _$EvaluationModel {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'manager_id')
  String get managerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'month_year')
  String get monthYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'skill_rating')
  String get skillRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'attitude_rating')
  String get attitudeRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'working_days')
  double get workingDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'leave_days')
  double get leaveDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'unpaid_leave_days')
  double get unpaidLeaveDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'unexcused_days')
  double get unexcusedDays => throw _privateConstructorUsedError;
  String get violations => throw _privateConstructorUsedError;
  @JsonKey(name: 'monthly_grade')
  String get monthlyGrade => throw _privateConstructorUsedError;
  @JsonKey(name: 'proposed_action')
  String get proposedAction => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this EvaluationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EvaluationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EvaluationModelCopyWith<EvaluationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EvaluationModelCopyWith<$Res> {
  factory $EvaluationModelCopyWith(
    EvaluationModel value,
    $Res Function(EvaluationModel) then,
  ) = _$EvaluationModelCopyWithImpl<$Res, EvaluationModel>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'manager_id') String managerId,
    @JsonKey(name: 'month_year') String monthYear,
    @JsonKey(name: 'skill_rating') String skillRating,
    @JsonKey(name: 'attitude_rating') String attitudeRating,
    @JsonKey(name: 'working_days') double workingDays,
    @JsonKey(name: 'leave_days') double leaveDays,
    @JsonKey(name: 'unpaid_leave_days') double unpaidLeaveDays,
    @JsonKey(name: 'unexcused_days') double unexcusedDays,
    String violations,
    @JsonKey(name: 'monthly_grade') String monthlyGrade,
    @JsonKey(name: 'proposed_action') String proposedAction,
    String status,
  });
}

/// @nodoc
class _$EvaluationModelCopyWithImpl<$Res, $Val extends EvaluationModel>
    implements $EvaluationModelCopyWith<$Res> {
  _$EvaluationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EvaluationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? managerId = null,
    Object? monthYear = null,
    Object? skillRating = null,
    Object? attitudeRating = null,
    Object? workingDays = null,
    Object? leaveDays = null,
    Object? unpaidLeaveDays = null,
    Object? unexcusedDays = null,
    Object? violations = null,
    Object? monthlyGrade = null,
    Object? proposedAction = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            managerId: null == managerId
                ? _value.managerId
                : managerId // ignore: cast_nullable_to_non_nullable
                      as String,
            monthYear: null == monthYear
                ? _value.monthYear
                : monthYear // ignore: cast_nullable_to_non_nullable
                      as String,
            skillRating: null == skillRating
                ? _value.skillRating
                : skillRating // ignore: cast_nullable_to_non_nullable
                      as String,
            attitudeRating: null == attitudeRating
                ? _value.attitudeRating
                : attitudeRating // ignore: cast_nullable_to_non_nullable
                      as String,
            workingDays: null == workingDays
                ? _value.workingDays
                : workingDays // ignore: cast_nullable_to_non_nullable
                      as double,
            leaveDays: null == leaveDays
                ? _value.leaveDays
                : leaveDays // ignore: cast_nullable_to_non_nullable
                      as double,
            unpaidLeaveDays: null == unpaidLeaveDays
                ? _value.unpaidLeaveDays
                : unpaidLeaveDays // ignore: cast_nullable_to_non_nullable
                      as double,
            unexcusedDays: null == unexcusedDays
                ? _value.unexcusedDays
                : unexcusedDays // ignore: cast_nullable_to_non_nullable
                      as double,
            violations: null == violations
                ? _value.violations
                : violations // ignore: cast_nullable_to_non_nullable
                      as String,
            monthlyGrade: null == monthlyGrade
                ? _value.monthlyGrade
                : monthlyGrade // ignore: cast_nullable_to_non_nullable
                      as String,
            proposedAction: null == proposedAction
                ? _value.proposedAction
                : proposedAction // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EvaluationModelImplCopyWith<$Res>
    implements $EvaluationModelCopyWith<$Res> {
  factory _$$EvaluationModelImplCopyWith(
    _$EvaluationModelImpl value,
    $Res Function(_$EvaluationModelImpl) then,
  ) = __$$EvaluationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'manager_id') String managerId,
    @JsonKey(name: 'month_year') String monthYear,
    @JsonKey(name: 'skill_rating') String skillRating,
    @JsonKey(name: 'attitude_rating') String attitudeRating,
    @JsonKey(name: 'working_days') double workingDays,
    @JsonKey(name: 'leave_days') double leaveDays,
    @JsonKey(name: 'unpaid_leave_days') double unpaidLeaveDays,
    @JsonKey(name: 'unexcused_days') double unexcusedDays,
    String violations,
    @JsonKey(name: 'monthly_grade') String monthlyGrade,
    @JsonKey(name: 'proposed_action') String proposedAction,
    String status,
  });
}

/// @nodoc
class __$$EvaluationModelImplCopyWithImpl<$Res>
    extends _$EvaluationModelCopyWithImpl<$Res, _$EvaluationModelImpl>
    implements _$$EvaluationModelImplCopyWith<$Res> {
  __$$EvaluationModelImplCopyWithImpl(
    _$EvaluationModelImpl _value,
    $Res Function(_$EvaluationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EvaluationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? managerId = null,
    Object? monthYear = null,
    Object? skillRating = null,
    Object? attitudeRating = null,
    Object? workingDays = null,
    Object? leaveDays = null,
    Object? unpaidLeaveDays = null,
    Object? unexcusedDays = null,
    Object? violations = null,
    Object? monthlyGrade = null,
    Object? proposedAction = null,
    Object? status = null,
  }) {
    return _then(
      _$EvaluationModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        managerId: null == managerId
            ? _value.managerId
            : managerId // ignore: cast_nullable_to_non_nullable
                  as String,
        monthYear: null == monthYear
            ? _value.monthYear
            : monthYear // ignore: cast_nullable_to_non_nullable
                  as String,
        skillRating: null == skillRating
            ? _value.skillRating
            : skillRating // ignore: cast_nullable_to_non_nullable
                  as String,
        attitudeRating: null == attitudeRating
            ? _value.attitudeRating
            : attitudeRating // ignore: cast_nullable_to_non_nullable
                  as String,
        workingDays: null == workingDays
            ? _value.workingDays
            : workingDays // ignore: cast_nullable_to_non_nullable
                  as double,
        leaveDays: null == leaveDays
            ? _value.leaveDays
            : leaveDays // ignore: cast_nullable_to_non_nullable
                  as double,
        unpaidLeaveDays: null == unpaidLeaveDays
            ? _value.unpaidLeaveDays
            : unpaidLeaveDays // ignore: cast_nullable_to_non_nullable
                  as double,
        unexcusedDays: null == unexcusedDays
            ? _value.unexcusedDays
            : unexcusedDays // ignore: cast_nullable_to_non_nullable
                  as double,
        violations: null == violations
            ? _value.violations
            : violations // ignore: cast_nullable_to_non_nullable
                  as String,
        monthlyGrade: null == monthlyGrade
            ? _value.monthlyGrade
            : monthlyGrade // ignore: cast_nullable_to_non_nullable
                  as String,
        proposedAction: null == proposedAction
            ? _value.proposedAction
            : proposedAction // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EvaluationModelImpl implements _EvaluationModel {
  const _$EvaluationModelImpl({
    this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'manager_id') required this.managerId,
    @JsonKey(name: 'month_year') required this.monthYear,
    @JsonKey(name: 'skill_rating') required this.skillRating,
    @JsonKey(name: 'attitude_rating') required this.attitudeRating,
    @JsonKey(name: 'working_days') this.workingDays = 0,
    @JsonKey(name: 'leave_days') this.leaveDays = 0,
    @JsonKey(name: 'unpaid_leave_days') this.unpaidLeaveDays = 0,
    @JsonKey(name: 'unexcused_days') this.unexcusedDays = 0,
    required this.violations,
    @JsonKey(name: 'monthly_grade') required this.monthlyGrade,
    @JsonKey(name: 'proposed_action') required this.proposedAction,
    this.status = 'draft',
  });

  factory _$EvaluationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EvaluationModelImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'manager_id')
  final String managerId;
  @override
  @JsonKey(name: 'month_year')
  final String monthYear;
  @override
  @JsonKey(name: 'skill_rating')
  final String skillRating;
  @override
  @JsonKey(name: 'attitude_rating')
  final String attitudeRating;
  @override
  @JsonKey(name: 'working_days')
  final double workingDays;
  @override
  @JsonKey(name: 'leave_days')
  final double leaveDays;
  @override
  @JsonKey(name: 'unpaid_leave_days')
  final double unpaidLeaveDays;
  @override
  @JsonKey(name: 'unexcused_days')
  final double unexcusedDays;
  @override
  final String violations;
  @override
  @JsonKey(name: 'monthly_grade')
  final String monthlyGrade;
  @override
  @JsonKey(name: 'proposed_action')
  final String proposedAction;
  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'EvaluationModel(id: $id, userId: $userId, managerId: $managerId, monthYear: $monthYear, skillRating: $skillRating, attitudeRating: $attitudeRating, workingDays: $workingDays, leaveDays: $leaveDays, unpaidLeaveDays: $unpaidLeaveDays, unexcusedDays: $unexcusedDays, violations: $violations, monthlyGrade: $monthlyGrade, proposedAction: $proposedAction, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EvaluationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.managerId, managerId) ||
                other.managerId == managerId) &&
            (identical(other.monthYear, monthYear) ||
                other.monthYear == monthYear) &&
            (identical(other.skillRating, skillRating) ||
                other.skillRating == skillRating) &&
            (identical(other.attitudeRating, attitudeRating) ||
                other.attitudeRating == attitudeRating) &&
            (identical(other.workingDays, workingDays) ||
                other.workingDays == workingDays) &&
            (identical(other.leaveDays, leaveDays) ||
                other.leaveDays == leaveDays) &&
            (identical(other.unpaidLeaveDays, unpaidLeaveDays) ||
                other.unpaidLeaveDays == unpaidLeaveDays) &&
            (identical(other.unexcusedDays, unexcusedDays) ||
                other.unexcusedDays == unexcusedDays) &&
            (identical(other.violations, violations) ||
                other.violations == violations) &&
            (identical(other.monthlyGrade, monthlyGrade) ||
                other.monthlyGrade == monthlyGrade) &&
            (identical(other.proposedAction, proposedAction) ||
                other.proposedAction == proposedAction) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    managerId,
    monthYear,
    skillRating,
    attitudeRating,
    workingDays,
    leaveDays,
    unpaidLeaveDays,
    unexcusedDays,
    violations,
    monthlyGrade,
    proposedAction,
    status,
  );

  /// Create a copy of EvaluationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EvaluationModelImplCopyWith<_$EvaluationModelImpl> get copyWith =>
      __$$EvaluationModelImplCopyWithImpl<_$EvaluationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EvaluationModelImplToJson(this);
  }
}

abstract class _EvaluationModel implements EvaluationModel {
  const factory _EvaluationModel({
    final String? id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'manager_id') required final String managerId,
    @JsonKey(name: 'month_year') required final String monthYear,
    @JsonKey(name: 'skill_rating') required final String skillRating,
    @JsonKey(name: 'attitude_rating') required final String attitudeRating,
    @JsonKey(name: 'working_days') final double workingDays,
    @JsonKey(name: 'leave_days') final double leaveDays,
    @JsonKey(name: 'unpaid_leave_days') final double unpaidLeaveDays,
    @JsonKey(name: 'unexcused_days') final double unexcusedDays,
    required final String violations,
    @JsonKey(name: 'monthly_grade') required final String monthlyGrade,
    @JsonKey(name: 'proposed_action') required final String proposedAction,
    final String status,
  }) = _$EvaluationModelImpl;

  factory _EvaluationModel.fromJson(Map<String, dynamic> json) =
      _$EvaluationModelImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'manager_id')
  String get managerId;
  @override
  @JsonKey(name: 'month_year')
  String get monthYear;
  @override
  @JsonKey(name: 'skill_rating')
  String get skillRating;
  @override
  @JsonKey(name: 'attitude_rating')
  String get attitudeRating;
  @override
  @JsonKey(name: 'working_days')
  double get workingDays;
  @override
  @JsonKey(name: 'leave_days')
  double get leaveDays;
  @override
  @JsonKey(name: 'unpaid_leave_days')
  double get unpaidLeaveDays;
  @override
  @JsonKey(name: 'unexcused_days')
  double get unexcusedDays;
  @override
  String get violations;
  @override
  @JsonKey(name: 'monthly_grade')
  String get monthlyGrade;
  @override
  @JsonKey(name: 'proposed_action')
  String get proposedAction;
  @override
  String get status;

  /// Create a copy of EvaluationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EvaluationModelImplCopyWith<_$EvaluationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
