// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timesheet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TimesheetModel _$TimesheetModelFromJson(Map<String, dynamic> json) {
  return _TimesheetModel.fromJson(json);
}

/// @nodoc
mixin _$TimesheetModel {
  String? get id =>
      throw _privateConstructorUsedError; // Sẽ có khi lấy từ DB về, null khi tạo mới
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'date')
  DateTime get date => throw _privateConstructorUsedError; // Tự động parse từ kiểu date của SQL
  @JsonKey(name: 'shift_type')
  String get shiftType => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'overtime_start')
  String? get overtimeStart => throw _privateConstructorUsedError; // Lưu dạng giờ phút '17:00'
  @JsonKey(name: 'overtime_end')
  String? get overtimeEnd => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this TimesheetModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimesheetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimesheetModelCopyWith<TimesheetModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimesheetModelCopyWith<$Res> {
  factory $TimesheetModelCopyWith(
    TimesheetModel value,
    $Res Function(TimesheetModel) then,
  ) = _$TimesheetModelCopyWithImpl<$Res, TimesheetModel>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'date') DateTime date,
    @JsonKey(name: 'shift_type') String shiftType,
    String status,
    @JsonKey(name: 'overtime_start') String? overtimeStart,
    @JsonKey(name: 'overtime_end') String? overtimeEnd,
    String? notes,
  });
}

/// @nodoc
class _$TimesheetModelCopyWithImpl<$Res, $Val extends TimesheetModel>
    implements $TimesheetModelCopyWith<$Res> {
  _$TimesheetModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimesheetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? date = null,
    Object? shiftType = null,
    Object? status = null,
    Object? overtimeStart = freezed,
    Object? overtimeEnd = freezed,
    Object? notes = freezed,
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
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            shiftType: null == shiftType
                ? _value.shiftType
                : shiftType // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            overtimeStart: freezed == overtimeStart
                ? _value.overtimeStart
                : overtimeStart // ignore: cast_nullable_to_non_nullable
                      as String?,
            overtimeEnd: freezed == overtimeEnd
                ? _value.overtimeEnd
                : overtimeEnd // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimesheetModelImplCopyWith<$Res>
    implements $TimesheetModelCopyWith<$Res> {
  factory _$$TimesheetModelImplCopyWith(
    _$TimesheetModelImpl value,
    $Res Function(_$TimesheetModelImpl) then,
  ) = __$$TimesheetModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'date') DateTime date,
    @JsonKey(name: 'shift_type') String shiftType,
    String status,
    @JsonKey(name: 'overtime_start') String? overtimeStart,
    @JsonKey(name: 'overtime_end') String? overtimeEnd,
    String? notes,
  });
}

/// @nodoc
class __$$TimesheetModelImplCopyWithImpl<$Res>
    extends _$TimesheetModelCopyWithImpl<$Res, _$TimesheetModelImpl>
    implements _$$TimesheetModelImplCopyWith<$Res> {
  __$$TimesheetModelImplCopyWithImpl(
    _$TimesheetModelImpl _value,
    $Res Function(_$TimesheetModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimesheetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? date = null,
    Object? shiftType = null,
    Object? status = null,
    Object? overtimeStart = freezed,
    Object? overtimeEnd = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$TimesheetModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        shiftType: null == shiftType
            ? _value.shiftType
            : shiftType // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        overtimeStart: freezed == overtimeStart
            ? _value.overtimeStart
            : overtimeStart // ignore: cast_nullable_to_non_nullable
                  as String?,
        overtimeEnd: freezed == overtimeEnd
            ? _value.overtimeEnd
            : overtimeEnd // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimesheetModelImpl implements _TimesheetModel {
  const _$TimesheetModelImpl({
    this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'date') required this.date,
    @JsonKey(name: 'shift_type') this.shiftType = 'Ca Ngày',
    this.status = 'Có mặt',
    @JsonKey(name: 'overtime_start') this.overtimeStart,
    @JsonKey(name: 'overtime_end') this.overtimeEnd,
    this.notes,
  });

  factory _$TimesheetModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimesheetModelImplFromJson(json);

  @override
  final String? id;
  // Sẽ có khi lấy từ DB về, null khi tạo mới
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'date')
  final DateTime date;
  // Tự động parse từ kiểu date của SQL
  @override
  @JsonKey(name: 'shift_type')
  final String shiftType;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'overtime_start')
  final String? overtimeStart;
  // Lưu dạng giờ phút '17:00'
  @override
  @JsonKey(name: 'overtime_end')
  final String? overtimeEnd;
  @override
  final String? notes;

  @override
  String toString() {
    return 'TimesheetModel(id: $id, userId: $userId, date: $date, shiftType: $shiftType, status: $status, overtimeStart: $overtimeStart, overtimeEnd: $overtimeEnd, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimesheetModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.shiftType, shiftType) ||
                other.shiftType == shiftType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.overtimeStart, overtimeStart) ||
                other.overtimeStart == overtimeStart) &&
            (identical(other.overtimeEnd, overtimeEnd) ||
                other.overtimeEnd == overtimeEnd) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    date,
    shiftType,
    status,
    overtimeStart,
    overtimeEnd,
    notes,
  );

  /// Create a copy of TimesheetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimesheetModelImplCopyWith<_$TimesheetModelImpl> get copyWith =>
      __$$TimesheetModelImplCopyWithImpl<_$TimesheetModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TimesheetModelImplToJson(this);
  }
}

abstract class _TimesheetModel implements TimesheetModel {
  const factory _TimesheetModel({
    final String? id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'date') required final DateTime date,
    @JsonKey(name: 'shift_type') final String shiftType,
    final String status,
    @JsonKey(name: 'overtime_start') final String? overtimeStart,
    @JsonKey(name: 'overtime_end') final String? overtimeEnd,
    final String? notes,
  }) = _$TimesheetModelImpl;

  factory _TimesheetModel.fromJson(Map<String, dynamic> json) =
      _$TimesheetModelImpl.fromJson;

  @override
  String? get id; // Sẽ có khi lấy từ DB về, null khi tạo mới
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'date')
  DateTime get date; // Tự động parse từ kiểu date của SQL
  @override
  @JsonKey(name: 'shift_type')
  String get shiftType;
  @override
  String get status;
  @override
  @JsonKey(name: 'overtime_start')
  String? get overtimeStart; // Lưu dạng giờ phút '17:00'
  @override
  @JsonKey(name: 'overtime_end')
  String? get overtimeEnd;
  @override
  String? get notes;

  /// Create a copy of TimesheetModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimesheetModelImplCopyWith<_$TimesheetModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
