import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/theme/app_colors.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_auto_onboarding_cubit.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';

/// 🚀 Pantalla de Auto-Onboarding desde EPS.
///
/// Muestra el progreso en tiempo real de la conexión con la EPS
/// y la extracción de datos clínicos. Al finalizar, muestra un
/// resumen de lo que se cargó automáticamente.
///
/// Flujo:
/// 1. Progress indicator animado con mensajes
/// 2. Al completar: resumen de datos extraídos
/// 3. Botón "Continuar" → va al onboarding con datos pre-poblados
class EpsAutoOnboardingScreen extends StatefulWidget {
  final EPSProvider provider;
  final String tipoDocumento;
  final String numeroDocumento;
  final void Function(UserProfile profile) onComplete;

  const EpsAutoOnboardingScreen({
    super.key,
    required this.provider,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.onComplete,
  });

  @override
  State<EpsAutoOnboardingScreen> createState() => _EpsAutoOnboardingScreenState();
}

class _EpsAutoOnboardingScreenState extends State<EpsAutoOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      context.read<EpsAutoOnboardingCubit>().start(
            provider: widget.provider,
            tipoDocumento: widget.tipoDocumento,
            numeroDocumento: widget.numeroDocumento,
          );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EpsAutoOnboardingCubit, EpsAutoOnboardingState>(
      listener: (context, state) {
        if (state is EpsAutoOnboardingSuccess) {
          // Auto-transition después de mostrar el resumen
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              widget.onComplete(state.profile);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<EpsAutoOnboardingCubit, EpsAutoOnboardingState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    Expanded(
                      child: _buildContent(state),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.local_hospital_rounded,
          size: 64,
          color: AppColors.primary.withOpacity(0.8),
        ),
        const SizedBox(height: 16),
        Text(
          widget.provider.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Conectando con el IHCE de Minsalud',
          style: TextStyle(fontSize: 14, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildContent(EpsAutoOnboardingState state) {
    switch (state) {
      case EpsAutoOnboardingInitial():
        return const SizedBox.shrink();

      case EpsAutoOnboardingConnecting():
        return _buildProgress(
          icon: Icons.wifi_find_rounded,
          message: (state as EpsAutoOnboardingConnecting).message,
          progress: state.progress,
          showPulse: true,
        );

      case EpsAutoOnboardingFetching():
        return _buildProgress(
          icon: Icons.cloud_download_rounded,
          message: (state as EpsAutoOnboardingFetching).message,
          progress: state.progress,
          showPulse: true,
        );

      case EpsAutoOnboardingProcessing():
        return _buildProgress(
          icon: Icons.health_and_safety_rounded,
          message: 'Procesando tu historial clínico...',
          progress: state.progress,
          showPulse: true,
        );

      case EpsAutoOnboardingSuccess():
        return _buildSuccess(state as EpsAutoOnboardingSuccess);

      case EpsAutoOnboardingError():
        return _buildError(state as EpsAutoOnboardingError);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProgress({
    required IconData icon,
    required String message,
    required double progress,
    required bool showPulse,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Opacity(
            opacity: _pulseAnimation.value,
            child: Icon(icon, size: 48, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(fontSize: 12, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildSuccess(EpsAutoOnboardingSuccess state) {
    final profile = state.profile;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded, size: 72, color: Colors.greenAccent),
        const SizedBox(height: 16),
        const Text(
          '¡Perfil cargado!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          state.isComplete
              ? 'Todos tus datos fueron extraídos de ${widget.provider.name}'
              : '${state.skippedSteps} pasos completados automáticamente',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 32),

        // Resumen de datos extraídos
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildDataRow(
                Icons.person,
                'Nombre',
                profile.name ?? '— Pendiente',
                profile.name != null,
              ),
              const SizedBox(height: 12),
              _buildDataRow(
                Icons.calendar_today,
                'Fecha nacimiento',
                profile.birthDate != null
                    ? '${profile.birthDate!.day}/${profile.birthDate!.month}/${profile.birthDate!.year}'
                    : '— Pendiente',
                profile.birthDate != null,
              ),
              const SizedBox(height: 12),
              _buildDataRow(
                Icons.wc,
                'Sexo',
                profile.sex == 'M' ? 'Masculino' : profile.sex == 'F' ? 'Femenino' : '— Pendiente',
                profile.sex != null,
              ),
              const SizedBox(height: 12),
              _buildDataRow(
                Icons.medical_services,
                'Condiciones',
                profile.conditions.isNotEmpty
                    ? profile.conditions.take(2).join(', ') +
                        (profile.conditions.length > 2
                            ? ' +${profile.conditions.length - 2} más'
                            : '')
                    : '— Pendiente',
                profile.conditions.isNotEmpty,
              ),
              const SizedBox(height: 12),
              _buildDataRow(
                Icons.medication,
                'Medicamentos',
                profile.medications.isNotEmpty
                    ? profile.medications.take(2).join(', ') +
                        (profile.medications.length > 2
                            ? ' +${profile.medications.length - 2} más'
                            : '')
                    : '— Pendiente',
                profile.medications.isNotEmpty,
              ),
            ],
          ),
        ),

        if (!state.isComplete && state.missingFields.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Falta completar: ${state.missingFields.join(", ")}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.amberAccent),
          ),
        ],

        const SizedBox(height: 32),

        // Botón continuar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => widget.onComplete(profile),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Continuar al Onboarding', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value, bool isComplete) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isComplete ? Colors.greenAccent : Colors.white38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isComplete ? Colors.white : Colors.white38,
                  fontWeight: isComplete ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        if (isComplete)
          const Icon(Icons.check_circle, size: 18, color: Colors.greenAccent)
        else
          const Icon(Icons.edit, size: 18, color: Colors.white24),
      ],
    );
  }

  Widget _buildError(EpsAutoOnboardingError state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
        const SizedBox(height: 16),
        Text(
          'Error de conexión',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade300,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 32),
        if (state.canRetry) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<EpsAutoOnboardingCubit>().reset();
                // Re-intentar
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reintentar', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Continuar con onboarding manual
              final manualProfile = UserProfile(
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              widget.onComplete(manualProfile);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white54,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Continuar sin datos de EPS', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
