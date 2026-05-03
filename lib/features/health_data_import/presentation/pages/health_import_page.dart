import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/health_import_cubit.dart';
import '../../application/health_import_state.dart';
import '../widgets/data_source_card.dart';
import '../widgets/import_progress_dialog.dart';

class HealthImportPage extends StatelessWidget {
  const HealthImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HealthImportCubit>()..checkAvailableSources(),
      child: const _HealthImportView(),
    );
  }
}

class _HealthImportView extends StatefulWidget {
  const _HealthImportView();

  @override
  State<_HealthImportView> createState() => _HealthImportViewState();
}

class _HealthImportViewState extends State<_HealthImportView> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      _biometricAvailable = await _localAuth.canCheckBiometrics;
      if (mounted) setState(() {});
    } catch (_) {
      _biometricAvailable = false;
    }
  }

  Future<bool> _authenticateBiometric() async {
    if (!_biometricAvailable) return true;
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to confirm health data import',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HealthImportCubit, HealthImportState>(
      listener: (context, state) {
        if (state is HealthImportSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully imported ${state.importedCount} records from ${state.source.displayName}',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        } else if (state is HealthImportError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is HealthImportLoading) {
          return _buildScaffold(
            context,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is HealthImportImporting) {
          return _buildScaffold(
            context,
            child: Center(child: ImportProgressDialog(state: state)),
          );
        }

        if (state is HealthImportAuthenticating) {
          return _buildScaffold(
            context,
            child: Center(
              child: GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Authenticating with ${state.source.displayName}...',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (state is HealthImportReady) {
          return _buildReadyView(context, state);
        }

        if (state is HealthImportInitial) {
          return _buildScaffold(
            context,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<HealthImportCubit>().checkAvailableSources();
                },
                child: const Text('Check Available Sources'),
              ),
            ),
          );
        }

        return _buildScaffold(context, child: const SizedBox.shrink());
      },
    );
  }

  Widget _buildScaffold(BuildContext context, {required Widget child}) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Import Health Data'),
      ),
      body: child,
    );
  }

  Widget _buildReadyView(BuildContext context, HealthImportReady state) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Import Health Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.secondary),
            onPressed: () {
              context.read<HealthImportCubit>().checkAvailableSources();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassmorphicCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Import your health data from connected apps and devices. Data from the last 30 days will be imported.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data Sources',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...HealthDataSource.values.map((source) {
              final isAvailable = state.availability[source] ?? false;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: DataSourceCard(
                  source: source,
                  isAvailable: isAvailable,
                  lastSync: null,
                  onImport: () => _handleImport(context, source),
                ),
              );
            }),
            const SizedBox(height: 16),
            GlassmorphicCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Types to Import',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DataTypeChip(label: 'Steps'),
                        _DataTypeChip(label: 'Distance'),
                        _DataTypeChip(label: 'Heart Rate'),
                        _DataTypeChip(label: 'Sleep'),
                        _DataTypeChip(label: 'Blood Glucose'),
                        _DataTypeChip(label: 'Blood Pressure'),
                        _DataTypeChip(label: 'Height'),
                        _DataTypeChip(label: 'Weight'),
                        _DataTypeChip(label: 'O₂ Saturation'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImport(
    BuildContext context,
    HealthDataSource source,
  ) async {
    // Biometric authentication before import
    final authenticated = await _authenticateBiometric();
    if (!authenticated) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return BlocProvider.value(
            value: context.read<HealthImportCubit>(),
            child: BlocBuilder<HealthImportCubit, HealthImportState>(
              builder: (ctx, state) {
                if (state is HealthImportImporting) {
                  return ImportProgressDialog(state: state);
                }
                if (state is HealthImportAuthenticating) {
                  return GlassmorphicCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Requesting permission from ${state.source.displayName}...',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      );

      context.read<HealthImportCubit>().importFromSource(source);
    }
  }
}

class _DataTypeChip extends StatelessWidget {
  final String label;

  const _DataTypeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
