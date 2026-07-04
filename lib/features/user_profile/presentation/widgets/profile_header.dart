import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile userProfile;
  const ProfileHeader({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 128,
          width: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: (userProfile.avatarUrl != null && userProfile.avatarUrl!.isNotEmpty)
                  ? NetworkImage(userProfile.avatarUrl!)
                  : const AssetImage('assets/images/user_placeholder.png') as ImageProvider,
              fit: BoxFit.cover,
            ),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userProfile.name ?? 'Usuario',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          userProfile.email ?? 'no-email@orion.health',
          style: const TextStyle(fontSize: 16, color: AppColors.secondary),
        ),
      ],
    );
  }
}
