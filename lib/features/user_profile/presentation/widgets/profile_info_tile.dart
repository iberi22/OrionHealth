import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(title),
      onTap: onTap,
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: Colors.white.withValues(alpha: 0.7)))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }
}
