// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Factory for Dio instances with security hardening:
/// - Certificate Pinning (SHA-256)
/// - Forced HTTPS
/// - Strict SSL validation
class HttpClientFactory {
  /// Pinned fingerprints (SHA-256 of the DER-encoded certificate).
  static const Map<String, List<String>> _allowedPins = {
    // These pins are verified from current production certificates
    'rxnav.nlm.nih.gov': ['bQPSf/wNwflh1ow7wbZNGpY22c5wGmfYpMBmiPL0uBU='],
    'api.fda.gov': ['JjztvG35nefJZYq1xBvCEymtwk9Oi6Bzm40BWj4NpOA='],
    'eutils.ncbi.nlm.nih.gov': ['yf0n/vkGMQzZEeZOzWgSUAtuNOhhbxJDRe9grC+FT9U='],

    // Placeholders for orionhealth.app - must be updated before final prod release
    'api.orionhealth.app': ['REPLACE_WITH_PROD_PIN'],
    'ai.orionhealth.app': ['REPLACE_WITH_PROD_PIN'],
  };

  /// Creates a configured Dio instance.
  static Dio createDio() {
    final dio = Dio();

    // 1. Force HTTPS Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final uri = options.uri;
        // Allow localhost for development, but otherwise force HTTPS
        final isLocal = uri.host == 'localhost' || uri.host == '127.0.0.1';
        if (uri.scheme != 'https' && !isLocal) {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Security Error: HTTPS is required for all external connections.',
              type: DioExceptionType.connectionError,
            ),
          );
        }
        return handler.next(options);
      },
    ));

    // 2. Certificate Pinning and SSL Validation
    // This only works on IO platforms (Android/iOS/Desktop)
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      final adapter = dio.httpClientAdapter as IOHttpClientAdapter;

      /// Dio's validateCertificate is called for ALL certificates during the handshake.
      /// Returning true allows the process to continue (still subject to badCertificateCallback if untrusted).
      /// Returning false immediately terminates the connection.
      adapter.validateCertificate = (X509Certificate? cert, String host, int port) {
        if (cert == null) return false;

        final pins = _allowedPins[host];

        // If the host is not in our pinning list, we return true
        // to let the default system trust store validation proceed.
        if (pins == null || pins.isEmpty) {
          return true;
        }

        // Special case for placeholders in non-production builds
        if (pins.contains('REPLACE_WITH_PROD_PIN') && !kReleaseMode) {
          return true;
        }

        // Calculate SHA-256 fingerprint of the certificate DER
        final hash = sha256.convert(cert.der).bytes;
        final fingerprint = base64.encode(hash);

        // Verification: fingerprint must match one of the allowed pins
        if (pins.contains(fingerprint)) {
          return true;
        }

        // If it doesn't match and it was a pinned host, we REJECT.
        // This provides protection against compromised CAs for these specific hosts.
        return false;
      };

      adapter.createHttpClient = () {
        final client = HttpClient();
        // Strict SSL: Reject any certificate that fails system validation
        // (expired, self-signed, untrusted CA, etc.)
        client.badCertificateCallback = (cert, host, port) => false;
        return client;
      };
    }

    return dio;
  }
}
