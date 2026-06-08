import 'package:intl/intl.dart';
import '../entities/email_template.dart';
import '../../../appointments/domain/entities/appointment.dart';

class EmailService {
  String interpolate(String template, Appointment appointment) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    var result = template
        .replaceAll('{{doctor}}', appointment.doctorName)
        .replaceAll('{{specialty}}', appointment.specialty)
        .replaceAll('{{date}}', dateFormat.format(appointment.dateTime))
        .replaceAll('{{time}}', timeFormat.format(appointment.dateTime))
        .replaceAll('{{notes}}', appointment.notes ?? 'N/A');

    // Extract location from notes if possible, as it's common in our parser
    final locationMatch = RegExp(r'Clínica: (.*?). EPS:').firstMatch(appointment.notes ?? '');
    final location = locationMatch?.group(1) ?? 'N/A';
    result = result.replaceAll('{{location}}', location);

    return result;
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.\+]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<bool> sendEmail(String to, EmailTemplate template, Appointment appointment) async {
    if (!isValidEmail(to)) return false;

    // In a real implementation, this would call an API
    // For now, we simulate success/failure
    try {
      // Interpolate template with appointment data
      // final body = interpolate(template.body, appointment);
      // final subject = interpolate(template.subject, appointment);

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 100));

      // For testing purposes, we can assume it always succeeds unless it's a specific "fail" email
      if (to == "fail@example.com") return false;

      return true;
    } catch (e) {
      return false;
    }
  }
}
