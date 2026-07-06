import 'package:equatable/equatable.dart';

enum NodeStatus {
  online,
  offline,
  syncing,
  error,
}

class NetworkNode extends Equatable {
  final String id;
  final String name;
  final String address;
  final NodeStatus status;
  final DateTime lastSeen;

  const NetworkNode({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.lastSeen,
  });

  factory NetworkNode.fromJson(Map<String, dynamic> json) {
    return NetworkNode(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      status: NodeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NodeStatus.offline,
      ),
      lastSeen: DateTime.parse(json['lastSeen'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'status': status.name,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  NetworkNode copyWith({
    String? id,
    String? name,
    String? address,
    NodeStatus? status,
    DateTime? lastSeen,
  }) {
    return NetworkNode(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  List<Object?> get props => [id, name, address, status, lastSeen];
}
