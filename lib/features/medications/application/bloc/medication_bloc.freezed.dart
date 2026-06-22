// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MedicationState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Medication> medications) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Medication> medications)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Medication> medications)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MedicationInitial value) initial,
    required TResult Function(MedicationLoading value) loading,
    required TResult Function(MedicationLoaded value) loaded,
    required TResult Function(MedicationError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MedicationInitial value)? initial,
    TResult? Function(MedicationLoading value)? loading,
    TResult? Function(MedicationLoaded value)? loaded,
    TResult? Function(MedicationError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MedicationInitial value)? initial,
    TResult Function(MedicationLoading value)? loading,
    TResult Function(MedicationLoaded value)? loaded,
    TResult Function(MedicationError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationStateCopyWith<$Res> {
  factory $MedicationStateCopyWith(
          MedicationState value, $Res Function(MedicationState) then) =
      _$MedicationStateCopyWithImpl<$Res, MedicationState>;
}

/// @nodoc
class _$MedicationStateCopyWithImpl<$Res, $Val extends MedicationState>
    implements $MedicationStateCopyWith<$Res> {
  _$MedicationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MedicationInitialImplCopyWith<$Res> {
  factory _$$MedicationInitialImplCopyWith(_$MedicationInitialImpl value,
          $Res Function(_$MedicationInitialImpl) then) =
      __$$MedicationInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MedicationInitialImplCopyWithImpl<$Res>
    extends _$MedicationStateCopyWithImpl<$Res, _$MedicationInitialImpl>
    implements _$$MedicationInitialImplCopyWith<$Res> {
  __$$MedicationInitialImplCopyWithImpl(_$MedicationInitialImpl _value,
      $Res Function(_$MedicationInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MedicationInitialImpl implements MedicationInitial {
  const _$MedicationInitialImpl();

  @override
  String toString() {
    return 'MedicationState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MedicationInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Medication> medications) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Medication> medications)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Medication> medications)? loaded,
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
    required TResult Function(MedicationInitial value) initial,
    required TResult Function(MedicationLoading value) loading,
    required TResult Function(MedicationLoaded value) loaded,
    required TResult Function(MedicationError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MedicationInitial value)? initial,
    TResult? Function(MedicationLoading value)? loading,
    TResult? Function(MedicationLoaded value)? loaded,
    TResult? Function(MedicationError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MedicationInitial value)? initial,
    TResult Function(MedicationLoading value)? loading,
    TResult Function(MedicationLoaded value)? loaded,
    TResult Function(MedicationError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class MedicationInitial implements MedicationState {
  const factory MedicationInitial() = _$MedicationInitialImpl;
}

/// @nodoc
abstract class _$$MedicationLoadingImplCopyWith<$Res> {
  factory _$$MedicationLoadingImplCopyWith(_$MedicationLoadingImpl value,
          $Res Function(_$MedicationLoadingImpl) then) =
      __$$MedicationLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MedicationLoadingImplCopyWithImpl<$Res>
    extends _$MedicationStateCopyWithImpl<$Res, _$MedicationLoadingImpl>
    implements _$$MedicationLoadingImplCopyWith<$Res> {
  __$$MedicationLoadingImplCopyWithImpl(_$MedicationLoadingImpl _value,
      $Res Function(_$MedicationLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MedicationLoadingImpl implements MedicationLoading {
  const _$MedicationLoadingImpl();

  @override
  String toString() {
    return 'MedicationState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MedicationLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Medication> medications) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Medication> medications)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Medication> medications)? loaded,
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
    required TResult Function(MedicationInitial value) initial,
    required TResult Function(MedicationLoading value) loading,
    required TResult Function(MedicationLoaded value) loaded,
    required TResult Function(MedicationError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MedicationInitial value)? initial,
    TResult? Function(MedicationLoading value)? loading,
    TResult? Function(MedicationLoaded value)? loaded,
    TResult? Function(MedicationError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MedicationInitial value)? initial,
    TResult Function(MedicationLoading value)? loading,
    TResult Function(MedicationLoaded value)? loaded,
    TResult Function(MedicationError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class MedicationLoading implements MedicationState {
  const factory MedicationLoading() = _$MedicationLoadingImpl;
}

/// @nodoc
abstract class _$$MedicationLoadedImplCopyWith<$Res> {
  factory _$$MedicationLoadedImplCopyWith(_$MedicationLoadedImpl value,
          $Res Function(_$MedicationLoadedImpl) then) =
      __$$MedicationLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Medication> medications});
}

/// @nodoc
class __$$MedicationLoadedImplCopyWithImpl<$Res>
    extends _$MedicationStateCopyWithImpl<$Res, _$MedicationLoadedImpl>
    implements _$$MedicationLoadedImplCopyWith<$Res> {
  __$$MedicationLoadedImplCopyWithImpl(_$MedicationLoadedImpl _value,
      $Res Function(_$MedicationLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? medications = null,
  }) {
    return _then(_$MedicationLoadedImpl(
      null == medications
          ? _value._medications
          : medications // ignore: cast_nullable_to_non_nullable
              as List<Medication>,
    ));
  }
}

/// @nodoc

class _$MedicationLoadedImpl implements MedicationLoaded {
  const _$MedicationLoadedImpl(final List<Medication> medications)
      : _medications = medications;

  final List<Medication> _medications;
  @override
  List<Medication> get medications {
    if (_medications is EqualUnmodifiableListView) return _medications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medications);
  }

  @override
  String toString() {
    return 'MedicationState.loaded(medications: $medications)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationLoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._medications, _medications));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_medications));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationLoadedImplCopyWith<_$MedicationLoadedImpl> get copyWith =>
      __$$MedicationLoadedImplCopyWithImpl<_$MedicationLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Medication> medications) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(medications);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Medication> medications)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(medications);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Medication> medications)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(medications);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MedicationInitial value) initial,
    required TResult Function(MedicationLoading value) loading,
    required TResult Function(MedicationLoaded value) loaded,
    required TResult Function(MedicationError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MedicationInitial value)? initial,
    TResult? Function(MedicationLoading value)? loading,
    TResult? Function(MedicationLoaded value)? loaded,
    TResult? Function(MedicationError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MedicationInitial value)? initial,
    TResult Function(MedicationLoading value)? loading,
    TResult Function(MedicationLoaded value)? loaded,
    TResult Function(MedicationError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class MedicationLoaded implements MedicationState {
  const factory MedicationLoaded(final List<Medication> medications) =
      _$MedicationLoadedImpl;

  List<Medication> get medications;
  @JsonKey(ignore: true)
  _$$MedicationLoadedImplCopyWith<_$MedicationLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MedicationErrorImplCopyWith<$Res> {
  factory _$$MedicationErrorImplCopyWith(_$MedicationErrorImpl value,
          $Res Function(_$MedicationErrorImpl) then) =
      __$$MedicationErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$MedicationErrorImplCopyWithImpl<$Res>
    extends _$MedicationStateCopyWithImpl<$Res, _$MedicationErrorImpl>
    implements _$$MedicationErrorImplCopyWith<$Res> {
  __$$MedicationErrorImplCopyWithImpl(
      _$MedicationErrorImpl _value, $Res Function(_$MedicationErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$MedicationErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MedicationErrorImpl implements MedicationError {
  const _$MedicationErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'MedicationState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationErrorImplCopyWith<_$MedicationErrorImpl> get copyWith =>
      __$$MedicationErrorImplCopyWithImpl<_$MedicationErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Medication> medications) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Medication> medications)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Medication> medications)? loaded,
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
    required TResult Function(MedicationInitial value) initial,
    required TResult Function(MedicationLoading value) loading,
    required TResult Function(MedicationLoaded value) loaded,
    required TResult Function(MedicationError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MedicationInitial value)? initial,
    TResult? Function(MedicationLoading value)? loading,
    TResult? Function(MedicationLoaded value)? loaded,
    TResult? Function(MedicationError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MedicationInitial value)? initial,
    TResult Function(MedicationLoading value)? loading,
    TResult Function(MedicationLoaded value)? loaded,
    TResult Function(MedicationError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class MedicationError implements MedicationState {
  const factory MedicationError(final String message) = _$MedicationErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$MedicationErrorImplCopyWith<_$MedicationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
