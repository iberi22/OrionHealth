import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/infrastructure/repositories/isar_appointment_repository.dart';

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
  late IsarAppointmentRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeAppointment());
    registerFallbackValue(<Appointment>[]);
    registerFallbackValue(AppointmentStatus.upcoming);
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = IsarAppointmentRepository(mockIsar);

    // Mocking the generated extension property
    when(() => mockIsar.appointments).thenReturn(mockCollection);
  });

  group('IsarAppointmentRepository Mocked', () {
    test('saveAppointment calls put', () async {
      final appointment = Appointment(doctorName: 'Dr. House', specialty: 'Diagnostics', dateTime: DateTime.now(), status: AppointmentStatus.upcoming);
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveAppointment(appointment);

      verify(() => mockCollection.put(appointment)).called(1);
    });

    test('deleteAppointment calls delete', () async {
      when(() => mockCollection.delete(any())).thenAnswer((_) async => true);

      await repository.deleteAppointment(1);

      verify(() => mockCollection.delete(1)).called(1);
    });

    // Note: getAllAppointments is harder to test without native library because .where() returns a QueryBuilder
    // and its extensions are not easily mockable without the underlying native _query getter.
    // For now, we focus on the actions that use put/delete.
  });
}
