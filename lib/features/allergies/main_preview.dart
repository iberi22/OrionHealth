import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/features/allergies/presentation/pages/allergies_page.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<MemoryGraph>().initialize();
  runApp(const AllergiesPreviewApp());
}

class AllergiesPreviewApp extends StatelessWidget {
  const AllergiesPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allergies Preview',
      theme: CyberTheme.darkTheme,
      home: const AllergiesPage(),
    );
  }
}
