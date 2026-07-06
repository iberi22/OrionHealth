import 'package:equatable/equatable.dart';

enum NetworkStatus {
  healthy,
  congested,
  unstable,
  down,
}

class NetworkHealth extends Equatable {
  final NetworkStatus status;
  final int activeNodes;
  final int totalNodes;
  final double averageLatency;
  final double uptimePercentage;

  const NetworkHealth({
    required this.status,
    required this.activeNodes,
    required this.totalNodes,
    required this.averageLatency,
    required this.uptimePercentage,
  });

  factory NetworkHealth.fromJson(Map<String, dynamic> json) {
    return NetworkHealth(
      status: NetworkStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NetworkStatus.healthy,
      ),
      activeNodes: json['activeNodes'] as int,
      totalNodes: json['totalNodes'] as int,
      averageLatency: (json['averageLatency'] as num).toDouble(),
      uptimePercentage: (json['uptimePercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'activeNodes': activeNodes,
      'totalNodes': totalNodes,
      'averageLatency': averageLatency,
      'uptimePercentage': uptimePercentage,
    };
  }

  NetworkHealth copyWith({
    NetworkStatus? status,
    int? activeNodes,
    int? totalNodes,
    double? averageLatency,
    double? uptimePercentage,
  }) {
    return NetworkHealth(
      status: status ?? this.status,
      activeNodes: activeNodes ?? this.activeNodes,
      totalNodes: totalNodes ?? this.totalNodes,
      averageLatency: averageLatency ?? this.averageLatency,
      uptimePercentage: uptimePercentage ?? this.uptimePercentage,
    );
  }

  @override
  List<Object?> get props => [status, activeNodes, totalNodes, averageLatency, uptimePercentage];
}
