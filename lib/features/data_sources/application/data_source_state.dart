import 'package:equatable/equatable.dart';
import '../domain/entities/data_source_entity.dart';

abstract class DataSourceState extends Equatable {
  const DataSourceState();

  @override
  List<Object?> get props => [];
}

class DataSourceInitial extends DataSourceState {}

class DataSourceLoading extends DataSourceState {}

class DataSourceLoaded extends DataSourceState {
  final List<DataSource> dataSources;

  const DataSourceLoaded(this.dataSources);

  @override
  List<Object?> get props => [dataSources];
}

class DataSourceError extends DataSourceState {
  final String message;

  const DataSourceError(this.message);

  @override
  List<Object?> get props => [message];
}
