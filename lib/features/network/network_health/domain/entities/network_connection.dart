import 'package:equatable/equatable.dart';

class NetworkConnection extends Equatable {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final double latency;
  final double bandwidth;
  final bool isEncrypted;

  const NetworkConnection({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.latency,
    required this.bandwidth,
    required this.isEncrypted,
  });

  NetworkConnection copyWith({
    String? id,
    String? sourceNodeId,
    String? targetNodeId,
    double? latency,
    double? bandwidth,
    bool? isEncrypted,
  }) {
    return NetworkConnection(
      id: id ?? this.id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      latency: latency ?? this.latency,
      bandwidth: bandwidth ?? this.bandwidth,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  @override
  List<Object?> get props => [id, sourceNodeId, targetNodeId, latency, bandwidth, isEncrypted];
}
