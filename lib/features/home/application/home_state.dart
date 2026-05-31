import 'package:equatable/equatable.dart';
import '../../vitals/domain/entities/vital_sign.dart';
import '../../medical_assistant/domain/entities/medical_insight.dart';

class HomeState extends Equatable {
  final Map<VitalSignType, VitalSign?> latestVitals;
  final List<MedicalInsight> recentInsights;
  final bool isIndexing;
  final bool isLoadingVitals;
  final bool indexingError;
  final String? error;

  const HomeState({
    this.latestVitals = const {},
    this.recentInsights = const [],
    this.isIndexing = false,
    this.isLoadingVitals = true,
    this.indexingError = false,
    this.error,
  });

  HomeState copyWith({
    Map<VitalSignType, VitalSign?>? latestVitals,
    List<MedicalInsight>? recentInsights,
    bool? isIndexing,
    bool? isLoadingVitals,
    bool? indexingError,
    String? error,
  }) {
    return HomeState(
      latestVitals: latestVitals ?? this.latestVitals,
      recentInsights: recentInsights ?? this.recentInsights,
      isIndexing: isIndexing ?? this.isIndexing,
      isLoadingVitals: isLoadingVitals ?? this.isLoadingVitals,
      indexingError: indexingError ?? this.indexingError,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        latestVitals,
        recentInsights,
        isIndexing,
        isLoadingVitals,
        indexingError,
        error,
      ];
}
