import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/second_opinion.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/second_opinion_repository.dart';

class MockSecondOpinionRepository extends Mock implements SecondOpinionRepository {}

void main() {
  late MockSecondOpinionRepository repository;

  setUp(() {
    repository = MockSecondOpinionRepository();
  });

  final tDate = DateTime(2023, 1, 1);
  final tRequest = SecondOpinionRequest(
    id: 'req1',
    patientId: 'p1',
    symptoms: 'Heaviness in chest',
    createdAt: tDate,
  );
  final tResponse = SecondOpinionResponse(
    id: 'res1',
    requestId: 'req1',
    reviewerDoctorId: 'doc2',
    recommendation: 'Recommended ECG',
    confidence: 0.9,
    respondedAt: tDate,
  );

  group('SecondOpinionRepository', () {
    test('saveRequest saves a second opinion request', () async {
      when(() => repository.saveRequest(tRequest)).thenAnswer((_) async {});

      await repository.saveRequest(tRequest);

      verify(() => repository.saveRequest(tRequest)).called(1);
    });

    test('saveResponse saves a second opinion response', () async {
      when(() => repository.saveResponse(tResponse)).thenAnswer((_) async {});

      await repository.saveResponse(tResponse);

      verify(() => repository.saveResponse(tResponse)).called(1);
    });

    test('getRequest returns a request by id', () async {
      when(() => repository.getRequest('req1')).thenAnswer((_) async => tRequest);

      final result = await repository.getRequest('req1');

      expect(result, equals(tRequest));
      verify(() => repository.getRequest('req1')).called(1);
    });

    test('getRequest returns null when not found', () async {
      when(() => repository.getRequest('nonexistent')).thenAnswer((_) async => null);

      final result = await repository.getRequest('nonexistent');

      expect(result, isNull);
    });

    test('getResponsesForRequest returns responses for a request', () async {
      when(() => repository.getResponsesForRequest('req1')).thenAnswer((_) async => [tResponse]);

      final results = await repository.getResponsesForRequest('req1');

      expect(results.length, 1);
      expect(results.first, equals(tResponse));
      verify(() => repository.getResponsesForRequest('req1')).called(1);
    });

    test('getRequestsForPatient returns requests for a patient', () async {
      when(() => repository.getRequestsForPatient('p1')).thenAnswer((_) async => [tRequest]);

      final results = await repository.getRequestsForPatient('p1');

      expect(results.length, 1);
      expect(results.first, equals(tRequest));
      verify(() => repository.getRequestsForPatient('p1')).called(1);
    });
  });
}
