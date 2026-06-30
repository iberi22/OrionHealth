// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../application/meditation_cubit.dart';
import '../application/meditation_state.dart';
import 'widgets/audio_player_controls.dart';
import 'widgets/meditation_timer.dart';

class MeditationPage extends StatelessWidget {
  const MeditationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MeditationCubit>()..initialize(),
      child: const MeditationView(),
    );
  }
}

class MeditationView extends StatefulWidget {
  const MeditationView({super.key});

  @override
  State<MeditationView> createState() => _MeditationViewState();
}

class _MeditationViewState extends State<MeditationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _breathAnimation = Tween<double>(begin: 0.82, end: 1.18).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101828),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Meditación Guiada'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101828), Color(0xFF2F3B73), Color(0xFF1E1B4B)],
          ),
        ),
        child: BlocConsumer<MeditationCubit, MeditationState>(
          listener: (context, state) {
            if (state.status == MeditationStatus.playing) {
              _breathController.repeat(reverse: true);
            } else {
              _breathController.stop();
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MeditationState state) {
    switch (state.status) {
      case MeditationStatus.initial:
      case MeditationStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white70),
        );
      case MeditationStatus.error:
        return Center(
          child: Text(
            state.error ?? 'Error desconocido',
            style: const TextStyle(color: Colors.redAccent),
          ),
        );
      case MeditationStatus.completed:
        return _buildCompletedView(context, state);
      case MeditationStatus.idle:
        return _buildWelcomeView(context, state);
      case MeditationStatus.playing:
      case MeditationStatus.paused:
        return _buildActiveView(context, state);
    }
  }

  Widget _buildWelcomeView(BuildContext context, MeditationState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          state.script?.title ?? 'Cargando...',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${state.script?.durationMinutes ?? 0} minutos • ${state.script?.category.name ?? ''}',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () => context.read<MeditationCubit>().startMeditation(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF101828),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Comenzar', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildActiveView(BuildContext context, MeditationState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _breathAnimation,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Center(
              child: Text(
                state.status == MeditationStatus.playing ? 'Inhala / Exhala' : 'Pausado',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
        const SizedBox(height: 64),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            state.steps.isNotEmpty ? state.steps[state.currentStep] : '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Paso ${state.currentStep + 1} de ${state.steps.length}',
          style: const TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 48),
        MeditationTimer(elapsedSeconds: state.elapsedSeconds),
        const SizedBox(height: 48),
        AudioPlayerControls(
          isPlaying: state.status == MeditationStatus.playing,
          onPrevious: () => context.read<MeditationCubit>().previousStep(),
          onTogglePause: () => context.read<MeditationCubit>().togglePause(),
          onNext: () => context.read<MeditationCubit>().nextStep(),
        ),
      ],
    );
  }

  Widget _buildCompletedView(BuildContext context, MeditationState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Sesión Completada',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Has meditado durante ${state.elapsedSeconds ~/ 60}m ${state.elapsedSeconds % 60}s',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 48),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver al inicio', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
