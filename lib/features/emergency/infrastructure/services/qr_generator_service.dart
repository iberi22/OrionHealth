/// FEAT-022: QR code generator for Medical ID
///
/// Encodes a compact summary of the Medical ID as a QR-compatible string.
/// Format: `ORIONMED:v1;NAME=...;AGE=...;BT=...;AL=...;ICE=...`
///
/// Designed to be human-readable if QR scan fails.
library;

import '../../domain/entities/medical_id.dart';

class QrGeneratorService {
  /// Generates a compact QR string for emergency sharing.
  /// Maximum length ~250 chars (QR-Limit for v4 is 4296 but we keep readable).
  String generate(MedicalIdEntity id) {
    final buf = StringBuffer('ORIONMED:v1');
    buf.write(';NAME=${_truncate(id.fullName, 30)}');
    buf.write(';AGE=${id.age}');
    buf.write(';BT=${id.bloodType.code}');
    if (id.allergies.isNotEmpty) {
      buf.write(';AL=${_truncate(id.allergies.join("|"), 50)}');
    }
    if (id.currentMedications.isNotEmpty) {
      buf.write(';MED=${_truncate(id.currentMedications.join("|"), 50)}');
    }
    buf.write(';ICE=${_truncate(id.primaryContact.name, 25)}');
    buf.write(';PHONE=${_truncate(id.primaryContact.phone, 15)}');
    if (id.organDonor == OrganDonor.yes) buf.write(';OD=YES');
    if (id.dnrDirective != null) buf.write(';DNR=YES');
    return buf.toString();
  }

  String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max - 1)}…';
}
