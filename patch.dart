
class _FakeHttpOverrides extends HttpOverrides {
  final _FakeHttpClient client = _FakeHttpClient();
  final _FakeHttpServer server = _FakeHttpServer();

  @override
  HttpClient createHttpClient(SecurityContext? context) => client;

  @override
  Future<HttpServer> bind(dynamic address, int port,
      {int backlog = 0, bool v6Only = false, bool shared = false}) async {
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

    // Send to server
    // Note: We need a way to pass this to the server.
    // Let's make server a global or static for the test.
    _fakeServerInstance?.addRequest(request);

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
  final Uri uri;
  final String method;
  final List<int> _body;
  final _FakeHttpResponse response;
  final Completer<_FakeHttpResponse> responseCompleter = Completer();

  _FakeHttpRequest(this.uri, this.method, this._body, StreamController<List<int>> responseController)
      : response = _FakeHttpResponse(responseController) {
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpResponse implements HttpResponse {
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

class _FakeHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
