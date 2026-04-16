import 'package:injectable/injectable.dart';

@lazySingleton
class WifiDirectService {
  /// Implementation of WiFi Direct sharing as a fallback
  /// Note: Requires flutter_p2p or similar package
  Future<bool> isAvailable() async {
    return false;
  }

  Future<void> shareData(String data) async {
    // Placeholder for WiFi Direct sharing implementation
  }

  Stream<String> receiveData() async* {
    // Placeholder for WiFi Direct reception
    yield* const Stream.empty();
  }
}
