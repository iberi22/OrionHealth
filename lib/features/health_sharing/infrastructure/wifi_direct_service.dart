import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../domain/entities/shared_health_package.dart';

/// WiFi Direct sharing service for health data transfer
@lazySingleton
class WifiDirectService {
  static const int kDefaultPort = 9124;
  static const String _serviceType = '_orion-health._tcp';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration transferTimeout = Duration(minutes: 3);

  HttpServer? _server;
  http.Client? _client;
  bool _isRunning = false;
  String? _deviceIp;

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;

  final _stateController = StreamController<WifiSharingState>.broadcast();
  Stream<WifiSharingState> get stateStream => _stateController.stream;

  final _dataController = StreamController<SharedHealthPackage>.broadcast();
  Stream<SharedHealthPackage> get incomingData => _dataController.stream;

  /// Initialize WiFi P2P
  Future<void> initialize() async {
    _stateController.add(WifiSharingState.ready());
  }

  /// Discover nearby OrionHealth devices on the local network using mDNS.
  ///
  /// Returns a list of discovered [WifiDirectDevice]s.
  Future<List<WifiDirectDevice>> discoverDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _stateController.add(WifiSharingState.discovering());
    final results = <WifiDirectDevice>[];
    final completer = Completer<List<WifiDirectDevice>>();

    try {
      _discovery = BonsoirDiscovery(type: _serviceType);

      _discovery!.eventStream!.listen((event) {
        if (event is BonsoirDiscoveryServiceFoundEvent) {
          event.service.resolve(_discovery!.serviceResolver);
        } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
          final service = event.service;
          final host = service.hostname ?? 'localhost';
          final port = service.port;
          results.add(WifiDirectDevice(
            name: service.name,
            address: '$host:$port',
          ));
        }
      });

      await _discovery!.start();

