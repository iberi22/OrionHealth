// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'email_citas_event.dart';
import '../email_citas_state.dart';
import '../../domain/repositories/email_repository.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';
import '../../domain/usecases/email_citas_usecases.dart';

@injectable
class EmailCitasBloc extends Bloc<EmailCitasEvent, EmailCitasState> {
  final ConnectEmailProviderUseCase _connectEmailProviderUseCase;
  final SyncEmailAppointmentsUseCase _syncEmailAppointmentsUseCase;
  final EmailRepository _emailRepository;
  final AppointmentRepository _appointmentRepository;

  EmailCitasBloc(
    this._connectEmailProviderUseCase,
    this._syncEmailAppointmentsUseCase,
    this._emailRepository,
    this._appointmentRepository,
  ) : super(EmailCitasInitial()) {
    on<ConnectGmail>(_onConnectGmail);
    on<ConnectOutlook>(_onConnectOutlook);
    on<HandleOAuthRedirect>(_onHandleOAuthRedirect);
    on<ManualSync>(_onManualSync);
    on<SyncAppointments>(_onSyncAppointments);
  }

  String? _pendingProvider;
  String? _lastSuccessfulCode;

  Future<void> _onConnectGmail(
    ConnectGmail event,
    Emitter<EmailCitasState> emit,
  ) async {
    _pendingProvider = 'Gmail';
    final success = await _connectEmailProviderUseCase('Gmail');
    if (!success) {
      emit(const EmailCitasError('No se pudo abrir la página de conexión de Gmail'));
    }
  }

  Future<void> _onConnectOutlook(
    ConnectOutlook event,
    Emitter<EmailCitasState> emit,
  ) async {
    _pendingProvider = 'Outlook';
    final success = await _connectEmailProviderUseCase('Outlook');
    if (!success) {
      emit(const EmailCitasError('No se pudo abrir la página de conexión de Outlook'));
    }
  }

  Future<void> _onHandleOAuthRedirect(
    HandleOAuthRedirect event,
    Emitter<EmailCitasState> emit,
  ) async {
    final uri = event.uri;
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

        add(SyncAppointments(code));
      }
    }
  }

  Future<void> _onManualSync(
    ManualSync event,
    Emitter<EmailCitasState> emit,
  ) async {
    if (_lastSuccessfulCode != null && _pendingProvider != null) {
      add(SyncAppointments(_lastSuccessfulCode!));
    } else {
      emit(const EmailCitasError('Primero debes conectar una cuenta'));
    }
  }

  Future<void> _onSyncAppointments(
    SyncAppointments event,
    Emitter<EmailCitasState> emit,
  ) async {
    if (_pendingProvider == null) return;

    final currentState = state is EmailCitasConnected
        ? state as EmailCitasConnected
        : const EmailCitasConnected();

    emit(EmailCitasLoading());
    try {
      final appointments = await _syncEmailAppointmentsUseCase(
        _pendingProvider!,
        event.code,
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
