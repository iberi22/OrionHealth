import 'package:equatable/equatable.dart';

class EmailTemplate extends Equatable {
  final String subject;
  final String body;

  const EmailTemplate({
    required this.subject,
    required this.body,
  });

  @override
  List<Object?> get props => [subject, body];

  static const confirmation = EmailTemplate(
    subject: "Confirmación de Cita: {{specialty}}",
    body: "Hola,\n\nTu cita con el Dr(a). {{doctor}} en la especialidad de {{specialty}} ha sido agendada para el {{date}} a las {{time}}.\n\nNotas: {{notes}}\n\nSaludos,\nEquipo OrionHealth",
  );

  static const reminder = EmailTemplate(
    subject: "Recordatorio de Cita: {{specialty}} - Mañana",
    body: "Hola,\n\nTe recordamos tu cita de mañana con el Dr(a). {{doctor}} ({{specialty}}) a las {{time}}.\n\nLugar: {{location}}\n\n¡Te esperamos!",
  );
}
