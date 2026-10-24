import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Note: tests marked with // NETWORK require actual WiFi Direct hardware
  // Run with --exclude-tags=network to skip.
  // Two tests below (transfer tests) are tagged 'network'.

  late WifiDirectService service;
  const channel = MethodChannel('orionhealth/wifi_p2p');

  setUp(() {
    service = WifiDirectService();

    const bonsoirChannel = MethodChannel('fr.skyost.bonsoir');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(bonsoirChannel, (methodCall) async {
          switch (methodCall.method) {
            case 'discovery.initialize':
            case 'discovery.start':
            case 'discovery.stop':
            case 'broadcast.initialize':
            case 'broadcast.start':
            case 'broadcast.stop':
              return null;
            default:
              return null;
          }
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'mdnsDiscover') {
            return [
              {'name': 'OrionHealth Test Device', 'address': '127.0.0.1:9124'},
            ];
          }
          return null;
        });
  });

  tearDown(() async {
    try {
      await service.stop();
    } catch (_) {}
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('fr.skyost.bonsoir'),
          null,
        );
  });

  group('WifiDirectService', () {
    setUpAll(() {
      HttpOverrides.global = null;
    });

    test('initial state is ready', () async {
      expectLater(
        service.stateStream,
        emits(predicate((WifiSharingState s) => s.status == 'ready')),
      );
      await service.initialize();
    });

    test('discoverDevices updates state and returns devices', () async {
      await service.initialize();

      expectLater(
        service.stateStream,
        emitsThrough(
          predicate((WifiSharingState s) => s.status == 'discovering'),
        ),
      );

      const channel = EventChannel('fr.skyost.bonsoir.discovery');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(channel, _MockStreamHandler());

      final devices = await service.discoverDevices(
        timeout: const Duration(milliseconds: 100),
      );
      expect(devices, isNotEmpty);
      expect(devices.any((d) => d.name.contains('OrionHealth')), isTrue);
    });

    test('startServer updates state to hosting and uses IP', () async {
      await service.initialize();

      expectLater(
        service.stateStream,
        emitsThrough(
          predicate(
            (WifiSharingState s) => s.status == 'hosting' && s.address != null,
          ),
        ),
      );

      await service.startServer(port: 0);
      expect(service.serverAddress, isNotNull);
    });

    test('full transfer with PIN verification success', () async {
      // Requires real network — skip in CI mode
      // Run with `flutter test` to execute
      await service.initialize();
      const pin = '1234';

      // Start server with PIN
      await service.startServer(port: 0);
      final address = service.serverAddress!;

      final package = SharedHealthPackage(
        id: 'test',
        senderNodeId: 'sender',
        recipientNodeId: 'recipient',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(
          encryptedData: 'data',
          iv: 'iv',
          ephemeralPublicKey: 'key',
        ),
        metadata: PackageMetadata(
          packageType: 'full',
          consentVerified: true,
          includedCategories: {DataCategory.vitalSigns},
          appVersion: '1.0.0',
          pinHash: SharedHealthPackage.hashPin(pin),
        ),
        signature: 'sig',
      );

      // We expect the data to be received
      final dataFuture = service.incomingData.first;

      // Send data to self
      final result = await service.sendData(address, package);

      expect(result.success, isTrue);
      final receivedPackage = await dataFuture;
      expect(receivedPackage.id, 'test');
    });

    test('transfer with expired package failure', () async {
      await service.initialize();

      await service.startServer(port: 0);
      final address = service.serverAddress!;

      final package = SharedHealthPackage(
        id: 'test',
        senderNodeId: 'sender',
        recipientNodeId: 'recipient',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        expiresAt: DateTime.now().subtract(
          const Duration(minutes: 5),
        ), // Expired
        payload: const EncryptedPayload(
          encryptedData: 'data',
          iv: 'iv',
          ephemeralPublicKey: 'key',
        ),
        metadata: PackageMetadata(
          packageType: 'full',
          consentVerified: true,
          includedCategories: {DataCategory.vitalSigns},
          appVersion: '1.0.0',
        ),
        signature: 'sig',
      );

      final result = await service.sendData(address, package);

      expect(result.success, isFalse);
      expect(result.error, contains('410'));
    });

    test('stop() resets state correctly', () async {
      await service.initialize();
      await service.startServer(port: 0);
      expect(service.serverAddress, isNotNull);

      await service.stop();
      expect(service.serverAddress, isNull);

      // Should be able to start again
      await service.startServer(port: 0);
      expect(service.serverAddress, isNotNull);
    });
  });
}

