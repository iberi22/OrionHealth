import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/repositories/email_repository.dart';
import '../../appointments/domain/repositories/appointment_repository.dart';
import 'email_citas_state.dart';

@injectable
class EmailCitasCubit extends Cubit<EmailCitasState> {
  final EmailRepository _emailRepository;
  final AppointmentRepository _appointmentRepository;

  EmailCitasCubit(
    this._emailRepository,
    this._appointmentRepository,
  ) : super(EmailCitasInitial());

  String? _pendingProvider;
  String? _lastSuccessfulCode;

  Future<void> connectGmail() async {
    _pendingProvider = 'Gmail';
    final success = await _emailRepository.connectGmail();
    if (!success) {
      emit(const EmailCitasError('No se pudo abrir la página de conexión de Gmail'));
    }
  }

  Future<void> connectOutlook() async {
    _pendingProvider = 'Outlook';
    final success = await _emailRepository.connectOutlook();
    if (!success) {
      emit(const EmailCitasError('No se pudo abrir la página de conexión de Outlook'));
    }
  }

  Future<void> handleOAuthRedirect(Uri uri) async {
    if (uri.scheme == 'orionhealth' && uri.host == 'oauth2redirect') {
      final code = uri.queryParameters['code'];
      if (code != null && _pendingProvider != null) {
        _lastSuccessfulCode = code;
        final currentState = state is EmailCitasConnected
            ? state as EmailCitasConnected
            : const EmailCitasConnected();

        EmailCitasConnected newState;
        if (_pendingProvider == 'Gmail') {
          newState = currentState.copyWith(isGmailConnected: true);
        } else {
          newState = currentState.copyWith(isOutlookConnected: true);
        }
        emit(newState);

        await syncAppointments(code);
      }
    }
  }

  Future<void> manualSync() async {
    if (_lastSuccessfulCode != null && _pendingProvider != null) {
      await syncAppointments(_lastSuccessfulCode!);
    } else {
      emit(const EmailCitasError('Primero debes conectar una cuenta'));
    }
  }

  Future<void> syncAppointments(String code) async {
    if (_pendingProvider == null) return;

    final currentState = state is EmailCitasConnected
        ? state as EmailCitasConnected
        : const EmailCitasConnected();

    emit(EmailCitasLoading());
    try {
      final appointments = await _emailRepository.fetchParsedAppointments(
        _pendingProvider!,
        code,
      );

      for (var app in appointments) {
        await _appointmentRepository.saveAppointment(app);
        await _emailRepository.syncToNativeCalendar(app);
      }

      emit(EmailCitasSyncSuccess());
      // Restore connection state after success
      emit(currentState);
    } catch (e) {
      emit(EmailCitasError(e.toString()));
      emit(currentState);
    }
  }
}
