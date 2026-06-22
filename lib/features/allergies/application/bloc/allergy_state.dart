part of 'allergy_bloc.dart';

@freezed
class AllergyState with _$AllergyState {
  const factory AllergyState.initial() = AllergyInitial;
  const factory AllergyState.loading() = AllergyLoading;
  const factory AllergyState.loaded(List<Allergy> allergies) = AllergyLoaded;
  const factory AllergyState.error(String message) = AllergyError;
}
