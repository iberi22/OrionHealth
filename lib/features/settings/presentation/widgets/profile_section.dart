import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../user_profile/domain/entities/user_profile.dart';

class ProfileSection extends StatelessWidget {
  final UserProfile? userProfile;
  final bool isDarkMode;
  final VoidCallback? onEditPressed;
  final ValueChanged<bool>? onDarkModeChanged;

  const ProfileSection({
    super.key,
    this.userProfile,
    required this.isDarkMode,
    this.onEditPressed,
    this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile?.name ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProfile?.email ?? 'Sin correo electrónico',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('edit_profile_button'),
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                onPressed: onEditPressed,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.dark_mode_outlined, color: AppColors.secondary, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Modo Oscuro',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
              Switch(
                key: const Key('dark_mode_switch'),
                value: isDarkMode,
                onChanged: onDarkModeChanged,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final hasAvatar = userProfile?.avatarUrl != null && userProfile!.avatarUrl!.isNotEmpty;

    return Container(
      key: const Key('profile_avatar_container'),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
        image: DecorationImage(
          image: hasAvatar
            ? NetworkImage(userProfile!.avatarUrl!)
            : const AssetImage('assets/images/user_placeholder.png') as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
