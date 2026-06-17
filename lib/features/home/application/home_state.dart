import 'package:equatable/equatable.dart';
import '../../vitals/domain/entities/vital_sign.dart';

class HomeState extends Equatable {
  final bool isLoadingVitals;
  final Map<VitalSignType, VitalSign?> latestVitals;
  final bool isIndexing;
  final bool indexingError;

  const HomeState({
    this.isLoadingVitals = false,
    this.latestVitals = const {},
    this.isIndexing = false,
    this.indexingError = false,
  });

  HomeState copyWith({
    bool? isLoadingVitals,
    Map<VitalSignType, VitalSign?>? latestVitals,
    bool? isIndexing,
    bool? indexingError,
  }) {
    return HomeState(
      isLoadingVitals: isLoadingVitals ?? this.isLoadingVitals,
      latestVitals: latestVitals ?? this.latestVitals,
      isIndexing: isIndexing ?? this.isIndexing,
      indexingError: indexingError ?? this.indexingError,
    );
  }

  @override
  List<Object?> get props => [
        isLoadingVitals,
        latestVitals,
        isIndexing,
        indexingError,
      ];
}
