import 'package:equatable/equatable.dart';
import '../../vitals/domain/entities/vital_sign.dart';

class HomeState extends Equatable {
  final Map<VitalSignType, VitalSign?> latestVitals;
  final bool isIndexing;
  final bool isLoadingVitals;
  final bool indexingError;
  final String? error;

  const HomeState({
    this.latestVitals = const {},
    this.isIndexing = false,
    this.isLoadingVitals = true,
    this.indexingError = false,
    this.error,
  });

  HomeState copyWith({
    Map<VitalSignType, VitalSign?>? latestVitals,
    bool? isIndexing,
    bool? isLoadingVitals,
    bool? indexingError,
    String? error,
  }) {
    return HomeState(
      latestVitals: latestVitals ?? this.latestVitals,
      isIndexing: isIndexing ?? this.isIndexing,
      isLoadingVitals: isLoadingVitals ?? this.isLoadingVitals,
      indexingError: indexingError ?? this.indexingError,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [latestVitals, isIndexing, isLoadingVitals, indexingError, error];
}
