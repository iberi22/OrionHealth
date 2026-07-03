import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/entities/calendar_appointment.dart';
import '../domain/entities/calendar_import_state.dart';
import '../domain/repositories/calendar_import_repository.dart';
import '../domain/usecases/import_calendar_usecase.dart';

export '../domain/entities/calendar_import_state.dart';

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

@injectable
class CalendarImportCubit extends Cubit<CalendarImportState> {
  final CalendarImportRepository _calendarRepository;
  final ImportCalendarUseCase _importCalendarUseCase;

  CalendarImportCubit(
    this._calendarRepository,
    this._importCalendarUseCase,
  ) : super(const CalendarImportInitial());

  Future<void> scanCalendar() async {
    emit(const CalendarImportLoading());
    try {
      final hasPermission = await _calendarRepository.hasPermissions();
      if (!hasPermission) {
        final granted = await _calendarRepository.requestPermissions();
        if (!granted) {
          emit(const CalendarImportPermissionDenied());
          return;
        }
      }

      // Fetch as CalendarAppointment domain entities
      final appointments = await _calendarRepository.fetchMedicalAppointments();
      emit(CalendarImportLoaded(appointments));
    } catch (e) {
      emit(CalendarImportError(e.toString()));
    }
  }

  Future<void> importAppointments(List<CalendarAppointment> appointments) async {
    emit(const CalendarImportLoading());
    try {
      final result = await _importCalendarUseCase.execute(
        ImportCalendarParams(appointments: appointments),
      );
      emit(CalendarImportSuccess(result.importedCount));
    } catch (e) {
      emit(CalendarImportError(e.toString()));
    }
  }
}
