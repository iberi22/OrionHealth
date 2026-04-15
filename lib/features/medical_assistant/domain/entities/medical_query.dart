import 'package:equatable/equatable.dart';

/// Represents a user's medical query or question
class MedicalQuery extends Equatable {
  final String id;
  final String question;
  final DateTime timestamp;
  final String? userId;
  final List<String> contextTags;
  final Map<String, dynamic>? metadata;

  const MedicalQuery({
    required this.id,
    required this.question,
    required this.timestamp,
    this.userId,
    this.contextTags = const [],
    this.metadata,
  });

  @override
  List<Object?> get props => [id, question, timestamp, userId, contextTags];

  MedicalQuery copyWith({
    String? id,
    String? question,
    DateTime? timestamp,
    String? userId,
    List<String>? contextTags,
    Map<String, dynamic>? metadata,
  }) {
    return MedicalQuery(
      id: id ?? this.id,
      question: question ?? this.question,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      contextTags: contextTags ?? this.contextTags,
      metadata: metadata ?? this.metadata,
    );
  }
}
