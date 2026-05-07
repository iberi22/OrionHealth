import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';

void main() {
  runApp(const PreviewApp());
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Component Preview',
      theme: AppTheme.darkTheme,
      home: const UserProfilePage(),
    );
  }
}
