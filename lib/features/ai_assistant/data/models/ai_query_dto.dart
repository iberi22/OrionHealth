import '../../domain/entities/ai_query.dart';

/// Data transfer object for [AiQuery].
class AiQueryDto {
  final String text;
  final Map<String, dynamic>? metadata;

  const AiQueryDto({required this.text, this.metadata});

  factory AiQueryDto.fromEntity(AiQuery query) => AiQueryDto(
        text: query.text,
        metadata: query.metadata,
      );

  AiQuery toEntity() => AiQuery(text: text, metadata: metadata);

  Map<String, dynamic> toJson() => {
        'text': text,
        if (metadata != null) 'metadata': metadata,
      };

  factory AiQueryDto.fromJson(Map<String, dynamic> json) => AiQueryDto(
        text: json['text'] as String,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
}
