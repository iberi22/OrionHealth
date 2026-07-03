import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/data/datasources/appointment_local_datasource.dart';
import 'package:orionhealth_health/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class MockAppointmentLocalDataSource extends Mock implements AppointmentLocalDataSource {}

class FakeAppointment extends Fake implements Appointment {}

void main() {
  late MockAppointmentLocalDataSource mockDataSource;
  late AppointmentRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeAppointment());
  });

  setUp(() {
    mockDataSource = MockAppointmentLocalDataSource();
    repository = AppointmentRepositoryImpl(mockDataSource);
  });

  group('AppointmentRepositoryImpl', () {
    final tAppointment = Appointment(
      id: 1,
      doctorName: 'Dr. Smith',
      specialty: 'Cardiology',
      dateTime: DateTime(2023, 10, 10),
      status: AppointmentStatus.upcoming,
    );

    test('getAllAppointments should call getAppointments on data source', () async {
      when(() => mockDataSource.getAppointments()).thenAnswer((_) async => [tAppointment]);

      final result = await repository.getAllAppointments();

      expect(result, [tAppointment]);
      verify(() => mockDataSource.getAppointments()).called(1);
    });

    test('saveAppointment should call saveAppointment on data source', () async {
      when(() => mockDataSource.saveAppointment(any())).thenAnswer((_) async => {});

      await repository.saveAppointment(tAppointment);

      verify(() => mockDataSource.saveAppointment(tAppointment)).called(1);
    });

    test('deleteAppointment should call deleteAppointment on data source', () async {
      const tId = 1;
      when(() => mockDataSource.deleteAppointment(any())).thenAnswer((_) async => {});

      await repository.deleteAppointment(tId);

      verify(() => mockDataSource.deleteAppointment(tId)).called(1);
    });
  });
}
