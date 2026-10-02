import 'dart:convert';
import 'package:health_contract/health_contract.dart' as contract;
import 'package:injectable/injectable.dart';

abstract class EcosystemSubjectStore {
  Future<String?> read();
  Future<void> bind(String subject);
}

abstract class EcosystemRecordStore {
  /// Atomically saves the entire batch, replacing identical record IDs.
  Future<void> save(List<Map<String, dynamic>> records);
  Future<String?> latestDataset();
}

class EcosystemImportPreview {
  final List<Map<String, dynamic>> records;
  final String? subject;
  final bool requiresSubjectBinding;
  const EcosystemImportPreview(
    this.records,
    this.subject,
    this.requiresSubjectBinding,
  );
}

@lazySingleton
class EcosystemImportService {
  final EcosystemSubjectStore _subjects;
  final EcosystemRecordStore _records;
  final DateTime Function() _now;
  Future<void> _pending = Future.value();

  EcosystemImportService(this._subjects, this._records) : _now = DateTime.now;
  EcosystemImportService.withClock(this._subjects, this._records, this._now);

  Future<EcosystemImportPreview> preview(
    List<Map<String, dynamic>> records,
  ) async {
    // Snapshot input to prevent callers changing confirmed data after preview.
    final snapshot = (jsonDecode(jsonEncode(records)) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final subjects = <String>{};
    for (final record in snapshot) {
      contract.Envelope.fromJson(record);
      subjects.add(record['subject'] as String);
      final data = record['data'] as Map<String, dynamic>;
      if (record['schema'] == 'swal.health/v1/workout-session' &&
          parseEcosystemTimestamp(
            data['endedAt'] as String,
          ).isBefore(parseEcosystemTimestamp(data['startedAt'] as String))) {
        throw const FormatException('Workout ends before it starts.');
      }
      if (record['schema'] == 'swal.health/v1/dietary-profile' &&
          !parseEcosystemTimestamp(
            data['expiresAt'] as String,
          ).isAfter(_now())) {
        throw const FormatException('Dietary profile has expired.');
      }
    }
    if (subjects.length > 1) {
      throw const FormatException('Records belong to different subjects.');
    }
    final subject = subjects.isEmpty ? null : subjects.single;
    final local = await _subjects.read();
    if (local != null && subject != null && local != subject) {
      throw const FormatException(
        'Records belong to a different local subject.',
      );
    }
    return EcosystemImportPreview(
      List.unmodifiable(
        snapshot.map((record) => _freeze(record) as Map<String, dynamic>),
      ),
      subject,
      local == null && subject != null,
    );
  }

  Future<int> save(
    EcosystemImportPreview preview, {
    required bool consent,
    bool bindSubject = false,
  }) async {
    if (!consent) {
      throw const FormatException('Import requires explicit consent.');
    }
    final previous = _pending;
    final completer = _saveAfter(previous, preview, bindSubject);
    _pending = completer.then<void>((_) {}, onError: (Object _) {});
    return completer;
  }

  Future<int> _saveAfter(
    Future<void> previous,
    EcosystemImportPreview selected,
    bool bindSubject,
  ) async {
    await previous;
    final checked = await preview(selected.records);
    if (checked.requiresSubjectBinding && !bindSubject) {
      throw const FormatException(
        'Confirm that these records belong to you before binding the subject.',
      );
    }
    // Bind first: a failed disk write cannot allow a subsequent foreign batch.
    if (checked.requiresSubjectBinding) await _subjects.bind(checked.subject!);
    await _records.save(checked.records);
    return checked.records.length;
  }
}

Object? _freeze(Object? value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.unmodifiable(
      value.map((key, item) => MapEntry(key, _freeze(item))),
    );
  }
  if (value is List) return List<Object?>.unmodifiable(value.map(_freeze));
  return value;
}

/// RFC3339 accepts lowercase separators; Dart's parser requires uppercase T.
DateTime parseEcosystemTimestamp(String value) =>
    DateTime.parse(value.replaceFirst('t', 'T').replaceFirst('z', 'Z'));
