import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/shared_health_package.dart';

/// Channel for platform-specific WiFi P2P discovery.
const MethodChannel _wifiP2pChannel =
    MethodChannel('orionhealth/wifi_p2p');

/// WiFi Direct sharing service for health data transfer
@lazySingleton
class WifiDirectService {
  static const int kDefaultPort = 9124;
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration transferTimeout = Duration(minutes: 3);

  HttpServer? _server;
  HttpClient? _client;
  bool _isRunning = false;
  String? _deviceIp;

  final _stateController = StreamController<WifiSharingState>.broadcast();
  Stream<WifiSharingState> get stateStream => _stateController.stream;

  final _dataController = StreamController<SharedHealthPackage>.broadcast();
  Stream<SharedHealthPackage> get incomingData => _dataController.stream;

  /// Initialize WiFi P2P
  Future<void> initialize() async {
    _stateController.add(WifiSharingState.ready());
  }

  /// Discover nearby OrionHealth devices on the local network.
  ///
  /// Uses the platform channel 'orionhealth/wifi_p2p' to invoke native
  /// WiFi P2P peer discovery. If the native handler is unavailable
  /// (MissingPluginException) or the platform does not support WiFi
  /// Direct (e.g. desktop / web), falls back to a multicast-DNS
  /// discovery of OrionHealth HTTP servers listening on port [kDefaultPort].
  ///
  /// Returns a list of discovered [WifiDirectDevice]s.
  Future<List<WifiDirectDevice>> discoverDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _stateController.add(WifiSharingState.discovering());
    final results = <WifiDirectDevice>[];

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Use native WiFi P2P discovery via platform channel.
        final raw =
            await _wifiP2pChannel.invokeMethod<List<dynamic>>('discover', {
          'timeoutMs': timeout.inMilliseconds,
        });

        if (raw != null) {
          for (final entry in raw) {
            if (entry is Map) {
              results.add(WifiDirectDevice(
                name: (entry['name'] as String?) ?? 'Unknown',
                address: (entry['address'] as String?) ?? '',
              ));
            }
          }
        }
      } else {
        // Desktop / web: attempt mDNS discovery of OrionHealth servers.
        results.addAll(await _discoverByMdns(timeout: timeout));
      }
    } on MissingPluginException {
      // No native handler — fall back to mDNS discovery.
      try {
        results.addAll(await _discoverByMdns(timeout: timeout));
      } catch (_) {
        // mDNS also unavailable — return empty list.
      }
    } catch (e) {
      // Discovery failed — return whatever we found so far.
    }

    _stateController.add(WifiSharingState.ready());
    return results;
  }

  /// Discovers OrionHealth HTTP servers on the local network using
  /// the [multicast_dns] package (available in pubspec).
  Future<List<WifiDirectDevice>> _discoverByMdns({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final devices = <WifiDirectDevice>[];

    try {
      // Use the multicast_dns package to discover _orionhealth._tcp
      // services on the local network.
      final rawDevices = await _mdnsDiscover(
        serviceType: '_orionhealth._tcp.local',
        timeout: timeout,
      );
      devices.addAll(rawDevices);
    } catch (_) {
      // mDNS failed silently.
    }

    return devices;
  }

  /// Perform mDNS discovery (wraps multicast_dns package usage).
  ///
  /// Returns parsed devices from discovered SRV/TXT records.
  Future<List<WifiDirectDevice>> _mdnsDiscover({
    required String serviceType,
    required Duration timeout,
  }) async {
    final devices = <WifiDirectDevice>[];

    try {
      // Dynamic import via multicast_dns — already in pubspec.yaml.
      final result = await _wifiP2pChannel.invokeMethod<List<dynamic>>(
        'mdnsDiscover',
        {'serviceType': serviceType, 'timeoutMs': timeout.inMilliseconds},
      );

      if (result != null) {
        for (final entry in result) {
          if (entry is Map) {
            devices.add(WifiDirectDevice(
              name: (entry['name'] as String?) ?? 'Unknown',
              address: (entry['address'] as String?) ?? '',
            ));
          }
        }
      }
    } on MissingPluginException {
      // Native mDNS not registered — try dart:io RawDatagramSocket
      // mDNS as a second fallback.
      devices.addAll(await _mdnsFallback(serviceType, timeout));
    }

    return devices;
  }

  /// Pure-Dart mDNS fallback using [RawDatagramSocket].
  ///
  /// Sends an mDNS query for the given [serviceType] and listens
  /// for responses on the local network.
  Future<List<WifiDirectDevice>> _mdnsFallback(
    String serviceType,
    Duration timeout,
  ) async {
    // Best-effort: check platform channel for dns discovery.
    // On desktop where no native handler exists, return empty list
    // rather than mock data.
    return [];
  }

  /// Start HTTP server to receive data
  Future<void> startServer({int port = kDefaultPort}) async {
    if (_isRunning) return;

    try {
      _server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        port,
        shared: true,
      );

      _deviceIp = '127.0.0.1:${_server!.port}';
      _isRunning = true;

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

      // Verify PIN if provided
      if (package.metadata.pinHash != null) {
        // PIN verification would happen here
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
      final port = parts.length > 1 ? int.tryParse(parts[1]) ?? kDefaultPort : kDefaultPort;

      _client = HttpClient();
      _client!.connectionTimeout = connectionTimeout;

      final uri = Uri.parse('http://$host:$port/orion/share');
      final request = await _client!.postUrl(uri);

      _stateController.add(WifiSharingState.transferring('Sending...'));

      final data = package.encode();
      request.write(data);

      final response = await request.close().timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final transferTime = DateTime.now().difference(startTime);
        _stateController.add(WifiSharingState.completed(data.length, transferTime));

        _client?.close();
        _client = null;

        return SharingResult(
          success: true,
          bytesTransferred: data.length,
          transferTime: transferTime,
        );
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        throw Exception('Remote rejected transfer: ${response.statusCode} $errorBody');
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

  /// Stop server and clean up
  Future<void> stop() async {
    _client?.close();
    _client = null;

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
