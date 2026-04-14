import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/features/appointments/presentation/pages/appointments_page.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<MemoryGraph>().initialize();
  await initializeDateFormatting('es', null);
  runApp(const AppointmentPreviewApp());
}

class AppointmentPreviewApp extends StatelessWidget {
  const AppointmentPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment Preview',
      theme: CyberTheme.darkTheme,
      home: const AppointmentsPage(),
    );
  }
}
