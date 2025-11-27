import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
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
      theme: CyberTheme.darkTheme,
      home: const UserProfilePage(),
    );
  }
}
