// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen QR code scanner for EPS connection.
///
/// Scans QR codes containing EPS provider data (ID or discovery URL)
/// and returns the scanned [EPSProviderScanResult] when successful.
class EpsQrScannerPage extends StatefulWidget {
  const EpsQrScannerPage({super.key});

  @override
  State<EpsQrScannerPage> createState() => _EpsQrScannerPageState();
}

class _EpsQrScannerPageState extends State<EpsQrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _hasScanned = true);

    final result = EPSProviderScanResult.fromRawValue(barcode!.rawValue!);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear Código EPS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Scanner overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              'Apunta al código QR de tu EPS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Result from scanning an EPS QR code.
class EPSProviderScanResult {
  final String? providerId;
  final String? discoveryUrl;
  final String rawValue;

  const EPSProviderScanResult({
    this.providerId,
    this.discoveryUrl,
    required this.rawValue,
  });

  /// Parse a raw QR value. Supports:
  /// - Plain EPS ID: "EPS025"
  /// - JSON: {"provider_id": "EPS025", "discovery_url": "..."}
  /// - URL: "https://ihce.minsalud.gov.co/fhir/EPS025/..."
  factory EPSProviderScanResult.fromRawValue(String rawValue) {
    // Try JSON
    try {
      final json = _parseJson(rawValue);
      if (json is Map<String, dynamic>) {
        return EPSProviderScanResult(
          providerId: json['provider_id'] as String?,
          discoveryUrl: json['discovery_url'] as String?,
          rawValue: rawValue,
        );
      }
    } catch (_) {}

    // Try URL
    if (rawValue.startsWith('http://') || rawValue.startsWith('https://')) {
      final uri = Uri.tryParse(rawValue);
      // Extract EPS ID from URL path: /fhir/EPS025/...
      String? id;
      if (uri != null) {
        final segments = uri.pathSegments;
        for (int i = 0; i < segments.length - 1; i++) {
          if (segments[i].toLowerCase() == 'fhir') {
            id = segments[i + 1];
            break;
          }
        }
      }
      return EPSProviderScanResult(
        providerId: id,
        discoveryUrl: rawValue,
        rawValue: rawValue,
      );
    }

    // Default: treat as provider ID
    return EPSProviderScanResult(
      providerId: rawValue.trim(),
      rawValue: rawValue,
    );
  }

  static dynamic _parseJson(String value) {
    // Simple JSON parse without dart:convert dependency in factory
    final trimmed = value.trim();
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) return null;

    final map = <String, String>{};
    final content = trimmed.substring(1, trimmed.length - 1);
    final parts = content.split(',');
    for (final part in parts) {
      final colon = part.indexOf(':');
      if (colon < 0) continue;
      final key = part.substring(0, colon).trim().replaceAll('"', '');
      final val = part.substring(colon + 1).trim().replaceAll('"', '');
      map[key] = val;
    }
    return map;
  }
}
