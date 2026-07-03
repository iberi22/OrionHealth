import 'package:injectable/injectable.dart';
import '../entities/node_stats.dart';
import '../repositories/network_repository.dart';

@lazySingleton
class GetNodeStats {
  final NetworkRepository _repository;

  GetNodeStats(this._repository);

  Future<NodeStats> call(String nodeId) async {
    return await _repository.getNodeStats(nodeId);
  }
}
