import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../auth/infrastructure/services/encryption_service.dart';
import '../domain/ble_sharing_service.dart';

class WifiDirectService {
  static const int kDefaultPort = 9124;
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration transferTimeout = Duration(minutes: 3);

  final EncryptionService _encryptionService;
  HttpServer? _server;
  Socket? _socket;
  bool _isRunning = false;
  String? _deviceIp;

  final _stateController = StreamController<WifiServiceState>.broadcast();
  Stream<WifiServiceState> get stateStream => _stateController.stream;

  final _dataController = StreamController<MedicalSharePackage>.broadcast();
  Stream<MedicalSharePackage> get incomingData => _dataController.stream;

  WifiDirectService({EncryptionService? encryptionService})
      : _encryptionService = encryptionService ?? EncryptionServiceImpl();

  Future<void> initialize() async {
    _stateController.add(WifiServiceState.ready());
  }

  Future<List<WifiDirectDevice>> discoverDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _stateController.add(WifiServiceState.discovering());
    await Future.delayed(timeout);
    _stateController.add(WifiServiceState.ready());
    return [
      const WifiDirectDevice(
        name: 'OrionHealth-Maria',
        address: '192.168.1.101',
      ),
      const WifiDirectDevice(
        name: 'OrionHealth-Juan',
        address: '192.168.1.102',
      ),
    ];
  }

  Future<void> startServer({int port = kDefaultPort}) async {
    if (_isRunning) return;

    try {
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        port,
        shared: true,
      );
      _deviceIp = '${_server!.address.address}:$port';
      _isRunning = true;
      _stateController.add(WifiServiceState.hosting(_deviceIp!));

      _server!.listen(
        (request) => _handleRequest(request),
        onError: (e) {
          _stateController.add(WifiServiceState.error('Server error: $e'));
        },
      );
    } catch (e) {
      _stateController.add(
        WifiServiceState.error('Failed to start server: $e'),
      );
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (request.method != 'POST' || request.uri.path != '/orion/share') {
      request.response.statusCode = 404;
      request.response.close();
      return;
    }

    _stateController.add(WifiServiceState.receiving());

    try {
      final bodyBytes = await request.fold<List<int>>(
        [],
        (acc, chunk) => acc..addAll(chunk),
      );

      final package = await _decryptPackageBytes(Uint8List.fromList(bodyBytes));

      if (package.isExpired) {
        request.response.statusCode = 410;
        request.response.writeln('Package expired');
        request.response.close();
        _stateController.add(WifiServiceState.error('Package has expired'));
        return;
      }

      _dataController.add(package);
      request.response.statusCode = 200;
      request.response.writeln('OK');
      await request.response.close();
      _stateController.add(WifiServiceState.received(package));
    } catch (e) {
      request.response.statusCode = 400;
      request.response.writeln('Invalid package');
      request.response.close();
      _stateController.add(WifiServiceState.error('Failed to receive: $e'));
    }
  }

  Future<SharingResult> sendData(
    String targetIp,
    MedicalSharePackage package,
  ) async {
    _stateController.add(WifiServiceState.connecting(targetIp));
    final startTime = DateTime.now();

    try {
      _socket = await Socket.connect(
        targetIp,
        kDefaultPort,
        timeout: connectionTimeout,
      );
      _stateController.add(WifiServiceState.transferring('Encrypting and sending...'));

      final encryptedBytes = await _encryptPackageToBytes(package);
      _socket!.add(encryptedBytes);
      await _socket!.flush();

      final response = await _socket!.first.timeout(
        const Duration(seconds: 10),
      );
      final responseStr = utf8.decode(response);
      await _socket!.close();
      _socket = null;

      if (responseStr.contains('OK')) {
        final transferTime = DateTime.now().difference(startTime);
        _stateController.add(
          WifiServiceState.completed(encryptedBytes.length, transferTime),
        );
        return SharingResult(
          success: true,
          bytesTransferred: encryptedBytes.length,
          transferTime: transferTime,
        );
      } else {
        throw Exception('Remote rejected transfer');
      }
    } catch (e) {
      _socket?.close();
      _socket = null;
      _stateController.add(WifiServiceState.error('Send failed: $e'));
      return SharingResult(
        success: false,
        error: e.toString(),
        bytesTransferred: 0,
        transferTime: DateTime.now().difference(startTime),
      );
    }
  }

  Future<Uint8List> _encryptPackageToBytes(MedicalSharePackage package) async {
    final jsonStr = jsonEncode(package.toJson());
    return await _encryptionService.encrypt(jsonStr);
  }

  Future<MedicalSharePackage> _decryptPackageBytes(Uint8List encryptedBytes) async {
    final decryptedJson = await _encryptionService.decrypt(encryptedBytes);
    final json = jsonDecode(decryptedJson) as Map<String, dynamic>;
    return MedicalSharePackage.fromJson(json);
  }

  Future<void> stop() async {
    _socket?.close();
    _socket = null;
    await _server?.close(force: true);
    _server = null;
    _isRunning = false;
    _deviceIp = null;
    _stateController.add(WifiServiceState.ready());
  }

  String? get serverAddress => _deviceIp;

  void dispose() {
    stop();
    _stateController.close();
    _dataController.close();
  }
}

class WifiDirectDevice {
  final String name;
  final String address;

  const WifiDirectDevice({required this.name, required this.address});
}

class WifiServiceState {
  final String status;
  final String? address;
  final String? message;
  final bool isError;
  final int? bytesTransferred;
  final Duration? transferTime;
  final MedicalSharePackage? receivedPackage;

  const WifiServiceState._({
    required this.status,
    this.address,
    this.message,
    this.isError = false,
    this.bytesTransferred,
    this.transferTime,
    this.receivedPackage,
  });

  factory WifiServiceState.ready() => const WifiServiceState._(
    status: 'ready',
    message: 'Ready to share via WiFi',
  );

  factory WifiServiceState.discovering() => const WifiServiceState._(
    status: 'discovering',
    message: 'Searching for nearby devices...',
  );

  factory WifiServiceState.hosting(String address) => WifiServiceState._(
    status: 'hosting',
    address: address,
    message: 'Waiting for connection...',
  );

  factory WifiServiceState.connecting(String address) => WifiServiceState._(
    status: 'connecting',
    address: address,
    message: 'Connecting to $address...',
  );

  factory WifiServiceState.transferring(String message) =>
      WifiServiceState._(status: 'transferring', message: message);

  factory WifiServiceState.receiving() => const WifiServiceState._(
    status: 'receiving',
    message: 'Receiving data...',
  );

  factory WifiServiceState.received(MedicalSharePackage package) =>
      WifiServiceState._(
        status: 'received',
        message: 'Data received from ${package.senderNodeId}',
        receivedPackage: package,
      );

  factory WifiServiceState.completed(int bytes, Duration time) =>
      WifiServiceState._(
        status: 'completed',
        message: 'Transfer complete',
        bytesTransferred: bytes,
        transferTime: time,
      );

  factory WifiServiceState.error(String message) =>
      WifiServiceState._(status: 'error', message: message, isError: true);
}
