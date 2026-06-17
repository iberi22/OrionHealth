import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/badge_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/reputation_badge.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/services/badge_calculator.dart';

class MockBadgeCalculator extends Mock implements BadgeCalculator {}

void main() {
  late BadgeCubit cubit;
  late MockBadgeCalculator mockBadgeCalculator;

  setUp(() {
    mockBadgeCalculator = MockBadgeCalculator();
    cubit = BadgeCubit(mockBadgeCalculator);
  });

  tearDown(() {
    cubit.close();
  });

  const tDoctorId = 'doc1';

  group('BadgeCubit', () {
    test('initial state should have no current level and not loading', () {
      final state = cubit.state;
      expect(state.currentLevel, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('emits [loading, loaded with level] when refreshBadge succeeds', () async {
      when(() => mockBadgeCalculator.calculateBadge(tDoctorId))
          .thenAnswer((_) async => BadgeLevel.silver);

      expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<BadgeState>((s) => s.isLoading == true && s.currentLevel == null),
          predicate<BadgeState>((s) => s.isLoading == false && s.currentLevel == BadgeLevel.silver),
        ]),
      );

      await cubit.refreshBadge(tDoctorId);
    });

    test('emits [loading, loaded with null] when badge calculator returns null', () async {
      when(() => mockBadgeCalculator.calculateBadge(tDoctorId))
          .thenAnswer((_) async => null);

      expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<BadgeState>((s) => s.isLoading == true && s.currentLevel == null),
          predicate<BadgeState>((s) => s.isLoading == false && s.currentLevel == null),
        ]),
      );

      await cubit.refreshBadge(tDoctorId);
    });

    test('emits [loading, error] when refreshBadge fails', () async {
      when(() => mockBadgeCalculator.calculateBadge(tDoctorId))
          .thenThrow(Exception('Badge error'));

      expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<BadgeState>((s) => s.isLoading == true && s.currentLevel == null),
          predicate<BadgeState>((s) =>
              s.isLoading == false &&
              s.currentLevel == null &&
              s.error == 'Exception: Badge error'),
        ]),
      );

      await cubit.refreshBadge(tDoctorId);
    });

    test('state copyWith preserves unchanged values when only isLoading changes', () {
      final state = BadgeState(currentLevel: BadgeLevel.bronze, isLoading: false);
      final updated = state.copyWith(isLoading: true);

      expect(updated.currentLevel, BadgeLevel.bronze);
      expect(updated.isLoading, isTrue);
      expect(updated.error, isNull);
    });

    test('state copyWith clears error when null is passed', () {
      final state = BadgeState(isLoading: false, error: 'Some error');
      final updated = state.copyWith(isLoading: true, error: null);

      expect(updated.error, isNull);
      expect(updated.isLoading, isTrue);
    });
  });
}
