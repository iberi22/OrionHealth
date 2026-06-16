// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/core/services/app_logger.dart';
import 'package:orionhealth_health/features/meditation/meditation_models.dart';

/// Full offline meditation service with bundled scripts,
/// progress persistence, and preferences storage.
///
/// All content is pre-loaded; no network required.
class MeditationServiceV2 {
  static const String _scriptsKey = 'meditation_scripts';
  static const String _prefsKey = 'meditation_preferences';
  static const String _historyKey = 'meditation_history';
  static const String _progressKey = 'meditation_progress';

  List<MeditationScript> _scripts = [];
  List<MeditationSessionRecord> _history = [];
  MeditationPreferences _preferences = const MeditationPreferences();
  bool _initialized = false;

  // ── Script library ───────────────────────────────────────

  List<MeditationScript> get scripts => List.unmodifiable(_scripts);
  MeditationPreferences get preferences => _preferences;
  List<MeditationSessionRecord> get history => List.unmodifiable(_history);

  MeditationScript? getScript(String id) {
    try {
      return _scripts.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<MeditationScript> scriptsByCategory(MeditationCategory category) =>
      _scripts.where((s) => s.category == category).toList();

  // ── Lifecycle ────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _loadBundledScripts();
    await _loadFromStorage();
    _initialized = true;
    AppLogger.i('MeditationV2', 'Initialized with ${_scripts.length} scripts');
  }

  void _loadBundledScripts() {
    _scripts = _bundledScripts();
    AppLogger.d('MeditationV2', 'Loaded ${_scripts.length} bundled scripts');
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load preferences
      final prefsJson = prefs.getString(_prefsKey);
      if (prefsJson != null) {
        _preferences =
            MeditationPreferences.fromJson(jsonDecode(prefsJson));
      }

      // Load history
      final historyJson = prefs.getString(_historyKey);
      if (historyJson != null) {
        final list = jsonDecode(historyJson) as List<dynamic>;
        _history = list
            .map((e) => MeditationSessionRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      AppLogger.i('MeditationV2', 'Loaded ${_history.length} sessions from storage');
    } catch (e) {
      AppLogger.e('MeditationV2', 'Failed to load from storage', error: e);
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_preferences.toJson()));
      await prefs.setString(
        _historyKey,
        jsonEncode(_history.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      AppLogger.e('MeditationV2', 'Failed to save to storage', error: e);
    }
  }

  // ── Script recommendation ────────────────────────────────

  Future<MeditationScript> recommendScript({List<String>? memoryHints}) async {
    if (_scripts.isEmpty) return _fallbackScript();

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

  MeditationScript _fallbackScript() {
    const fallback = MeditationScript(
      id: 'calm-01',
      title: 'Calma Interior',
      category: MeditationCategory.calm,
      durationMinutes: 5,
      steps: ['Respira profundamente', 'Relaja los hombros', 'Sonríe'],
    );
    _scripts = [fallback];
    return fallback;
  }

  // ── Session management ───────────────────────────────────

  Future<MeditationSessionRecord> startSession(MeditationScript script) async {
    final session = MeditationSessionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scriptId: script.id,
      category: script.category,
      startedAt: DateTime.now(),
    );

    _updatePreferences(script);
    return session;
  }

  Future<void> completeSession({
    required MeditationSessionRecord session,
    required int elapsedSeconds,
    required int completedSteps,
  }) async {
    final completed = MeditationSessionRecord(
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

    _updatePreferences(getScript(session.scriptId));
    await _saveToStorage();
    AppLogger.i('MeditationV2', 'Session completed: ${session.id} ($elapsedSeconds s)');
  }

  // ── Progress ─────────────────────────────────────────────

  Future<MeditationProgress> getProgress() async {
    final completed =
        _history.where((s) => s.completed).toList();
    return MeditationProgress(
      totalSessions: _history.length,
      completedSessions: completed.length,
      totalCompletedSeconds:
          completed.fold(0, (sum, s) => sum + s.elapsedSeconds),
      lastSession: _history.isNotEmpty ? _history.first : null,
    );
  }

  // ── Preferences ──────────────────────────────────────────

  void _updatePreferences(MeditationScript? script) {
    if (script == null) return;
    _preferences = _preferences.copyWith(lastScriptId: script.id);
  }

  Future<void> updatePreferences(MeditationPreferences prefs) async {
    _preferences = prefs;
    await _saveToStorage();
  }

  // ── Bundled scripts (full Spanish content) ───────────────

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
