import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:orionhealth_health/features/email_citas/application/email_citas_cubit.dart';
import 'package:orionhealth_health/features/email_citas/application/email_citas_state.dart';
import 'package:orionhealth_health/features/email_citas/domain/repositories/email_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class MockEmailRepo extends Mock implements EmailRepository {}
class MockAppointmentRepo extends Mock implements AppointmentRepository {}

void main() {
  late EmailCitasCubit cubit;
  late MockEmailRepo mockEmailRepo;
  late MockAppointmentRepo mockAppointmentRepo;

  setUp(() {
    mockEmailRepo = MockEmailRepo();
    mockAppointmentRepo = MockAppointmentRepo();
    cubit = EmailCitasCubit(mockEmailRepo, mockAppointmentRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('EmailCitasCubit', () {
    test('initial state is EmailCitasInitial', () {
      expect(cubit.state, isA<EmailCitasInitial>());
    });

    blocTest<EmailCitasCubit, EmailCitasState>(
      'emits EmailCitasConnected when Gmail connects successfully',
      build: () {
        when(() => mockEmailRepo.connectGmail()).thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) => cubit.connectGmail(),
      expect: () => [],
    );

    blocTest<EmailCitasCubit, EmailCitasState>(
      'emits EmailCitasError when Gmail fails',
      build: () {
        when(() => mockEmailRepo.connectGmail()).thenAnswer((_) async => false);
        return cubit;
      },
      act: (cubit) => cubit.connectGmail(),
      expect: () => [isA<EmailCitasError>()],
    );

    blocTest<EmailCitasCubit, EmailCitasState>(
      'emits EmailCitasError when syncing without connection',
      build: () => cubit,
      act: (cubit) => cubit.manualSync(),
      expect: () => [isA<EmailCitasError>()],
    );
  });
}
