/// FEAT-022: Emergency ID display page
///
/// Lock-screen friendly: large fonts, high contrast, only critical fields.
/// First responder can read this without unlocking the app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/emergency_cubit.dart';

class EmergencyIdPage extends StatefulWidget {
  final String userId;
  const EmergencyIdPage({super.key, required this.userId});

  @override
  State<EmergencyIdPage> createState() => _EmergencyIdPageState();
}

class _EmergencyIdPageState extends State<EmergencyIdPage> {
  @override
  void initState() {
    super.initState();
    context.read<EmergencyCubit>().load(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('🚨 Medical ID'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit),
            onPressed: () =>
                Navigator.pushNamed(context, '/emergency/edit'),
          ),
        ],
      ),
      body: BlocBuilder<EmergencyCubit, EmergencyState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.notSet) {
            return const _EmptyState();
          }
          if (state.error != null) {
            return Center(
              child: Text('Error: ${state.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }
          final id = state.medicalId;
          if (id == null) {
            return const _EmptyState();
          }
          return _CriticalCard(medicalId: id);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.medical_services_outlined,
              size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('No Medical ID set',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create Medical ID'),
            onPressed: () =>
                Navigator.pushNamed(context, '/emergency/edit'),
          ),
        ],
      ),
    );
  }
}

class _CriticalCard extends StatelessWidget {
  final dynamic medicalId;
  const _CriticalCard({required this.medicalId});

  @override
  Widget build(BuildContext context) {
    final fields = medicalId.toCriticalCard() as List<String>;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name + blood type prominently
            Text(
              medicalId.fullName as String,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Text(
              '${medicalId.bloodType.displayName} • ${medicalId.age} años',
              style: const TextStyle(fontSize: 24, color: Colors.black87),
            ),
            const Divider(height: 32),
            // Allergies (critical)
            if ((medicalId.allergies as List).isNotEmpty)
              _AlertSection(
                icon: Icons.warning_amber_rounded,
                title: 'ALERGIAS',
                content: (medicalId.allergies as List).join('\n'),
              ),
            if ((medicalId.currentMedications as List).isNotEmpty)
              _AlertSection(
                icon: Icons.medication_outlined,
                title: 'MEDICAMENTOS',
                content: (medicalId.currentMedications as List).join('\n'),
              ),
            if ((medicalId.chronicConditions as List).isNotEmpty)
              _AlertSection(
                icon: Icons.medical_information_outlined,
                title: 'CONDICIONES',
                content: (medicalId.chronicConditions as List)
                    .map((c) => '• ${c.name}')
                    .join('\n'),
              ),
            const Spacer(),
            // ICE contact at bottom
            _AlertSection(
              icon: Icons.phone,
              title: 'CONTACTO DE EMERGENCIA',
              content:
                  '${medicalId.primaryContact.name}\n${medicalId.primaryContact.phone}',
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _AlertSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                  Text(content, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