class _FakeHttpOverrides extends HttpOverrides {
  final _FakeHttpClient client = _FakeHttpClient();
  final _FakeHttpServer server = _FakeHttpServer();

  @override
  HttpClient createHttpClient(SecurityContext? context) => client;

  @override
  Future<HttpServer> bind(
    dynamic address,
    int port, {
    int backlog = 0,
    bool v6Only = false,
    bool shared = false,
  }) async {
    return server;
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration? idleTimeout;
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    return _FakeHttpClientRequest(url, this);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  final Uri url;
  final _FakeHttpClient client;
  final List<int> _body = [];
  final HttpHeaders _headers = _FakeHttpHeaders();

  _FakeHttpClientRequest(this.url, this.client);

  @override
  HttpHeaders get headers => _headers;

  @override
  void add(List<int> data) {
    _body.addAll(data);
  }

  @override
  Future<HttpClientResponse> close() async {
    final responseController = StreamController<List<int>>();
    final request = _FakeHttpRequest(url, 'POST', _body, responseController);

    if (_fakeServerInstance != null) {
      _fakeServerInstance!.addRequest(request);
    }

    final response = await request.responseCompleter.future;
    return _FakeHttpClientResponse(response.statusCode, response.body);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

_FakeHttpServer? _fakeServerInstance;

class _FakeHttpServer extends Stream<HttpRequest> implements HttpServer {
  final _controller = StreamController<HttpRequest>.broadcast();

  _FakeHttpServer() {
    _fakeServerInstance = this;
  }

  void addRequest(_FakeHttpRequest request) {
    _controller.add(request);
  }

  @override
  int get port => 9124;

  @override
  InternetAddress get address => InternetAddress('127.0.0.1');

  @override
  StreamSubscription<HttpRequest> listen(
    void Function(HttpRequest event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<HttpServer> close({bool force = false}) async {
    await _controller.close();
    if (_fakeServerInstance == this) _fakeServerInstance = null;
    return this;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpRequest extends Stream<List<int>> implements HttpRequest {
  @override
  final Uri uri;
  @override
  final String method;
  final List<int> _body;
  @override
  final _FakeHttpResponse response;
  final Completer<_FakeHttpResponse> responseCompleter = Completer();

  _FakeHttpRequest(
    this.uri,
    this.method,
    this._body,
    StreamController<List<int>> responseController,
  ) : response = _FakeHttpResponse(responseController) {
    response._completer = responseCompleter;
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(_body).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<S> fold<S>(
    S initialValue,
    S Function(S previous, List<int> element) combine,
  ) async {
    return combine(initialValue, _body);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpResponse implements HttpResponse {
  @override
  int statusCode = 200;
  final List<int> body = [];
  final StreamController<List<int>> _controller;
  late Completer<_FakeHttpResponse> _completer;

  _FakeHttpResponse(this._controller);

  @override
  void writeln([Object? obj = '']) {
    body.addAll(utf8.encode('$obj\n'));
  }

  @override
  Future<void> close() async {
    _controller.add(body);
    _controller.close();
    _completer.complete(this);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode;
  final List<int> _body;

  _FakeHttpClientResponse(this.statusCode, this._body);

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(_body);
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(_body).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<S> fold<S>(
    S initialValue,
    S Function(S previous, List<int> element) combine,
  ) async {
    return combine(initialValue, _body);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
