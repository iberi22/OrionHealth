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
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = IsarAppointmentRepository(mockIsar);

    when(() => mockIsar.appointments).thenReturn(mockCollection);
  });

  group('IsarAppointmentRepository', () {
    test('saveAppointment puts appointment in collection', () async {
      final appointment = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveAppointment(appointment);

      verify(() => mockCollection.put(appointment)).called(1);
    });

    test('deleteAppointment deletes from collection', () async {
      const id = 1;
      when(() => mockCollection.delete(any())).thenAnswer((_) async => true);

      await repository.deleteAppointment(id);

      verify(() => mockCollection.delete(id)).called(1);
    });
  });
}
