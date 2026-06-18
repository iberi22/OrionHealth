// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../entities/eps_provider.dart';
import '../repositories/oauth_repository.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';

@injectable
class ConnectProviderUseCase {
  final OAuthRepository _oauthRepository;
  final UserProfileRepository _userProfileRepository;

  ConnectProviderUseCase(this._oauthRepository, this._userProfileRepository);

  Future<void> call(EPSProvider provider) async {
    final result = await _oauthRepository.login(provider);
    if (result != null) {
      final patientId = result.patientId;
      final profile = await _userProfileRepository.getUserProfile();
      if (profile != null) {
        final updatedProfile = profile.copyWith(
          isEpsConnected: true,
          epsPatientId: patientId,
        );
        await _userProfileRepository.saveUserProfile(updatedProfile);
      } else {
        throw Exception('User profile not found.');
      }
    }
  }
}
