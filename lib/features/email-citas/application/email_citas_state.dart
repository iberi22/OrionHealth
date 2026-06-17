import 'package:equatable/equatable.dart';

abstract class EmailCitasState extends Equatable {
  const EmailCitasState();

  @override
  List<Object?> get props => [];
}

class EmailCitasInitial extends EmailCitasState {
  const EmailCitasInitial();
}

class EmailCitasLoading extends EmailCitasState {
  const EmailCitasLoading();
}

class EmailCitasConnected extends EmailCitasState {
  final bool isGmailConnected;
  final bool isOutlookConnected;

  const EmailCitasConnected({
    this.isGmailConnected = false,
    this.isOutlookConnected = false,
  });

  @override
  List<Object?> get props => [isGmailConnected, isOutlookConnected];

  EmailCitasConnected copyWith({
    bool? isGmailConnected,
    bool? isOutlookConnected,
  }) {
    return EmailCitasConnected(
      isGmailConnected: isGmailConnected ?? this.isGmailConnected,
      isOutlookConnected: isOutlookConnected ?? this.isOutlookConnected,
    );
  }
}

class EmailCitasSyncSuccess extends EmailCitasState {
  const EmailCitasSyncSuccess();
}

class EmailCitasError extends EmailCitasState {
  final String message;

  const EmailCitasError(this.message);

  @override
  List<Object?> get props => [message];
}
