import 'package:equatable/equatable.dart';

class ResearchQuery extends Equatable {
  final String text;
  final List<String>? sources;
  final DateTime? fromDate;

  const ResearchQuery({
    required this.text,
    this.sources,
    this.fromDate,
  });

  @override
  List<Object?> get props => [text, sources, fromDate];
}
