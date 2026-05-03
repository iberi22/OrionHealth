import 'dart:io';

import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(
    geminiApiKey: Platform.environment['GEMINI_API_KEY'],
  );
  await getIt<MemoryGraph>().initialize();
  runApp(const MedicationPreviewApp());
}

class MedicationPreviewApp extends StatelessWidget {
  const MedicationPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Preview',
      theme: CyberTheme.darkTheme,
      home: const MedicationsPage(),
    );
  }
}
