// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergy_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AllergyState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Allergy> allergies) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Allergy> allergies)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Allergy> allergies)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AllergyInitial value) initial,
    required TResult Function(AllergyLoading value) loading,
    required TResult Function(AllergyLoaded value) loaded,
    required TResult Function(AllergyError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AllergyInitial value)? initial,
    TResult? Function(AllergyLoading value)? loading,
    TResult? Function(AllergyLoaded value)? loaded,
    TResult? Function(AllergyError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AllergyInitial value)? initial,
    TResult Function(AllergyLoading value)? loading,
    TResult Function(AllergyLoaded value)? loaded,
    TResult Function(AllergyError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergyStateCopyWith<$Res> {
  factory $AllergyStateCopyWith(
          AllergyState value, $Res Function(AllergyState) then) =
      _$AllergyStateCopyWithImpl<$Res, AllergyState>;
}

/// @nodoc
class _$AllergyStateCopyWithImpl<$Res, $Val extends AllergyState>
    implements $AllergyStateCopyWith<$Res> {
  _$AllergyStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AllergyInitialImplCopyWith<$Res> {
  factory _$$AllergyInitialImplCopyWith(_$AllergyInitialImpl value,
          $Res Function(_$AllergyInitialImpl) then) =
      __$$AllergyInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AllergyInitialImplCopyWithImpl<$Res>
    extends _$AllergyStateCopyWithImpl<$Res, _$AllergyInitialImpl>
    implements _$$AllergyInitialImplCopyWith<$Res> {
  __$$AllergyInitialImplCopyWithImpl(
      _$AllergyInitialImpl _value, $Res Function(_$AllergyInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AllergyInitialImpl implements AllergyInitial {
  const _$AllergyInitialImpl();

  @override
  String toString() {
    return 'AllergyState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AllergyInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Allergy> allergies) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Allergy> allergies)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Allergy> allergies)? loaded,
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
    required TResult Function(AllergyInitial value) initial,
    required TResult Function(AllergyLoading value) loading,
    required TResult Function(AllergyLoaded value) loaded,
    required TResult Function(AllergyError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AllergyInitial value)? initial,
    TResult? Function(AllergyLoading value)? loading,
    TResult? Function(AllergyLoaded value)? loaded,
    TResult? Function(AllergyError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AllergyInitial value)? initial,
    TResult Function(AllergyLoading value)? loading,
    TResult Function(AllergyLoaded value)? loaded,
    TResult Function(AllergyError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class AllergyInitial implements AllergyState {
  const factory AllergyInitial() = _$AllergyInitialImpl;
}

/// @nodoc
abstract class _$$AllergyLoadingImplCopyWith<$Res> {
  factory _$$AllergyLoadingImplCopyWith(_$AllergyLoadingImpl value,
          $Res Function(_$AllergyLoadingImpl) then) =
      __$$AllergyLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AllergyLoadingImplCopyWithImpl<$Res>
    extends _$AllergyStateCopyWithImpl<$Res, _$AllergyLoadingImpl>
    implements _$$AllergyLoadingImplCopyWith<$Res> {
  __$$AllergyLoadingImplCopyWithImpl(
      _$AllergyLoadingImpl _value, $Res Function(_$AllergyLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AllergyLoadingImpl implements AllergyLoading {
  const _$AllergyLoadingImpl();

  @override
  String toString() {
    return 'AllergyState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AllergyLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Allergy> allergies) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Allergy> allergies)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Allergy> allergies)? loaded,
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
    required TResult Function(AllergyInitial value) initial,
    required TResult Function(AllergyLoading value) loading,
    required TResult Function(AllergyLoaded value) loaded,
    required TResult Function(AllergyError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AllergyInitial value)? initial,
    TResult? Function(AllergyLoading value)? loading,
    TResult? Function(AllergyLoaded value)? loaded,
    TResult? Function(AllergyError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AllergyInitial value)? initial,
    TResult Function(AllergyLoading value)? loading,
    TResult Function(AllergyLoaded value)? loaded,
    TResult Function(AllergyError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class AllergyLoading implements AllergyState {
  const factory AllergyLoading() = _$AllergyLoadingImpl;
}

/// @nodoc
abstract class _$$AllergyLoadedImplCopyWith<$Res> {
  factory _$$AllergyLoadedImplCopyWith(
          _$AllergyLoadedImpl value, $Res Function(_$AllergyLoadedImpl) then) =
      __$$AllergyLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Allergy> allergies});
}

/// @nodoc
class __$$AllergyLoadedImplCopyWithImpl<$Res>
    extends _$AllergyStateCopyWithImpl<$Res, _$AllergyLoadedImpl>
    implements _$$AllergyLoadedImplCopyWith<$Res> {
  __$$AllergyLoadedImplCopyWithImpl(
      _$AllergyLoadedImpl _value, $Res Function(_$AllergyLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allergies = null,
  }) {
    return _then(_$AllergyLoadedImpl(
      null == allergies
          ? _value._allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<Allergy>,
    ));
  }
}

/// @nodoc

class _$AllergyLoadedImpl implements AllergyLoaded {
  const _$AllergyLoadedImpl(final List<Allergy> allergies)
      : _allergies = allergies;

  final List<Allergy> _allergies;
  @override
  List<Allergy> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  @override
  String toString() {
    return 'AllergyState.loaded(allergies: $allergies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergyLoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._allergies, _allergies));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_allergies));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergyLoadedImplCopyWith<_$AllergyLoadedImpl> get copyWith =>
      __$$AllergyLoadedImplCopyWithImpl<_$AllergyLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Allergy> allergies) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(allergies);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Allergy> allergies)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(allergies);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Allergy> allergies)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(allergies);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AllergyInitial value) initial,
    required TResult Function(AllergyLoading value) loading,
    required TResult Function(AllergyLoaded value) loaded,
    required TResult Function(AllergyError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AllergyInitial value)? initial,
    TResult? Function(AllergyLoading value)? loading,
    TResult? Function(AllergyLoaded value)? loaded,
    TResult? Function(AllergyError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AllergyInitial value)? initial,
    TResult Function(AllergyLoading value)? loading,
    TResult Function(AllergyLoaded value)? loaded,
    TResult Function(AllergyError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class AllergyLoaded implements AllergyState {
  const factory AllergyLoaded(final List<Allergy> allergies) =
      _$AllergyLoadedImpl;

  List<Allergy> get allergies;
  @JsonKey(ignore: true)
  _$$AllergyLoadedImplCopyWith<_$AllergyLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AllergyErrorImplCopyWith<$Res> {
  factory _$$AllergyErrorImplCopyWith(
          _$AllergyErrorImpl value, $Res Function(_$AllergyErrorImpl) then) =
      __$$AllergyErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$AllergyErrorImplCopyWithImpl<$Res>
    extends _$AllergyStateCopyWithImpl<$Res, _$AllergyErrorImpl>
    implements _$$AllergyErrorImplCopyWith<$Res> {
  __$$AllergyErrorImplCopyWithImpl(
      _$AllergyErrorImpl _value, $Res Function(_$AllergyErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$AllergyErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AllergyErrorImpl implements AllergyError {
  const _$AllergyErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AllergyState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergyErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergyErrorImplCopyWith<_$AllergyErrorImpl> get copyWith =>
      __$$AllergyErrorImplCopyWithImpl<_$AllergyErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Allergy> allergies) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Allergy> allergies)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Allergy> allergies)? loaded,
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
    required TResult Function(AllergyInitial value) initial,
    required TResult Function(AllergyLoading value) loading,
    required TResult Function(AllergyLoaded value) loaded,
    required TResult Function(AllergyError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AllergyInitial value)? initial,
    TResult? Function(AllergyLoading value)? loading,
    TResult? Function(AllergyLoaded value)? loaded,
    TResult? Function(AllergyError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AllergyInitial value)? initial,
    TResult Function(AllergyLoading value)? loading,
    TResult Function(AllergyLoaded value)? loaded,
    TResult Function(AllergyError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class AllergyError implements AllergyState {
  const factory AllergyError(final String message) = _$AllergyErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$AllergyErrorImplCopyWith<_$AllergyErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
