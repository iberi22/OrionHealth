import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_health_summary.dart';

void main() {
  group('HomeState', () {
    test('initial state has default values', () {
      const state = HomeState();
      expect(state.status, HomeStatus.initial);
      expect(state.healthSummary, isNull);
      expect(state.modules, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('should support value equality', () {
      const state1 = HomeState(status: HomeStatus.loading);
      const state2 = HomeState(status: HomeStatus.loading);
      expect(state1, equals(state2));
    });

    test('copyWith works correctly', () {
      const state = HomeState(status: HomeStatus.initial);
      final updated = state.copyWith(status: HomeStatus.loaded);
      expect(updated.status, HomeStatus.loaded);
      expect(updated.healthSummary, isNull);
    });

    test('copyWith preserves values when not provided', () {
      const summary = HomeHealthSummary(
        latestVitals: [],
        upcomingAppointments: [],
        medicationCount: 0,
      );
      final state = HomeState(status: HomeStatus.loaded, healthSummary: summary);
      final updated = state.copyWith(errorMessage: 'Error');
      expect(updated.status, HomeStatus.loaded);
      expect(updated.healthSummary, summary);
      expect(updated.errorMessage, 'Error');
    });
  });
}
