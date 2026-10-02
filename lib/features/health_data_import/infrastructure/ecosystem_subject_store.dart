import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/services/ecosystem_import_service.dart';

@LazySingleton(as: EcosystemSubjectStore)
class LocalEcosystemSubjectStore implements EcosystemSubjectStore {
  static const prefsEntry = 'swal.health.v1.subject';

  @override
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(prefsEntry);

  Future<void> _pending = Future.value();

  @override
  Future<void> bind(String subject) {
    final operation = _pending.then((_) => _bind(subject));
    _pending = operation.then<void>((_) {}, onError: (Object _) {});
    return operation;
  }

  Future<void> _bind(String subject) async {
    if (!RegExp(r'^subj_[0-7][0-9A-HJKMNP-TV-Z]{25}$').hasMatch(subject)) {
      throw const FormatException('Invalid ecosystem subject.');
    }
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(prefsEntry);
    if (existing != null && existing != subject) {
      throw const FormatException(
        'Cannot replace the local ecosystem subject.',
      );
    }
    if (!await prefs.setString(prefsEntry, subject)) {
      throw StateError('Could not persist local subject.');
    }
  }
}
