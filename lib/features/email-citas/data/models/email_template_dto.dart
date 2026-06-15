import '../../domain/entities/email_template.dart';

class EmailTemplateDto {
  final String id;
  final String subject;
  final String body;
  final Map<String, String> variables;

  const EmailTemplateDto({
    required this.id, required this.subject, required this.body,
    this.variables = const {},
  });

  factory EmailTemplateDto.fromEntity(EmailTemplate e) => EmailTemplateDto(
    id: e.id, subject: e.subject, body: e.body,
    variables: e.variables ?? {},
  );

  EmailTemplate toEntity() => EmailTemplate(
    id: id, subject: subject, body: body, variables: variables,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'subject': subject, 'body': body, 'variables': variables,
  };

  factory EmailTemplateDto.fromJson(Map<String, dynamic> j) => EmailTemplateDto(
    id: j['id'] as String, subject: j['subject'] as String,
    body: j['body'] as String,
    variables: (j['variables'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as String)) ?? {},
  );
}
