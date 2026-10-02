import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../domain/repositories/workout_repository.dart';
import '../domain/services/workout_fhir_mapper.dart';

@lazySingleton
class WorkoutFhirExportService {
  final WorkoutRepository _repository;
  WorkoutFhirExportService(this._repository);

  /// Augments the wallet's existing export without coupling it to app storage.
  Future<String> appendToBundle(String walletBundle) async {
    final bundle = jsonDecode(walletBundle) as Map<String, dynamic>;
    final entries = List<dynamic>.from(bundle['entry'] as List? ?? []);
    for (final session in await _repository.getAllSessions()) {
      entries.add({'resource': workoutToObservation(session)});
    }
    bundle['entry'] = entries;
    if (bundle.containsKey('total')) bundle['total'] = entries.length;
    return jsonEncode(bundle);
  }
}
