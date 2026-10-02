import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/workout_repository.dart';

class WorkoutsPage extends StatefulWidget {
  final WorkoutRepository? repository;
  const WorkoutsPage({super.key, this.repository});
  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  late Future<List<WorkoutSession>> _sessions;
  @override
  void initState() {
    super.initState();
    _sessions = _load();
  }

  Future<List<WorkoutSession>> _load() =>
      (widget.repository ?? getIt<WorkoutRepository>()).getAllSessions();
  Future<void> _refresh() async {
    setState(() => _sessions = _load());
    await _sessions;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Entrenamientos')),
    body: FutureBuilder<List<WorkoutSession>>(
      future: _sessions,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: _refresh,
              child: const Text('No se pudieron cargar. Reintentar'),
            ),
          );
        }
        final sessions = snapshot.data ?? [];
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (sessions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Importa un archivo .swalhealth.json para ver tus entrenamientos.',
                  ),
                ),
              for (final session in sessions)
                ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(
                    DateFormat.yMMMd().add_Hm().format(
                      session.startedAt.toLocal(),
                    ),
                  ),
                  subtitle: Text(
                    '${session.exercises.length} ejercicios · ${(session.duration.inSeconds / 60).toStringAsFixed(1)} min',
                  ),
                  trailing: session.energyKcal == null
                      ? null
                      : Text('${session.energyKcal!.toStringAsFixed(0)} kcal'),
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => WorkoutDetailPage(session: session),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

class WorkoutDetailPage extends StatelessWidget {
  final WorkoutSession session;
  const WorkoutDetailPage({super.key, required this.session});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Entrenamiento')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(DateFormat.yMMMd().add_Hm().format(session.startedAt.toLocal())),
        Text(
          'Duración: ${(session.duration.inSeconds / 60).toStringAsFixed(1)} min',
        ),
        if (session.energyKcal != null)
          Text('Energía: ${session.energyKcal} kcal (${session.energyMethod})'),
        if (session.perceivedEffort != null)
          Text('Esfuerzo: ${session.perceivedEffort}/10'),
        if (session.routineId != null) Text('Rutina: ${session.routineId}'),
        for (final exercise in session.exercises)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.ref.replaceFirst('wg:', '').replaceAll('-', ' '),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (var i = 0; i < exercise.sets.length; i++)
                    Text(
                      'Serie ${i + 1}: ${_setDescription(exercise.sets[i])}',
                    ),
                ],
              ),
            ),
          ),
        if (session.notes != null && session.notes!.isNotEmpty)
          Text(session.notes!),
      ],
    ),
  );

  String _setDescription(WorkoutSet set) => [
    if (set.reps != null) '${set.reps} reps',
    if (set.weightKg != null) '${set.weightKg} kg',
    if (set.durationS != null) '${set.durationS} s',
    if (set.distanceM != null) '${set.distanceM} m',
    if (set.rpe != null) 'RPE ${set.rpe}',
  ].join(' · ');
}
