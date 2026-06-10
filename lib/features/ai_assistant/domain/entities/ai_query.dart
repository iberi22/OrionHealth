import 'package:equatable/equatable.dart';

class AiQuery extends Equatable {
  final String text;
  final DateTime timestamp;

  const AiQuery({
    required this.text,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, timestamp];
}
