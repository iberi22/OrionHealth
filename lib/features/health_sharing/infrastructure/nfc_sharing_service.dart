import 'package:injectable/injectable.dart';

@lazySingleton
class NfcSharingService {
  /// Implementation of NFC sharing as a fallback
  /// Note: Requires nfc_manager package
  Future<bool> isAvailable() async {
    return false;
  }

  Future<void> shareData(String data) async {
    // Placeholder for NFC sharing implementation
  }

  Stream<String> receiveData() async* {
    // Placeholder for NFC reception
    yield* const Stream.empty();
  }
}
