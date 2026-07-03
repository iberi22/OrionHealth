import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/data/datasources/appointment_local_datasource.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionAppointment extends IsarCollection<Appointment> {}
class MockIsarCollection extends Mock implements IsarCollectionAppointment {}

class FakeAppointment extends Fake implements Appointment {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late AppointmentLocalDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(FakeAppointment());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    dataSource = AppointmentLocalDataSource(mockIsar);

    when(() => mockIsar.appointments).thenReturn(mockCollection);
  });

  group('AppointmentLocalDataSource', () {
    final tAppointment = Appointment(
      id: 1,
      doctorName: 'Dr. Smith',
      specialty: 'Cardiology',
      dateTime: DateTime(2023, 10, 10),
      status: AppointmentStatus.upcoming,
    );

    test('saveAppointment should put appointment in Isar', () async {
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await dataSource.saveAppointment(tAppointment);

      verify(() => mockCollection.put(tAppointment)).called(1);
    });

    test('deleteAppointment should delete appointment from Isar', () async {
      const tId = 1;
      when(() => mockCollection.delete(any())).thenAnswer((_) async => true);

      await dataSource.deleteAppointment(tId);

      verify(() => mockCollection.delete(tId)).called(1);
    });

    test('getAppointmentById should return appointment from Isar', () async {
      const tId = 1;
      when(() => mockCollection.get(any())).thenAnswer((_) async => tAppointment);

      final result = await dataSource.getAppointmentById(tId);

      expect(result, tAppointment);
      verify(() => mockCollection.get(tId)).called(1);
    });
  });
}
