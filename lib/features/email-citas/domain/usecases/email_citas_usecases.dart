import 'package:injectable/injectable.dart';
import '../repositories/email_repository.dart';
import '../../../appointments/domain/entities/appointment.dart';

@injectable
class ConnectEmailProviderUseCase {
  final EmailRepository _repository;
  ConnectEmailProviderUseCase(this._repository);

  Future<bool> call(String provider) async {
    if (provider == 'Gmail') {
      return _repository.connectGmail();
    } else if (provider == 'Outlook') {
      return _repository.connectOutlook();
    }
    return false;
  }
}

@injectable
class SyncEmailAppointmentsUseCase {
  final EmailRepository _repository;
  SyncEmailAppointmentsUseCase(this._repository);

  Future<List<Appointment>> call(String provider, String code) {
    return _repository.fetchParsedAppointments(provider, code);
  }
}
