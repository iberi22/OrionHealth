import 'dart:async';
import 'package:app_links/app_links.dart';

/// Captures cold-start links before native initialization; only the authenticated
/// navigation shell drains them. Health payloads are never logged.
class EcosystemLinkInbox {
  EcosystemLinkInbox._();
  static final instance = EcosystemLinkInbox._();
  final _pending = <Uri>[];
  StreamSubscription<Uri>? _subscription;
  void Function()? onPending;
  Uri? _lastReceived;

  static bool isImportLink(Uri uri) =>
      (uri.scheme == 'https' && uri.path == '/import') ||
      (uri.scheme == 'orionhealth' && uri.host == 'import');

  void start() {
    if (_subscription != null) return;
    final links = AppLinks();
    _subscription = links.uriLinkStream.listen(_receive, onError: (_) {});
    unawaited(
      links
          .getInitialLink()
          .then((uri) {
            if (uri != null) _receive(uri);
          })
          .catchError((Object _) {}),
    );
  }

  void _receive(Uri uri) {
    if (!isImportLink(uri) || uri == _lastReceived || _pending.contains(uri)) {
      return;
    }
    _lastReceived = uri;
    // Keep a bounded queue; no link can trigger a save without review.
    if (_pending.length == 8) _pending.removeAt(0);
    _pending.add(uri);
    onPending?.call();
  }

  Uri? take() => _pending.isEmpty ? null : _pending.removeAt(0);
}
