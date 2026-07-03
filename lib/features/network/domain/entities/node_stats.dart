import 'package:equatable/equatable.dart';

class NodeStats extends Equatable {
  final String nodeId;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final Duration uptime;

  const NodeStats({
    required this.nodeId,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.uptime,
  });

  NodeStats copyWith({
    String? nodeId,
    double? cpuUsage,
    double? memoryUsage,
    double? diskUsage,
    Duration? uptime,
  }) {
    return NodeStats(
      nodeId: nodeId ?? this.nodeId,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      diskUsage: diskUsage ?? this.diskUsage,
      uptime: uptime ?? this.uptime,
    );
  }

  @override
  List<Object?> get props => [nodeId, cpuUsage, memoryUsage, diskUsage, uptime];
}
