enum MeditationCategory { calm, focus, sleep, breathing }

class MeditationScript {
  final String id;
  final String title;
  final MeditationCategory category;
  final int durationMinutes;
  final List<String> steps;
  final List<String> tags;

  const MeditationScript({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.steps,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'durationMinutes': durationMinutes,
        'steps': steps,
        'tags': tags,
      };

  static MeditationScript fromJson(Map<String, dynamic> json) =>
      MeditationScript(
        id: json['id'] as String,
        title: json['title'] as String,
        category: MeditationCategory.values.byName(json['category'] as String),
        durationMinutes: (json['durationMinutes'] as num).toInt(),
        steps: (json['steps'] as List<dynamic>).cast<String>(),
        tags: ((json['tags'] as List<dynamic>?) ?? const []).cast<String>(),
      );
}

class MeditationPreferences {
  final MeditationCategory preferredCategory;
  final int preferredDurationMinutes;
  final bool ttsEnabled;
  final String? lastScriptId;

  const MeditationPreferences({
    this.preferredCategory = MeditationCategory.calm,
    this.preferredDurationMinutes = 5,
    this.ttsEnabled = true,
    this.lastScriptId,
  });

  MeditationPreferences copyWith({
    MeditationCategory? preferredCategory,
    int? preferredDurationMinutes,
    bool? ttsEnabled,
    String? lastScriptId,
  }) {
    return MeditationPreferences(
      preferredCategory: preferredCategory ?? this.preferredCategory,
      preferredDurationMinutes:
          preferredDurationMinutes ?? this.preferredDurationMinutes,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      lastScriptId: lastScriptId ?? this.lastScriptId,
    );
  }

  Map<String, dynamic> toJson() => {
        'preferredCategory': preferredCategory.name,
        'preferredDurationMinutes': preferredDurationMinutes,
        'ttsEnabled': ttsEnabled,
        'lastScriptId': lastScriptId,
      };

  static MeditationPreferences fromJson(Map<String, dynamic> json) =>
      MeditationPreferences(
        preferredCategory: MeditationCategory.values.byName(
          json['preferredCategory'] as String? ?? MeditationCategory.calm.name,
        ),
        preferredDurationMinutes:
            (json['preferredDurationMinutes'] as num?)?.toInt() ?? 5,
        ttsEnabled: json['ttsEnabled'] as bool? ?? true,
        lastScriptId: json['lastScriptId'] as String?,
      );
}

class MeditationSessionRecord {
  final String id;
  final String scriptId;
  final MeditationCategory category;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int elapsedSeconds;
  final int completedSteps;
  final bool completed;

  const MeditationSessionRecord({
    required this.id,
    required this.scriptId,
    required this.category,
    required this.startedAt,
    this.completedAt,
    this.elapsedSeconds = 0,
    this.completedSteps = 0,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'scriptId': scriptId,
        'category': category.name,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'elapsedSeconds': elapsedSeconds,
        'completedSteps': completedSteps,
        'completed': completed,
      };

  static MeditationSessionRecord fromJson(Map<String, dynamic> json) =>
      MeditationSessionRecord(
        id: json['id'] as String,
        scriptId: json['scriptId'] as String,
        category: MeditationCategory.values.byName(json['category'] as String),
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
        completedSteps: (json['completedSteps'] as num?)?.toInt() ?? 0,
        completed: json['completed'] as bool? ?? false,
      );
}

class MeditationProgress {
  final int totalSessions;
  final int completedSessions;
  final int totalCompletedSeconds;
  final MeditationSessionRecord? lastSession;

  const MeditationProgress({
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.totalCompletedSeconds = 0,
    this.lastSession,
  });
}
