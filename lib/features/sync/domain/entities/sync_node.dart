import 'package:equatable/equatable.dart';

/// Represents a discovered OrionHealth node on the local network.
class SyncNode extends Equatable {
  final String id;
  final String name;
  final String host;
  final int port;

  const SyncNode({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
  });

  @override
  List<Object?> get props => [id, name, host, port];
}
