import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/second_opinion_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/second_opinion.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/second_opinion_repository.dart';

class MockSecondOpinionRepository extends Mock implements SecondOpinionRepository {}

class SecondOpinionRequestFake extends Fake implements SecondOpinionRequest {}

void main() {
  late SecondOpinionCubit cubit;
  late MockSecondOpinionRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(SecondOpinionRequestFake());
  });

  setUp(() {
    mockRepo = MockSecondOpinionRepository();
    cubit = SecondOpinionCubit(mockRepo);
  });

  final tPatientId = 'p1';
  final tRequestId = 'req1';
  final tDate = DateTime(2023, 1, 1);
  final tRequest = SecondOpinionRequest(
    id: tRequestId,
    patientId: tPatientId,
    symptoms: 'Heaviness in chest',
    createdAt: tDate,
  );
  final tResponse = SecondOpinionResponse(
    id: 'res1',
    requestId: tRequestId,
    reviewerDoctorId: 'doc2',
    recommendation: 'Recommended ECG',
    confidence: 0.9,
    respondedAt: tDate,
  );

  group('SecondOpinionCubit', () {
    test('loadRequests emits requests', () async {
      when(() => mockRepo.getRequestsForPatient(tPatientId)).thenAnswer((_) async => [tRequest]);

      await cubit.loadRequests(tPatientId);

      expect(cubit.state.requests, [tRequest]);
    });

    test('loadResponses updates responses map', () async {
      when(() => mockRepo.getResponsesForRequest(tRequestId)).thenAnswer((_) async => [tResponse]);

      await cubit.loadResponses(tRequestId);

      expect(cubit.state.responses[tRequestId], [tResponse]);
    });

    test('submitRequest saves and reloads', () async {
      when(() => mockRepo.saveRequest(any())).thenAnswer((_) async => {});
      when(() => mockRepo.getRequestsForPatient(tPatientId)).thenAnswer((_) async => [tRequest]);

      await cubit.submitRequest(tRequest);

      verify(() => mockRepo.saveRequest(tRequest)).called(1);
      expect(cubit.state.requests, [tRequest]);
    });
  });
}
