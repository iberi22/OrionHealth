import 'package:equatable/equatable.dart';
import '../domain/entities/network_peer.dart';
import '../domain/entities/network_message.dart';

abstract class NetworkState extends Equatable {
  const NetworkState();

  @override
  List<Object?> get props => [];
}

class NetworkInitial extends NetworkState {}

class NetworkLoading extends NetworkState {}

class NetworkLoaded extends NetworkState {
  final List<NetworkPeer> peers;
  final List<NetworkMessage> messages;

  const NetworkLoaded({
    required this.peers,
    required this.messages,
  });

  @override
  List<Object?> get props => [peers, messages];
}

class NetworkError extends NetworkState {
  final String message;

  const NetworkError(this.message);

  @override
  List<Object?> get props => [message];
}
