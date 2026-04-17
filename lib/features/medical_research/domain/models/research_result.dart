import 'package:equatable/equatable.dart';

class ResearchResult extends Equatable {
  final String title;
  final String content;
  final String source;
  final String url;
  final double confidence;
  final Map<String, dynamic> metadata;

  const ResearchResult({
    required this.title,
    required this.content,
    required this.source,
    required this.url,
    this.confidence = 0.0,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [title, source, url];
}
