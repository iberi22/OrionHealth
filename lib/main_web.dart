// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2026 SouthWest AI Labs

/// Web entry point for OrionHealth PWA.
///
/// This is a minimal Flutter Web build that showcases the Emergency
/// Data feature (FEAT-022) as a PWA. The full mobile app (with native
/// FFI for AI/ML, WorkManager, Isar) is not web-compatible by design.
///
/// Architecture:
/// - Public landing (orionhealth.pages.dev) → Astro static site (docs/)
/// - PWA demo (app.orionhealth.pages.dev) → this Flutter Web build
/// - Native apps → full Flutter (Android/iOS) with all 26 features
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/emergency/domain/entities/emergency_contact.dart';
import 'features/emergency/domain/entities/medical_id.dart';
import 'features/emergency/infrastructure/repositories/web_medical_id_repository.dart';
import 'features/emergency/infrastructure/services/qr_generator_service.dart';
import 'features/emergency/presentation/cubit/emergency_cubit.dart';
import 'features/emergency/presentation/pages/emergency_id_page.dart';
import 'features/emergency/presentation/pages/emergency_edit_page.dart';
import 'features/emergency/presentation/widgets/medical_id_qr_view.dart';
import 'features/emergency/domain/usecases/get_medical_id_usecase.dart';
import 'features/emergency/domain/usecases/update_medical_id_usecase.dart';

void main() {
  runApp(const OrionHealthWebApp());
}

class OrionHealthWebApp extends StatelessWidget {
  const OrionHealthWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Web uses SharedPreferences implementation
    final repo = WebMedicalIdRepository();
    return MaterialApp(
      title: 'OrionHealth Emergency',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => EmergencyCubit(
          GetMedicalIdUseCase(repo),
          UpdateMedicalIdUseCase(repo),
        ),
        child: const WebHome(),
      ),
      routes: {
        '/edit': (context) {
          final cubit = context.read<EmergencyCubit>();
          return BlocProvider.value(
            value: cubit,
            child: const EmergencyEditPage(userId: 'demo-user'),
          );
        },
      },
    );
  }
}

class WebHome extends StatelessWidget {
  const WebHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚨 OrionHealth Emergency Demo'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Acerca de',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'PWA Demo: Medical ID (FEAT-022)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Emergency ID page (lock screen view)
            SizedBox(
              height: 600,
              child: EmergencyIdPage(userId: 'demo-user'),
            ),
            // Edit button
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar Medical ID'),
                onPressed: () => Navigator.pushNamed(context, '/edit'),
              ),
            ),
            // QR section
            BlocBuilder<EmergencyCubit, EmergencyState>(
              builder: (context, state) {
                if (state.medicalId == null) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Configura tu Medical ID para ver el QR'),
                  );
                }
                return MedicalIdQrView(medicalId: state.medicalId!);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'OrionHealth Emergency (PWA Demo)',
      applicationVersion: 'v0.10.0',
      applicationLegalese: '''
OrionHealth v0.10.0 — FEAT-022 + Flutter Web PWA

Esta es una demo PWA de la feature Emergency Data.
Funcionalidad:
• Medical ID (tipo de sangre, alergias, ICE)
• QR para primeros respondedores
• Persistencia local (SharedPreferences + Web Crypto)

App completa (26 features): ver orionhealth.app
''',
      children: const [
        SizedBox(height: 8),
        Text('🔒 Todos los datos se almacenan localmente en el navegador.'),
      ],
    );
  }
}
