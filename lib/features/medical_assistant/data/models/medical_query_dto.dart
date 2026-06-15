import '../../domain/entities/medical_query.dart';

class MedicalQueryDto {
  final String id;
  final String question;
  final Map<String, dynamic>? context;

  const MedicalQueryDto({required this.id, required this.question, this.context});

  factory MedicalQueryDto.fromEntity(MedicalQuery q) => MedicalQueryDto(
    id: q.id, question: q.question, context: q.userContext,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'question': question, if (context != null) 'context': context,
  };

  factory MedicalQueryDto.fromJson(Map<String, dynamic> j) => MedicalQueryDto(
    id: j['id'] as String, question: j['question'] as String,
    context: j['context'] as Map<String, dynamic>?,
  );
}
