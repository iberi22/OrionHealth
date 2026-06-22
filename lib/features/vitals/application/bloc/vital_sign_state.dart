part of 'vital_sign_bloc.dart';

@freezed
class VitalSignState with _$VitalSignState {
  const factory VitalSignState.initial() = VitalSignInitial;
  const factory VitalSignState.loading() = VitalSignLoading;
  const factory VitalSignState.loaded(List<VitalSign> vitals) = VitalSignLoaded;
  const factory VitalSignState.latestLoaded(Map<VitalSignType, VitalSign?> latest) = VitalSignLatestLoaded;
  const factory VitalSignState.error(String message) = VitalSignError;
}