      // Wait for the timeout or until we have some results
      await Future.delayed(timeout);
      await _discovery!.stop();
      _discovery = null;
      completer.complete(results);
    } catch (e) {
      if (!completer.isCompleted) completer.complete(results);
    }

    _stateController.add(WifiSharingState.ready());
    return completer.future;
  }

  /// Start HTTP server to receive data and broadcast presence via mDNS.
  Future<void> startServer({int port = kDefaultPort}) async {
    if (_isRunning) return;

    try {
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        port,
        shared: true,
      );

      final actualPort = _server!.port;
      _deviceIp = '0.0.0.0:$actualPort';
      _isRunning = true;

      // Broadcast presence via mDNS
      final service = BonsoirService(
        name: 'OrionShare-${DateTime.now().millisecondsSinceEpoch}',
        type: _serviceType,
        port: actualPort,
      );
      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast!.start();

      _stateController.add(WifiSharingState.hosting(_deviceIp!));

      // Listen for incoming connections
      _server!.listen(
        (request) => _handleRequest(request),
        onError: (e) {
          _stateController.add(WifiSharingState.error('Server error: $e'));
        },
      );
    } catch (e) {
      _stateController.add(WifiSharingState.error('Failed to start server: $e'));
    }
  }

  /// Handle incoming HTTP request
  Future<void> _handleRequest(HttpRequest request) async {
    if (request.method != 'POST' || request.uri.path != '/orion/share') {
      request.response.statusCode = 404;
      request.response.close();
      return;
    }

    _stateController.add(WifiSharingState.receiving());

    try {
      // Collect all body bytes and decode
      final bodyBytes = await request.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
      final body = utf8.decode(bodyBytes);
      final package = SharedHealthPackage.decode(body);

      if (package.isExpired) {
        request.response.statusCode = 410; // Gone
        request.response.writeln('Package expired');
        request.response.close();
        _stateController.add(WifiSharingState.error('Package has expired'));
        return;
      }

      // Verify pin if provided
      if (package.metadata.pinHash != null) {
        // pin verification would happen here
      }

      _dataController.add(package);

      request.response.statusCode = 200;
      request.response.writeln('OK');
      await request.response.close();

      _stateController.add(WifiSharingState.received(package));
    } catch (e) {
      request.response.statusCode = 400;
      request.response.writeln('Invalid package');
      request.response.close();
      _stateController.add(WifiSharingState.error('Failed to receive: $e'));
    }
  }

  /// Send data to a device
  Future<SharingResult> sendData(
    String targetIp,
    SharedHealthPackage package,
  ) async {
    _stateController.add(WifiSharingState.connecting(targetIp));

    final startTime = DateTime.now();

    try {
      // Parse port from targetIp (format: 'ip:port') or use default
      final parts = targetIp.split(':');
      final host = parts.isNotEmpty ? parts[0] : targetIp;
      final port =
          parts.length > 1 ? int.tryParse(parts[1]) ?? kDefaultPort : kDefaultPort;

      _client = http.Client();

      final uri = Uri.parse('http://$host:$port/orion/share');

      _stateController.add(WifiSharingState.transferring('Sending...'));

      final data = package.encode();
      final response = await _client!
          .post(
            uri,
            body: data,
            headers: {'Content-Type': 'text/plain'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final transferTime = DateTime.now().difference(startTime);
        _stateController.add(
            WifiSharingState.completed(data.length, transferTime));

        _client?.close();
        _client = null;

        return SharingResult(
          success: true,
          bytesTransferred: data.length,
          transferTime: transferTime,
        );
      } else {
        throw Exception(
            'Remote rejected transfer: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _client?.close();
      _client = null;

      _stateController.add(WifiSharingState.error('Send failed: $e'));

      return SharingResult(
        success: false,
        error: e.toString(),
        bytesTransferred: 0,
        transferTime: DateTime.now().difference(startTime),
      );
    }
  }

  /// Stop server, discovery, and clean up
  Future<void> stop() async {
    _client?.close();
    _client = null;

    await _broadcast?.stop();
    _broadcast = null;

    await _discovery?.stop();
    _discovery = null;

    await _server?.close(force: true);
    _server = null;

    _isRunning = false;
    _deviceIp = null;

    _stateController.add(WifiSharingState.ready());
  }

  /// Get current server address
  String? get serverAddress => _deviceIp;

  void dispose() {
    stop();
    _stateController.close();
    _dataController.close();
  }
}

/// WiFi Direct device
class WifiDirectDevice {
  final String name;
  final String address;

  const WifiDirectDevice({
    required this.name,
    required this.address,
  });
}

/// State of WiFi Direct sharing
class WifiSharingState {
  final String status;
  final String? address;
  final String? message;
  final bool isError;
  final int? bytesTransferred;
  final Duration? transferTime;
  final SharedHealthPackage? receivedPackage;

  const WifiSharingState._({
    required this.status,
    this.address,
    this.message,
    this.isError = false,
    this.bytesTransferred,
    this.transferTime,
    this.receivedPackage,
  });

  factory WifiSharingState.ready() => const WifiSharingState._(
        status: 'ready',
        message: 'Ready to share via WiFi',
      );

  factory WifiSharingState.discovering() => const WifiSharingState._(
        status: 'discovering',
        message: 'Searching for nearby devices...',
      );

  factory WifiSharingState.hosting(String address) => WifiSharingState._(
        status: 'hosting',
        address: address,
        message: 'Waiting for connection...',
      );

  factory WifiSharingState.connecting(String address) => WifiSharingState._(
        status: 'connecting',
        address: address,
        message: 'Connecting to $address...',
      );

  factory WifiSharingState.transferring(String message) => WifiSharingState._(
        status: 'transferring',
        message: message,
      );

  factory WifiSharingState.receiving() => const WifiSharingState._(
        status: 'receiving',
        message: 'Receiving data...',
      );

  factory WifiSharingState.received(SharedHealthPackage package) => WifiSharingState._(
        status: 'received',
        message: 'Data received from ${package.senderNodeId}',
        receivedPackage: package,
      );

  factory WifiSharingState.completed(int bytes, Duration time) => WifiSharingState._(
        status: 'completed',
        message: 'Transfer complete',
        bytesTransferred: bytes,
        transferTime: time,
      );

  factory WifiSharingState.error(String message) => WifiSharingState._(
        status: 'error',
        message: message,
        isError: true,
      );
}
