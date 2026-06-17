import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/vouch_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/vouch.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/vouch_repository.dart';

class MockVouchRepository extends Mock implements VouchRepository {}

class VouchFake extends Fake implements Vouch {}

void main() {
  late VouchCubit vouchCubit;
  late MockVouchRepository mockVouchRepo;

  setUpAll(() {
    registerFallbackValue(VouchFake());
  });

  setUp(() {
    mockVouchRepo = MockVouchRepository();
    vouchCubit = VouchCubit(mockVouchRepo);
  });

  final tDoctorId = 'doc1';
  final tDate = DateTime(2023, 1, 1);
  final tVouch = Vouch(
    id: 'v1',
    vouchedBy: 'doc2',
    targetDoctor: tDoctorId,
    category: 'Clinical',
    timestamp: tDate,
  );

  group('VouchCubit', () {
    test('initial state should be empty', () {
      expect(vouchCubit.state.vouches, isEmpty);
      expect(vouchCubit.state.isLoading, isFalse);
    });

    test('loadVouches emits loading and then vouches', () async {
      when(() => mockVouchRepo.getByDoctor(tDoctorId)).thenAnswer((_) async => [tVouch]);

      final future = vouchCubit.loadVouches(tDoctorId);

      expect(vouchCubit.state.isLoading, isTrue);

      await future;

      expect(vouchCubit.state.isLoading, isFalse);
      expect(vouchCubit.state.vouches, [tVouch]);
    });

    test('addVouch saves and reloads vouches', () async {
      when(() => mockVouchRepo.addVouch(any())).thenAnswer((_) async => {});
      when(() => mockVouchRepo.getByDoctor(tDoctorId)).thenAnswer((_) async => [tVouch]);

      await vouchCubit.addVouch(tVouch);

      verify(() => mockVouchRepo.addVouch(tVouch)).called(1);
      expect(vouchCubit.state.vouches, [tVouch]);
    });
  });
}
