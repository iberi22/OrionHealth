import 'package:equatable/equatable.dart';
import '../domain/entities/did.dart';
import '../domain/entities/verifiable_credential.dart';

abstract class SsiState extends Equatable {
  const SsiState();

  @override
  List<Object?> get props => [];
}

class SsiInitial extends SsiState {}

class SsiLoading extends SsiState {}

class SsiDidsLoaded extends SsiState {
  final List<Did> dids;
  const SsiDidsLoaded(this.dids);

  @override
  List<Object?> get props => [dids];
}

class SsiCredentialsLoaded extends SsiState {
  final List<VerifiableCredential> credentials;
  const SsiCredentialsLoaded(this.credentials);

  @override
  List<Object?> get props => [credentials];
}

class SsiError extends SsiState {
  final String message;
  const SsiError(this.message);

  @override
  List<Object?> get props => [message];
}
