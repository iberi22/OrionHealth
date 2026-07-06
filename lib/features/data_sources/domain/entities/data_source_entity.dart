import 'package:equatable/equatable.dart';

enum DataSourceType {
  sensor,
  file,
  healthConnect,
}

enum DataSourceStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class DataSource extends Equatable {
  final String id;
  final String name;
  final String description;
  final DataSourceType type;
  final DataSourceStatus status;
  final DateTime? lastSync;
  final String? errorMessage;

  const DataSource({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    this.lastSync,
    this.errorMessage,
  });

  DataSource copyWith({
    String? name,
    String? description,
    DataSourceType? type,
    DataSourceStatus? status,
    DateTime? lastSync,
    String? errorMessage,
  }) {
    return DataSource(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      lastSync: lastSync ?? this.lastSync,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [id, name, description, type, status, lastSync, errorMessage];
}
