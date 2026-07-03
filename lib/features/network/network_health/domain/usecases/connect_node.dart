import 'package:injectable/injectable.dart';
import '../repositories/network_repository.dart';

@lazySingleton
class ConnectNode {
  final NetworkRepository _repository;

  ConnectNode(this._repository);

  Future<void> call(String nodeId) async {
    await _repository.connectNode(nodeId);
  }
}
