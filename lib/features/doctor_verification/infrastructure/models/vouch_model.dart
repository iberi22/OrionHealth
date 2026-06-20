import '../../domain/entities/vouch.dart';

class VouchModel extends Vouch {
  VouchModel({
    required super.id,
    required super.vouchedBy,
    required super.targetDoctor,
    required super.category,
    required super.timestamp,
  });

  factory VouchModel.fromJson(Map<String, dynamic> json) {
    return VouchModel(
      id: json['id'] as String,
      vouchedBy: json['vouchedBy'] as String,
      targetDoctor: json['targetDoctor'] as String,
      category: json['category'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vouchedBy': vouchedBy,
      'targetDoctor': targetDoctor,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory VouchModel.fromEntity(Vouch entity) {
    return VouchModel(
      id: entity.id,
      vouchedBy: entity.vouchedBy,
      targetDoctor: entity.targetDoctor,
      category: entity.category,
      timestamp: entity.timestamp,
    );
  }
}
