import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SharingCubit>()..startListening(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recibir Datos Médicos'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<SharingCubit, SharingState>(
          builder: (context, state) {
            if (state is SharingReceived) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Datos Recibidos',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                      ),
                      const SizedBox(height: 16),
                      GlassmorphicCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Paciente: ${state.package.profile?.name ?? "Desconocido"}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('ID: ${state.package.profile?.uniqueId ?? "N/A"}'),
                              const Divider(color: Colors.white24),
                              Text('Alergias: ${state.package.allergies.length}'),
                              Text('Medicamentos: ${state.package.medications.length}'),
                              Text('Signos Vitales: ${state.package.vitals.length}'),
                              Text('Citas: ${state.package.appointments.length}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // En una implementación real, aquí guardaríamos los datos en Isar
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('GUARDAR EN EXPEDIENTE'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bluetooth_searching, size: 80, color: Colors.cyanAccent),
                  const SizedBox(height: 24),
                  const Text(
                    'Esperando transferencia...',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Asegúrate de que el otro dispositivo esté enviando',
                    style: TextStyle(fontSize: 14, color: Colors.white38),
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(color: Colors.cyanAccent),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
