import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

part 'user_profile_state.dart';

@injectable
class UserProfileCubit extends Cubit<UserProfileState> {
  final UserProfileRepository _repository;

  UserProfileCubit(this._repository) : super(UserProfileInitial());

  Future<void> loadUserProfile() async {
    emit(UserProfileLoading());
    try {
      final profile = await _repository.getUserProfile();
      if (profile != null) {
        emit(UserProfileLoaded(profile));
      } else {
        // If no profile exists, emit loaded with an empty profile or handle as needed
        // For now, let's create a default empty profile
        emit(UserProfileLoaded(UserProfile()));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    emit(UserProfileLoading());
    try {
      await _repository.saveUserProfile(profile);
      emit(UserProfileLoaded(profile));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
