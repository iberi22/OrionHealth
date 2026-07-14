import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// EPS WebView Session Persistence Manager
///
/// Persists WebView session state (cookies, localStorage, navigation history)
/// so the user can re-enter their EPS portal directly without re-selecting
/// the provider or re-logging in.
///
/// Architecture:
/// - On first login: captures all cookies + localStorage + sessionStorage
/// - On re-entry: restores cookies and navigates directly to dashboard
/// - Navigation history: tracks every URL visited in the portal session
class EpsWebViewSession {
  final FlutterSecureStorage _storage;
  final String _epsId;

  EpsWebViewSession({
    required FlutterSecureStorage storage,
    required String epsId,
  })  : _storage = storage,
        _epsId = epsId;

  // ─── Storage keys ───

  String get _cookiesKey => 'eps_session_${_epsId}_cookies';
  String get _navHistoryKey => 'eps_session_${_epsId}_nav_history';
  String get _lastUrlKey => 'eps_session_${_epsId}_last_url';
  String get _localStorageKey => 'eps_session_${_epsId}_local_storage';
  String get _sessionMetaKey => 'eps_session_${_epsId}_meta';

  // ─── Session Capture ───

  /// Captures the full WebView session state after successful login.
  /// Call this after detecting that the user has logged into their EPS portal.
  Future<void> captureSession(InAppWebViewController controller) async {
    try {
      // Capture cookies
      final cookieManager = CookieManager.instance();
      final cookies = await cookieManager.getCookies(
        url: WebUri('https://'),
      );

      if (cookies.isNotEmpty) {
        final cookieList = cookies
            .map((c) => {
                  'name': c.name,
                  'value': c.value,
                  'domain': c.domain,
                  'path': c.path ?? '/',
                  'expiresDate': c.expiresDate,
                  'isSecure': c.isSecure,
                  'isHttpOnly': c.isHttpOnly,
                })
            .toList();
        await _storage.write(
          key: _cookiesKey,
          value: jsonEncode(cookieList),
        );
      }

      // Capture localStorage
      final localStorage = await controller.evaluateJavascript(source: '''
        (function() {
          try {
            const items = {};
            for (let i = 0; i < localStorage.length; i++) {
              const key = localStorage.key(i);
              items[key] = localStorage.getItem(key);
            }
            return JSON.stringify(items);
          } catch(e) { return '{}'; }
        })()
      ''');

      if (localStorage != null && localStorage.toString().isNotEmpty) {
        await _storage.write(key: _localStorageKey, value: localStorage.toString());
      }

      // Record session metadata
      final meta = jsonEncode({
        'capturedAt': DateTime.now().toIso8601String(),
        'epsId': _epsId,
      });
      await _storage.write(key: _sessionMetaKey, value: meta);

      debugPrint('EPS WebView session captured for $_epsId: ${cookies.length} cookies');
    } catch (e) {
      debugPrint('Failed to capture EPS session: $e');
    }
  }

  // ─── Session Restoration ───

  /// Restores all cookies to the WebView before loading the portal.
  /// Returns true if restoration was successful.
  Future<bool> restoreSession(InAppWebViewController controller) async {
    try {
      final cookiesJson = await _storage.read(key: _cookiesKey);
      if (cookiesJson == null || cookiesJson.isEmpty) return false;

      final cookieManager = CookieManager.instance();
      final cookiesList = jsonDecode(cookiesJson) as List<dynamic>;

      for (final cookie in cookiesList) {
        try {
          await cookieManager.setCookie(
            url: WebUri('https://${cookie['domain']}'),
            name: cookie['name']?.toString() ?? '',
            value: cookie['value']?.toString() ?? '',
            domain: cookie['domain']?.toString(),
            path: cookie['path']?.toString() ?? '/',
            expiresDate: cookie['expiresDate'] != null
                ? (cookie['expiresDate'] as num).toInt()
                : DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch,
            isSecure: cookie['isSecure'] ?? true,
            isHttpOnly: cookie['isHttpOnly'] ?? false,
          );
        } catch (_) {
          // Individual cookie restoration failure is non-fatal
        }
      }

      debugPrint('EPS WebView session restored for $_epsId: ${cookiesList.length} cookies');
      return true;
    } catch (e) {
      debugPrint('Failed to restore EPS session: $e');
      return false;
    }
  }

  /// Restores localStorage into the WebView.
  Future<void> restoreLocalStorage(InAppWebViewController controller) async {
    try {
      final data = await _storage.read(key: _localStorageKey);
      if (data == null || data.isEmpty) return;

      await controller.evaluateJavascript(source: '''
        (function() {
          try {
            const items = JSON.parse('${data.replaceAll("'", "\\'")}');
            for (const [key, value] of Object.entries(items)) {
              localStorage.setItem(key, value);
            }
          } catch(e) {}
        })()
      ''');
    } catch (_) {}
  }

  // ─── Navigation History ───

  /// Saves a URL to the navigation history stack.
  Future<void> trackNavigation(String url) async {
    try {
      final existingJson = await _storage.read(key: _navHistoryKey);
      final history = existingJson != null && existingJson.isNotEmpty
          ? (jsonDecode(existingJson) as List<dynamic>).toList()
          : <dynamic>[];

      history.add({
        'url': url,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Keep last 50 entries
      if (history.length > 50) {
        history.removeRange(0, history.length - 50);
      }

      await _storage.write(key: _navHistoryKey, value: jsonEncode(history));
    } catch (e) {
      debugPrint('Failed to track navigation: $e');
    }
  }

  /// Gets the full navigation history.
  Future<List<Map<String, dynamic>>> getNavigationHistory() async {
    try {
      final json = await _storage.read(key: _navHistoryKey);
      if (json == null || json.isEmpty) return [];

      final list = jsonDecode(json) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Gets the last visited URL within the EPS portal.
  Future<String?> getLastUrl() async {
    try {
      return await _storage.read(key: _lastUrlKey);
    } catch (_) {
      return null;
    }
  }

  /// Saves the last visited URL.
  Future<void> saveLastUrl(String url) async {
    try {
      await _storage.write(key: _lastUrlKey, value: url);
    } catch (e) {
      debugPrint('Failed to save last URL: $e');
    }
  }

  /// Checks if a valid session exists for this EPS.
  Future<bool> hasActiveSession() async {
    try {
      final cookies = await _storage.read(key: _cookiesKey);
      if (cookies == null || cookies.isEmpty) return false;

      final meta = await _storage.read(key: _sessionMetaKey);
      if (meta == null || meta.isEmpty) return false;

      // Check if session is less than 7 days old
      final metaMap = jsonDecode(meta);
      final capturedAt = DateTime.parse(metaMap['capturedAt']);
      if (DateTime.now().difference(capturedAt).inDays > 7) {
        await clearSession();
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Session Cleanup ───

  /// Clears all persisted session data for this EPS.
  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _cookiesKey);
      await _storage.delete(key: _navHistoryKey);
      await _storage.delete(key: _lastUrlKey);
      await _storage.delete(key: _localStorageKey);
      await _storage.delete(key: _sessionMetaKey);
    } catch (_) {}
  }

  /// Clears the secure storage (called on logout or disconnect).
  Future<void> destroyAll() async {
    await clearSession();
    await _storage.deleteAll();
  }
}
