class HomeDto {
  final bool hasIndexed;
  final DateTime? lastSyncTime;
  final int healthScore;

  const HomeDto({required this.hasIndexed, this.lastSyncTime, required this.healthScore});

  Map<String, dynamic> toJson() => {
    'hasIndexed': hasIndexed,
    if (lastSyncTime != null) 'lastSyncTime': lastSyncTime!.toIso8601String(),
    'healthScore': healthScore,
  };

  factory HomeDto.fromJson(Map<String, dynamic> j) => HomeDto(
    hasIndexed: j['hasIndexed'] as bool? ?? false,
    lastSyncTime: j['lastSyncTime'] != null ? DateTime.parse(j['lastSyncTime'] as String) : null,
    healthScore: j['healthScore'] as int? ?? 0,
  );
}
