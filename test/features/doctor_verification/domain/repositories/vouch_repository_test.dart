import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/vouch.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/vouch_repository.dart';

class MockVouchRepository extends Mock implements VouchRepository {}

void main() {
  late MockVouchRepository repository;

  setUp(() {
    repository = MockVouchRepository();
  });

  final tDate = DateTime(2023, 1, 1);
  final tVouch = Vouch(
    id: 'v1',
    vouchedBy: 'doc2',
    targetDoctor: 'doc1',
    category: 'Clinical',
    timestamp: tDate,
  );

  group('VouchRepository', () {
    test('getByDoctor returns vouches for a doctor', () async {
      when(() => repository.getByDoctor('doc1')).thenAnswer((_) async => [tVouch]);

      final results = await repository.getByDoctor('doc1');

      expect(results.length, 1);
      expect(results.first, equals(tVouch));
      verify(() => repository.getByDoctor('doc1')).called(1);
    });

    test('getByDoctor returns empty list when no vouches', () async {
      when(() => repository.getByDoctor('nonexistent')).thenAnswer((_) async => []);

      final results = await repository.getByDoctor('nonexistent');

      expect(results, isEmpty);
    });

    test('addVouch saves a vouch', () async {
      when(() => repository.addVouch(tVouch)).thenAnswer((_) async {});

      await repository.addVouch(tVouch);

      verify(() => repository.addVouch(tVouch)).called(1);
    });

    test('verifyVouchChain returns true when chain is valid', () async {
      when(
        () => repository.verifyVouchChain('doc1', depth: any(named: 'depth')),
      ).thenAnswer((_) async => true);

      final result = await repository.verifyVouchChain('doc1');

      expect(result, isTrue);
      verify(() => repository.verifyVouchChain('doc1', depth: 3)).called(1);
    });

    test('verifyVouchChain returns false when chain is invalid', () async {
      when(
        () => repository.verifyVouchChain('nonexistent', depth: any(named: 'depth')),
      ).thenAnswer((_) async => false);

      final result = await repository.verifyVouchChain('nonexistent');

      expect(result, isFalse);
    });

    test('verifyVouchChain respects custom depth', () async {
      when(
        () => repository.verifyVouchChain('doc1', depth: any(named: 'depth')),
      ).thenAnswer((_) async => true);

      final result = await repository.verifyVouchChain('doc1', depth: 5);

      expect(result, isTrue);
      verify(() => repository.verifyVouchChain('doc1', depth: 5)).called(1);
    });
  });
}
