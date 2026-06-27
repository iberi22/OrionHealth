// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vital_sign_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VitalSignState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VitalSign> vitals) loaded,
    required TResult Function(Map<VitalSignType, VitalSign?> latest)
        latestLoaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VitalSign> vitals)? loaded,
    TResult? Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VitalSign> vitals)? loaded,
    TResult Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VitalSignInitial value) initial,
    required TResult Function(VitalSignLoading value) loading,
    required TResult Function(VitalSignLoaded value) loaded,
    required TResult Function(VitalSignLatestLoaded value) latestLoaded,
    required TResult Function(VitalSignError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VitalSignInitial value)? initial,
    TResult? Function(VitalSignLoading value)? loading,
    TResult? Function(VitalSignLoaded value)? loaded,
    TResult? Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult? Function(VitalSignError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VitalSignInitial value)? initial,
    TResult Function(VitalSignLoading value)? loading,
    TResult Function(VitalSignLoaded value)? loaded,
    TResult Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult Function(VitalSignError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VitalSignStateCopyWith<$Res> {
  factory $VitalSignStateCopyWith(
          VitalSignState value, $Res Function(VitalSignState) then) =
      _$VitalSignStateCopyWithImpl<$Res, VitalSignState>;
}

/// @nodoc
class _$VitalSignStateCopyWithImpl<$Res, $Val extends VitalSignState>
    implements $VitalSignStateCopyWith<$Res> {
  _$VitalSignStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$VitalSignInitialImplCopyWith<$Res> {
  factory _$$VitalSignInitialImplCopyWith(_$VitalSignInitialImpl value,
          $Res Function(_$VitalSignInitialImpl) then) =
      __$$VitalSignInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$VitalSignInitialImplCopyWithImpl<$Res>
    extends _$VitalSignStateCopyWithImpl<$Res, _$VitalSignInitialImpl>
    implements _$$VitalSignInitialImplCopyWith<$Res> {
  __$$VitalSignInitialImplCopyWithImpl(_$VitalSignInitialImpl _value,
      $Res Function(_$VitalSignInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$VitalSignInitialImpl implements VitalSignInitial {
  const _$VitalSignInitialImpl();

  @override
  String toString() {
    return 'VitalSignState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$VitalSignInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VitalSign> vitals) loaded,
    required TResult Function(Map<VitalSignType, VitalSign?> latest)
        latestLoaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VitalSign> vitals)? loaded,
    TResult? Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VitalSign> vitals)? loaded,
    TResult Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
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
    required TResult Function(VitalSignInitial value) initial,
    required TResult Function(VitalSignLoading value) loading,
    required TResult Function(VitalSignLoaded value) loaded,
    required TResult Function(VitalSignLatestLoaded value) latestLoaded,
    required TResult Function(VitalSignError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VitalSignInitial value)? initial,
    TResult? Function(VitalSignLoading value)? loading,
    TResult? Function(VitalSignLoaded value)? loaded,
    TResult? Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult? Function(VitalSignError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VitalSignInitial value)? initial,
    TResult Function(VitalSignLoading value)? loading,
    TResult Function(VitalSignLoaded value)? loaded,
    TResult Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult Function(VitalSignError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class VitalSignInitial implements VitalSignState {
  const factory VitalSignInitial() = _$VitalSignInitialImpl;
}

/// @nodoc
abstract class _$$VitalSignLoadingImplCopyWith<$Res> {
  factory _$$VitalSignLoadingImplCopyWith(_$VitalSignLoadingImpl value,
          $Res Function(_$VitalSignLoadingImpl) then) =
      __$$VitalSignLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$VitalSignLoadingImplCopyWithImpl<$Res>
    extends _$VitalSignStateCopyWithImpl<$Res, _$VitalSignLoadingImpl>
    implements _$$VitalSignLoadingImplCopyWith<$Res> {
  __$$VitalSignLoadingImplCopyWithImpl(_$VitalSignLoadingImpl _value,
      $Res Function(_$VitalSignLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$VitalSignLoadingImpl implements VitalSignLoading {
  const _$VitalSignLoadingImpl();

  @override
  String toString() {
    return 'VitalSignState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$VitalSignLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VitalSign> vitals) loaded,
    required TResult Function(Map<VitalSignType, VitalSign?> latest)
        latestLoaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VitalSign> vitals)? loaded,
    TResult? Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VitalSign> vitals)? loaded,
    TResult Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
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
    required TResult Function(VitalSignInitial value) initial,
    required TResult Function(VitalSignLoading value) loading,
    required TResult Function(VitalSignLoaded value) loaded,
    required TResult Function(VitalSignLatestLoaded value) latestLoaded,
    required TResult Function(VitalSignError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VitalSignInitial value)? initial,
    TResult? Function(VitalSignLoading value)? loading,
    TResult? Function(VitalSignLoaded value)? loaded,
    TResult? Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult? Function(VitalSignError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VitalSignInitial value)? initial,
    TResult Function(VitalSignLoading value)? loading,
    TResult Function(VitalSignLoaded value)? loaded,
    TResult Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult Function(VitalSignError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class VitalSignLoading implements VitalSignState {
  const factory VitalSignLoading() = _$VitalSignLoadingImpl;
}

/// @nodoc
abstract class _$$VitalSignLoadedImplCopyWith<$Res> {
  factory _$$VitalSignLoadedImplCopyWith(_$VitalSignLoadedImpl value,
          $Res Function(_$VitalSignLoadedImpl) then) =
      __$$VitalSignLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<VitalSign> vitals});
}

/// @nodoc
class __$$VitalSignLoadedImplCopyWithImpl<$Res>
    extends _$VitalSignStateCopyWithImpl<$Res, _$VitalSignLoadedImpl>
    implements _$$VitalSignLoadedImplCopyWith<$Res> {
  __$$VitalSignLoadedImplCopyWithImpl(
      _$VitalSignLoadedImpl _value, $Res Function(_$VitalSignLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vitals = null,
  }) {
    return _then(_$VitalSignLoadedImpl(
      null == vitals
          ? _value._vitals
          : vitals // ignore: cast_nullable_to_non_nullable
              as List<VitalSign>,
    ));
  }
}

/// @nodoc

class _$VitalSignLoadedImpl implements VitalSignLoaded {
  const _$VitalSignLoadedImpl(final List<VitalSign> vitals) : _vitals = vitals;

  final List<VitalSign> _vitals;
  @override
  List<VitalSign> get vitals {
    if (_vitals is EqualUnmodifiableListView) return _vitals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_vitals);
  }

  @override
  String toString() {
    return 'VitalSignState.loaded(vitals: $vitals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VitalSignLoadedImpl &&
            const DeepCollectionEquality().equals(other._vitals, _vitals));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_vitals));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VitalSignLoadedImplCopyWith<_$VitalSignLoadedImpl> get copyWith =>
      __$$VitalSignLoadedImplCopyWithImpl<_$VitalSignLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VitalSign> vitals) loaded,
    required TResult Function(Map<VitalSignType, VitalSign?> latest)
        latestLoaded,
    required TResult Function(String message) error,
  }) {
    return loaded(vitals);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VitalSign> vitals)? loaded,
    TResult? Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(vitals);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VitalSign> vitals)? loaded,
    TResult Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(vitals);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VitalSignInitial value) initial,
    required TResult Function(VitalSignLoading value) loading,
    required TResult Function(VitalSignLoaded value) loaded,
    required TResult Function(VitalSignLatestLoaded value) latestLoaded,
    required TResult Function(VitalSignError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VitalSignInitial value)? initial,
    TResult? Function(VitalSignLoading value)? loading,
    TResult? Function(VitalSignLoaded value)? loaded,
    TResult? Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult? Function(VitalSignError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VitalSignInitial value)? initial,
    TResult Function(VitalSignLoading value)? loading,
    TResult Function(VitalSignLoaded value)? loaded,
    TResult Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult Function(VitalSignError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class VitalSignLoaded implements VitalSignState {
  const factory VitalSignLoaded(final List<VitalSign> vitals) =
      _$VitalSignLoadedImpl;

  List<VitalSign> get vitals;
  @JsonKey(ignore: true)
  _$$VitalSignLoadedImplCopyWith<_$VitalSignLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VitalSignLatestLoadedImplCopyWith<$Res> {
  factory _$$VitalSignLatestLoadedImplCopyWith(
          _$VitalSignLatestLoadedImpl value,
          $Res Function(_$VitalSignLatestLoadedImpl) then) =
      __$$VitalSignLatestLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Map<VitalSignType, VitalSign?> latest});
}

/// @nodoc
class __$$VitalSignLatestLoadedImplCopyWithImpl<$Res>
    extends _$VitalSignStateCopyWithImpl<$Res, _$VitalSignLatestLoadedImpl>
    implements _$$VitalSignLatestLoadedImplCopyWith<$Res> {
  __$$VitalSignLatestLoadedImplCopyWithImpl(_$VitalSignLatestLoadedImpl _value,
      $Res Function(_$VitalSignLatestLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latest = null,
  }) {
    return _then(_$VitalSignLatestLoadedImpl(
      null == latest
          ? _value._latest
          : latest // ignore: cast_nullable_to_non_nullable
              as Map<VitalSignType, VitalSign?>,
    ));
  }
}

/// @nodoc

class _$VitalSignLatestLoadedImpl implements VitalSignLatestLoaded {
  const _$VitalSignLatestLoadedImpl(final Map<VitalSignType, VitalSign?> latest)
      : _latest = latest;

  final Map<VitalSignType, VitalSign?> _latest;
  @override
  Map<VitalSignType, VitalSign?> get latest {
    if (_latest is EqualUnmodifiableMapView) return _latest;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_latest);
  }

  @override
  String toString() {
    return 'VitalSignState.latestLoaded(latest: $latest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VitalSignLatestLoadedImpl &&
            const DeepCollectionEquality().equals(other._latest, _latest));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_latest));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VitalSignLatestLoadedImplCopyWith<_$VitalSignLatestLoadedImpl>
      get copyWith => __$$VitalSignLatestLoadedImplCopyWithImpl<
          _$VitalSignLatestLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VitalSign> vitals) loaded,
    required TResult Function(Map<VitalSignType, VitalSign?> latest)
        latestLoaded,
    required TResult Function(String message) error,
  }) {
    return latestLoaded(latest);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VitalSign> vitals)? loaded,
    TResult? Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
    TResult? Function(String message)? error,
  }) {
    return latestLoaded?.call(latest);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VitalSign> vitals)? loaded,
    TResult Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (latestLoaded != null) {
      return latestLoaded(latest);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VitalSignInitial value) initial,
    required TResult Function(VitalSignLoading value) loading,
    required TResult Function(VitalSignLoaded value) loaded,
    required TResult Function(VitalSignLatestLoaded value) latestLoaded,
    required TResult Function(VitalSignError value) error,
  }) {
    return latestLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VitalSignInitial value)? initial,
    TResult? Function(VitalSignLoading value)? loading,
    TResult? Function(VitalSignLoaded value)? loaded,
    TResult? Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult? Function(VitalSignError value)? error,
  }) {
    return latestLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VitalSignInitial value)? initial,
    TResult Function(VitalSignLoading value)? loading,
    TResult Function(VitalSignLoaded value)? loaded,
    TResult Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult Function(VitalSignError value)? error,
    required TResult orElse(),
  }) {
    if (latestLoaded != null) {
      return latestLoaded(this);
    }
    return orElse();
  }
}

