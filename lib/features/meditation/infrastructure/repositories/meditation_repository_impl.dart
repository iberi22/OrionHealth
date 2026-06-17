// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../../../../core/services/app_logger.dart';
import '../../domain/entities/meditation_category.dart';
import '../../domain/entities/meditation_preferences.dart';
import '../../domain/entities/meditation_progress.dart';
import '../../domain/entities/meditation_script.dart';
import '../../domain/entities/meditation_session.dart';
import '../../domain/repositories/meditation_repository.dart';
import '../datasources/meditation_local_datasource.dart';

@LazySingleton(as: MeditationRepository)
class MeditationRepositoryImpl implements MeditationRepository {
  final MeditationLocalDataSource _localDataSource;

  List<MeditationScript> _scripts = [];
  List<MeditationSession> _history = [];
  MeditationPreferences _preferences = const MeditationPreferences();
  bool _initialized = false;

  MeditationRepositoryImpl(this._localDataSource);

  @override
  List<MeditationScript> get scripts => List.unmodifiable(_scripts);

  @override
  MeditationPreferences get preferences => _preferences;

  @override
  List<MeditationSession> get history => List.unmodifiable(_history);

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _scripts = _bundledScripts();
    _preferences = await _localDataSource.getPreferences() ?? const MeditationPreferences();
    _history = await _localDataSource.getHistory();
    _initialized = true;
    AppLogger.i('MeditationRepository', 'Initialized with ${_scripts.length} scripts');
  }

  @override
  MeditationScript? getScript(String id) {
    try {
      return _scripts.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<MeditationScript> scriptsByCategory(MeditationCategory category) =>
      _scripts.where((s) => s.category == category).toList();

  @override
  Future<MeditationScript> recommendScript({List<String>? memoryHints}) async {
    if (_scripts.isEmpty) _scripts = _bundledScripts();

    // Try matching by last completed
    if (_preferences.lastScriptId != null) {
      final last = getScript(_preferences.lastScriptId!);
      if (last != null) return last;
    }

    // Try matching by preferred category
    final byCategory = scriptsByCategory(_preferences.preferredCategory);
    if (byCategory.isNotEmpty) return byCategory.first;

    return _scripts.first;
  }

  @override
  Future<MeditationSession> startSession(MeditationScript script) async {
    final session = MeditationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scriptId: script.id,
      category: script.category,
      startedAt: DateTime.now(),
    );

    await _updateLastScriptId(script.id);
    return session;
  }

  @override
  Future<void> completeSession({
    required MeditationSession session,
    required int elapsedSeconds,
    required int completedSteps,
  }) async {
    final completed = MeditationSession(
      id: session.id,
      scriptId: session.scriptId,
      category: session.category,
      startedAt: session.startedAt,
      completedAt: DateTime.now(),
      elapsedSeconds: elapsedSeconds,
      completedSteps: completedSteps,
      completed: true,
    );

    _history.insert(0, completed);

    // Keep last 100 sessions
    if (_history.length > 100) {
      _history = _history.sublist(0, 100);
    }

    await _localDataSource.saveHistory(_history);
    await _updateLastScriptId(session.scriptId);
    AppLogger.i('MeditationRepository', 'Session completed: ${session.id} ($elapsedSeconds s)');
  }

  @override
  Future<MeditationProgress> getProgress() async {
    final completed = _history.where((s) => s.completed).toList();
    return MeditationProgress(
      totalSessions: _history.length,
      completedSessions: completed.length,
      totalCompletedSeconds:
          completed.fold(0, (sum, s) => sum + s.elapsedSeconds),
      lastSession: _history.isNotEmpty ? _history.first : null,
    );
  }

  @override
  Future<void> updatePreferences(MeditationPreferences prefs) async {
    _preferences = prefs;
    await _localDataSource.savePreferences(_preferences);
  }

  Future<void> _updateLastScriptId(String scriptId) async {
    _preferences = _preferences.copyWith(lastScriptId: scriptId);
    await _localDataSource.savePreferences(_preferences);
  }

  static List<MeditationScript> _bundledScripts() {
    return [
      const MeditationScript(
        id: 'calm-01',
        title: 'Calma Interior',
        category: MeditationCategory.calm,
        durationMinutes: 5,
        steps: [
          'Siéntate cómodamente con la espalda recta',
          'Cierra los ojos suavemente',
          'Inhala profundamente contando hasta 4',
          'Mantén el aire contando hasta 2',
          'Exhala lentamente contando hasta 6',
          'Repite: inhala 4, sostén 2, exhala 6',
          'Observa cómo tu cuerpo se relaja',
          'Sonríe suavemente y abre los ojos',
        ],
        tags: ['principiante', 'respiracion', 'calma'],
      ),
      const MeditationScript(
        id: 'focus-01',
        title: 'Enfoque Profundo',
        category: MeditationCategory.focus,
        durationMinutes: 10,
        steps: [
          'Busca un lugar tranquilo',
          'Siéntate y cierra los ojos',
          'Inhala profundamente 3 veces',
          'Visualiza un punto de luz frente a ti',
          'Mantén tu atención en la luz',
          'Si tu mente divaga, regresa a la luz',
          'Siente cómo se intensifica el enfoque',
          'Abre los ojos y mantén la claridad',
        ],
        tags: ['concentracion', 'mente', 'trabajo'],
      ),
      const MeditationScript(
        id: 'sleep-01',
        title: 'Sueño Profundo',
        category: MeditationCategory.sleep,
        durationMinutes: 15,
        steps: [
          'Recuéstate en la cama',
          'Cierra los ojos y respira suave',
          'Relaja los pies y los tobillos',
          'Relaja las piernas y las rodillas',
          'Relaja el abdomen y el pecho',
          'Relaja los hombros y el cuello',
          'Relaja la mandíbula y la frente',
          'Imagina que flotas sobre nubes suaves',
          'Déjate llevar por la gravedad',
          'Respira profundo y suéltate',
        ],
        tags: ['dormir', 'relajacion', 'noche'],
      ),
      const MeditationScript(
        id: 'breathing-01',
        title: 'Respiración 4-7-8',
        category: MeditationCategory.breathing,
        durationMinutes: 5,
        steps: [
          'Siéntate derecho o recuéstate',
          'Exhala completamente por la boca',
          'Inhala por la nariz contando 4',
          'Mantén el aire contando 7',
          'Exhala por la boca contando 8',
          'Repite el ciclo 4-7-8',
          'Siente la calma en cada ciclo',
          'Abre los ojos cuando estés listo',
        ],
        tags: ['respiracion', 'ansiedad', 'calma'],
      ),
      const MeditationScript(
        id: 'calm-02',
        title: 'Escaneo Corporal',
        category: MeditationCategory.calm,
        durationMinutes: 10,
        steps: [
          'Acuéstate boca arriba con brazos a los lados',
          'Cierra los ojos y respira naturalmente',
          'Lleva atención a los dedos del pie izquierdo',
          'Sube lentamente por el pie, tobillo y pantorrilla',
          'Siente la pierna derecha completa',
          'Sube por el torso: abdomen, pecho, espalda',
          'Siente los hombros y los brazos',
          'Siente el cuello, la mandíbula y el rostro',
          'Ahora siente tu cuerpo completo como un todo',
          'Respira profundamente y vuelve suavemente',
        ],
        tags: ['cuerpo', 'conciencia', 'relajacion'],
      ),
      const MeditationScript(
        id: 'focus-02',
        title: 'Mindfulness en 3 Minutos',
        category: MeditationCategory.focus,
        durationMinutes: 3,
        steps: [
          'Pausa lo que estés haciendo',
          'Siéntate erguido y respira',
          'Nota 3 cosas que puedas ver',
          'Nota 3 cosas que puedas oír',
          'Nota 3 sensaciones en tu cuerpo',
          'Respira profundo y continúa',
        ],
        tags: ['rapido', 'mindfulness', 'pausa'],
      ),
    ];
  }
}
