// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppointmentState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Appointment> appointments) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Appointment> appointments)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Appointment> appointments)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AppointmentInitial value) initial,
    required TResult Function(AppointmentLoading value) loading,
    required TResult Function(AppointmentLoaded value) loaded,
    required TResult Function(AppointmentError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AppointmentInitial value)? initial,
    TResult? Function(AppointmentLoading value)? loading,
    TResult? Function(AppointmentLoaded value)? loaded,
    TResult? Function(AppointmentError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AppointmentInitial value)? initial,
    TResult Function(AppointmentLoading value)? loading,
    TResult Function(AppointmentLoaded value)? loaded,
    TResult Function(AppointmentError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentStateCopyWith<$Res> {
  factory $AppointmentStateCopyWith(
          AppointmentState value, $Res Function(AppointmentState) then) =
      _$AppointmentStateCopyWithImpl<$Res, AppointmentState>;
}

/// @nodoc
class _$AppointmentStateCopyWithImpl<$Res, $Val extends AppointmentState>
    implements $AppointmentStateCopyWith<$Res> {
  _$AppointmentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AppointmentInitialImplCopyWith<$Res> {
  factory _$$AppointmentInitialImplCopyWith(_$AppointmentInitialImpl value,
          $Res Function(_$AppointmentInitialImpl) then) =
      __$$AppointmentInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AppointmentInitialImplCopyWithImpl<$Res>
    extends _$AppointmentStateCopyWithImpl<$Res, _$AppointmentInitialImpl>
    implements _$$AppointmentInitialImplCopyWith<$Res> {
  __$$AppointmentInitialImplCopyWithImpl(_$AppointmentInitialImpl _value,
      $Res Function(_$AppointmentInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AppointmentInitialImpl implements AppointmentInitial {
  const _$AppointmentInitialImpl();

  @override
  String toString() {
    return 'AppointmentState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AppointmentInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Appointment> appointments) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Appointment> appointments)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Appointment> appointments)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AppointmentInitial value) initial,
    required TResult Function(AppointmentLoading value) loading,
    required TResult Function(AppointmentLoaded value) loaded,
    required TResult Function(AppointmentError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AppointmentInitial value)? initial,
    TResult? Function(AppointmentLoading value)? loading,
    TResult? Function(AppointmentLoaded value)? loaded,
    TResult? Function(AppointmentError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AppointmentInitial value)? initial,
    TResult Function(AppointmentLoading value)? loading,
    TResult Function(AppointmentLoaded value)? loaded,
    TResult Function(AppointmentError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class AppointmentInitial implements AppointmentState {
  const factory AppointmentInitial() = _$AppointmentInitialImpl;
}

/// @nodoc
abstract class _$$AppointmentLoadingImplCopyWith<$Res> {
  factory _$$AppointmentLoadingImplCopyWith(_$AppointmentLoadingImpl value,
          $Res Function(_$AppointmentLoadingImpl) then) =
      __$$AppointmentLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AppointmentLoadingImplCopyWithImpl<$Res>
    extends _$AppointmentStateCopyWithImpl<$Res, _$AppointmentLoadingImpl>
    implements _$$AppointmentLoadingImplCopyWith<$Res> {
  __$$AppointmentLoadingImplCopyWithImpl(_$AppointmentLoadingImpl _value,
      $Res Function(_$AppointmentLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AppointmentLoadingImpl implements AppointmentLoading {
  const _$AppointmentLoadingImpl();

  @override
  String toString() {
    return 'AppointmentState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AppointmentLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Appointment> appointments) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Appointment> appointments)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Appointment> appointments)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AppointmentInitial value) initial,
    required TResult Function(AppointmentLoading value) loading,
    required TResult Function(AppointmentLoaded value) loaded,
    required TResult Function(AppointmentError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AppointmentInitial value)? initial,
    TResult? Function(AppointmentLoading value)? loading,
    TResult? Function(AppointmentLoaded value)? loaded,
    TResult? Function(AppointmentError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AppointmentInitial value)? initial,
    TResult Function(AppointmentLoading value)? loading,
    TResult Function(AppointmentLoaded value)? loaded,
    TResult Function(AppointmentError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class AppointmentLoading implements AppointmentState {
  const factory AppointmentLoading() = _$AppointmentLoadingImpl;
}

/// @nodoc
abstract class _$$AppointmentLoadedImplCopyWith<$Res> {
  factory _$$AppointmentLoadedImplCopyWith(_$AppointmentLoadedImpl value,
          $Res Function(_$AppointmentLoadedImpl) then) =
      __$$AppointmentLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Appointment> appointments});
}

/// @nodoc
class __$$AppointmentLoadedImplCopyWithImpl<$Res>
    extends _$AppointmentStateCopyWithImpl<$Res, _$AppointmentLoadedImpl>
    implements _$$AppointmentLoadedImplCopyWith<$Res> {
  __$$AppointmentLoadedImplCopyWithImpl(_$AppointmentLoadedImpl _value,
      $Res Function(_$AppointmentLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appointments = null,
  }) {
    return _then(_$AppointmentLoadedImpl(
      null == appointments
          ? _value._appointments
          : appointments // ignore: cast_nullable_to_non_nullable
              as List<Appointment>,
    ));
  }
}

/// @nodoc

class _$AppointmentLoadedImpl implements AppointmentLoaded {
  const _$AppointmentLoadedImpl(final List<Appointment> appointments)
      : _appointments = appointments;

  final List<Appointment> _appointments;
  @override
  List<Appointment> get appointments {
    if (_appointments is EqualUnmodifiableListView) return _appointments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_appointments);
  }

  @override
  String toString() {
    return 'AppointmentState.loaded(appointments: $appointments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentLoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._appointments, _appointments));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_appointments));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentLoadedImplCopyWith<_$AppointmentLoadedImpl> get copyWith =>
      __$$AppointmentLoadedImplCopyWithImpl<_$AppointmentLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Appointment> appointments) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(appointments);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Appointment> appointments)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(appointments);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Appointment> appointments)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(appointments);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AppointmentInitial value) initial,
    required TResult Function(AppointmentLoading value) loading,
    required TResult Function(AppointmentLoaded value) loaded,
    required TResult Function(AppointmentError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AppointmentInitial value)? initial,
    TResult? Function(AppointmentLoading value)? loading,
    TResult? Function(AppointmentLoaded value)? loaded,
    TResult? Function(AppointmentError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AppointmentInitial value)? initial,
    TResult Function(AppointmentLoading value)? loading,
    TResult Function(AppointmentLoaded value)? loaded,
    TResult Function(AppointmentError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class AppointmentLoaded implements AppointmentState {
  const factory AppointmentLoaded(final List<Appointment> appointments) =
      _$AppointmentLoadedImpl;

  List<Appointment> get appointments;
  @JsonKey(ignore: true)
  _$$AppointmentLoadedImplCopyWith<_$AppointmentLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AppointmentErrorImplCopyWith<$Res> {
  factory _$$AppointmentErrorImplCopyWith(_$AppointmentErrorImpl value,
          $Res Function(_$AppointmentErrorImpl) then) =
      __$$AppointmentErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$AppointmentErrorImplCopyWithImpl<$Res>
    extends _$AppointmentStateCopyWithImpl<$Res, _$AppointmentErrorImpl>
    implements _$$AppointmentErrorImplCopyWith<$Res> {
  __$$AppointmentErrorImplCopyWithImpl(_$AppointmentErrorImpl _value,
      $Res Function(_$AppointmentErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$AppointmentErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AppointmentErrorImpl implements AppointmentError {
  const _$AppointmentErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AppointmentState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentErrorImplCopyWith<_$AppointmentErrorImpl> get copyWith =>
      __$$AppointmentErrorImplCopyWithImpl<_$AppointmentErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Appointment> appointments) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Appointment> appointments)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Appointment> appointments)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AppointmentInitial value) initial,
    required TResult Function(AppointmentLoading value) loading,
    required TResult Function(AppointmentLoaded value) loaded,
    required TResult Function(AppointmentError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AppointmentInitial value)? initial,
    TResult? Function(AppointmentLoading value)? loading,
    TResult? Function(AppointmentLoaded value)? loaded,
    TResult? Function(AppointmentError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AppointmentInitial value)? initial,
    TResult Function(AppointmentLoading value)? loading,
    TResult Function(AppointmentLoaded value)? loaded,
    TResult Function(AppointmentError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class AppointmentError implements AppointmentState {
  const factory AppointmentError(final String message) = _$AppointmentErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$AppointmentErrorImplCopyWith<_$AppointmentErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