abstract class VitalSignLatestLoaded implements VitalSignState {
  const factory VitalSignLatestLoaded(
          final Map<VitalSignType, VitalSign?> latest) =
      _$VitalSignLatestLoadedImpl;

  Map<VitalSignType, VitalSign?> get latest;
  @JsonKey(ignore: true)
  _$$VitalSignLatestLoadedImplCopyWith<_$VitalSignLatestLoadedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VitalSignErrorImplCopyWith<$Res> {
  factory _$$VitalSignErrorImplCopyWith(_$VitalSignErrorImpl value,
          $Res Function(_$VitalSignErrorImpl) then) =
      __$$VitalSignErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$VitalSignErrorImplCopyWithImpl<$Res>
    extends _$VitalSignStateCopyWithImpl<$Res, _$VitalSignErrorImpl>
    implements _$$VitalSignErrorImplCopyWith<$Res> {
  __$$VitalSignErrorImplCopyWithImpl(
      _$VitalSignErrorImpl _value, $Res Function(_$VitalSignErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$VitalSignErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$VitalSignErrorImpl implements VitalSignError {
  const _$VitalSignErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'VitalSignState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VitalSignErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VitalSignErrorImplCopyWith<_$VitalSignErrorImpl> get copyWith =>
      __$$VitalSignErrorImplCopyWithImpl<_$VitalSignErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<VitalSign> vitals) loaded,
    required TResult Function(Map<VitalSignType, VitalSign?> latest)
        latestLoaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<VitalSign> vitals)? loaded,
    TResult? Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<VitalSign> vitals)? loaded,
    TResult Function(Map<VitalSignType, VitalSign?> latest)? latestLoaded,
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
    required TResult Function(VitalSignInitial value) initial,
    required TResult Function(VitalSignLoading value) loading,
    required TResult Function(VitalSignLoaded value) loaded,
    required TResult Function(VitalSignLatestLoaded value) latestLoaded,
    required TResult Function(VitalSignError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VitalSignInitial value)? initial,
    TResult? Function(VitalSignLoading value)? loading,
    TResult? Function(VitalSignLoaded value)? loaded,
    TResult? Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult? Function(VitalSignError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VitalSignInitial value)? initial,
    TResult Function(VitalSignLoading value)? loading,
    TResult Function(VitalSignLoaded value)? loaded,
    TResult Function(VitalSignLatestLoaded value)? latestLoaded,
    TResult Function(VitalSignError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class VitalSignError implements VitalSignState {
  const factory VitalSignError(final String message) = _$VitalSignErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$VitalSignErrorImplCopyWith<_$VitalSignErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
