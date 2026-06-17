import 'package:device_calendar/device_calendar.dart';
import 'package:injectable/injectable.dart';

@module
abstract class CalendarModule {
  @lazySingleton
  DeviceCalendarPlugin get deviceCalendarPlugin => DeviceCalendarPlugin();
}
