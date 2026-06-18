// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../repositories/oauth_repository.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';

@injectable
class DisconnectProviderUseCase {
  final OAuthRepository _oauthRepository;
  final UserProfileRepository _userProfileRepository;

  DisconnectProviderUseCase(this._oauthRepository, this._userProfileRepository);

  Future<void> call(String providerId) async {
    await _oauthRepository.logout(providerId);
    final profile = await _userProfileRepository.getUserProfile();
    if (profile != null) {
      final providers = await _oauthRepository.getConnectedProviders();
      if (providers.isEmpty) {
        final updatedProfile = profile.copyWith(isEpsConnected: false);
        updatedProfile.epsPatientId = null;
        await _userProfileRepository.saveUserProfile(updatedProfile);
      }
    }
  }
}
