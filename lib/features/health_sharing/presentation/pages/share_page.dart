import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  SharedHealthPackage? _package;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isar = getIt<Isar>();
    final profile = await isar.userProfiles.where().findFirst();
    final allergies = await isar.allergys.where().findAll();
    final medications = await isar.medications.where().findAll();
    final vitals = await isar.vitalSigns.where().findAll();
    final appointments = await isar.appointments.where().findAll();

    setState(() {
      _package = SharedHealthPackage(
        profile: profile,
        allergies: allergies,
        medications: medications,
        vitals: vitals,
        appointments: appointments,
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SharingCubit>()..startScanning(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Compartir Datos Médicos'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : BlocConsumer<SharingCubit, SharingState>(
                listener: (context, state) {
                  if (state is SharingSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  } else if (state is SharingFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dispositivos cercanos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                        ),
                        const SizedBox(height: 16),
                        if (state is SharingScanning)
                          Expanded(
                            child: state.devices.isEmpty
                                ? const Center(child: Text('Buscando dispositivos...'))
                                : ListView.builder(
                                    itemCount: state.devices.length,
                                    itemBuilder: (context, index) {
                                      final result = state.devices[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: GlassmorphicCard(
                                          child: ListTile(
                                            title: Text(result.device.platformName.isEmpty ? result.device.remoteId.toString() : result.device.platformName),
                                            subtitle: Text('RSSI: ${result.rssi}'),
                                            trailing: const Icon(Icons.bluetooth_searching, color: Colors.cyanAccent),
                                            onTap: () => context.read<SharingCubit>().shareData(result.device, _package!),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        if (state is SharingConnecting)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text('Conectando a ${state.deviceName}...'),
                              ],
                            ),
                          ),
                        if (state is SharingTransferring)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LinearProgressIndicator(value: state.progress),
                                const SizedBox(height: 16),
                                const Text('Transfiriendo datos de forma segura...'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
