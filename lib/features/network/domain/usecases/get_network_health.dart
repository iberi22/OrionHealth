import 'package:injectable/injectable.dart';
import '../entities/network_health.dart';
import '../repositories/network_repository.dart';

@lazySingleton
class GetNetworkHealth {
  final NetworkRepository _repository;

  GetNetworkHealth(this._repository);

  Future<NetworkHealth> call() async {
    return await _repository.getNetworkHealth();
  }
}
