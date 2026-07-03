import 'package:injectable/injectable.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_source.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../infrastructure/datasources/calendar_api_datasource.dart';

@LazySingleton(as: CalendarRepository)
class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarApiDatasource _apiDataSource;

  CalendarRepositoryImpl(this._apiDataSource);

  @override
  Future<bool> hasPermissions() {
    return _apiDataSource.hasPermissions();
  }

  @override
  Future<bool> requestPermissions() {
    return _apiDataSource.requestPermissions();
  }

  @override
  Future<List<CalendarSource>> getCalendarSources() {
    return _apiDataSource.getCalendarSources();
  }

  @override
  Future<List<CalendarEvent>> fetchMedicalEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _apiDataSource.fetchMedicalEvents(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
