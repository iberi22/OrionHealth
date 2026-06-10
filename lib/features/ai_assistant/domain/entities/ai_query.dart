import 'package:equatable/equatable.dart';

/// Represents a query sent to the AI Assistant
class AiQuery extends Equatable {
  final String text;
  final Map<String, dynamic>? metadata;

  const AiQuery({
    required this.text,
    this.metadata,
  });

  @override
  List<Object?> get props => [text, metadata];

  AiQuery copyWith({
    String? text,
    Map<String, dynamic>? metadata,
  }) {
    return AiQuery(
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
    );
  }
}
