import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// EPS Data Scraper — Post-Login Extraction Engine
///
/// Executes JavaScript injection in the authenticated WebView session
/// to extract patient profile data after manual login.
///
/// Architecture: User logs in manually → this scraper runs JS selectors
/// to pull name, document, birth date, conditions, medications from the DOM.
///
/// Privacy: All processing happens on-device. No data leaves the device.
class EpsDataScraper {
  final List<String> _scrapedFields;
  final List<String> _errors;

  EpsDataScraper()
      : _scrapedFields = [],
        _errors = [];

  /// CSS selectors for patient data fields across different EPS portals.
  /// Each EPS has different HTML structure — these are the most common patterns
  /// found in Colombian EPS patient portals (Sura, Sanitas, Nueva EPS, etc.).
  static const Map<String, List<String>> fieldSelectors = {
    'name': [
      // Sura patterns
      "document.querySelector('.nombre-paciente')?.textContent",
      "document.querySelector('h1.welcome')?.textContent",
      // Sanitas patterns
      "document.querySelector('.profile-name')?.textContent",
      "document.querySelector('.patient-fullname')?.textContent",
      // Nueva EPS patterns
      "document.querySelector('#nombreCompleto')?.textContent",
      "document.querySelector('.datos-afiliado .nombre')?.textContent",
      // Generic
      "document.querySelector('[data-field=\"nombre\"]')?.textContent",
      "document.querySelector('.user-name')?.textContent",
      "document.querySelector('.name')?.textContent",
    ],
    'documentId': [
      "document.querySelector('.documento')?.textContent",
      "document.querySelector('#nroDocumento')?.textContent",
      "document.querySelector('.cedula')?.textContent",
      "document.querySelector('[data-field=\"documento\"]')?.textContent",
      "document.querySelector('.identification')?.textContent",
      "document.querySelector('.id-number')?.textContent",
    ],
    'birthDate': [
      "document.querySelector('.fecha-nacimiento')?.textContent",
      "document.querySelector('#fechaNacimiento')?.textContent",
      "document.querySelector('.birth-date')?.textContent",
      "document.querySelector('[data-field=\"nacimiento\"]')?.textContent",
    ],
    'affiliationType': [
      "document.querySelector('.tipo-afiliado')?.textContent",
      "document.querySelector('.regimen')?.textContent",
      "document.querySelector('.plan-type')?.textContent",
    ],
  };

  /// Known API paths that return patient JSON data.
  /// Tried after DOM scraping fails to find data.
  static const List<String> apiPaths = [
    '/api/afiliado/perfil',
    '/api/v1/paciente',
    '/api/beneficiario/datos',
    '/api/me',
    '/api/user/profile',
    '/api/patient',
  ];

  /// Runs all scrapers in the authenticated WebView session.
  Future<Map<String, dynamic>> scrape(InAppWebViewController controller) async {
    final results = <String, dynamic>{};

    // Phase 1: DOM scraping via CSS selectors
    for (final entry in fieldSelectors.entries) {
      final field = entry.key;
      for (int i = 0; i < entry.value.length; i++) {
        try {
          final jsCode = entry.value[i];
          final value = await controller.evaluateJavascript(source: jsCode);
          if (value != null && value.toString().trim().isNotEmpty) {
            final cleaned = _cleanValue(value.toString());
            if (cleaned.isNotEmpty) {
              results[field] = cleaned;
              _scrapedFields.add('$field (selector ${i + 1})');
              break; // Found it, stop trying more selectors
            }
          }
        } catch (_) {
          // Selector not found on this page, try the next one
        }
      }
    }

    // Phase 2: Try API endpoints if DOM scraping missed key fields
    if (!results.containsKey('name') || !results.containsKey('documentId')) {
      for (final path in apiPaths) {
        try {
          final json = await controller.evaluateJavascript(source: '''
            (async function() {
              try {
                const r = await fetch('$path', { credentials: 'include' });
                if (r.ok) {
                  const data = await r.json();
                  return JSON.stringify(data);
                }
                return null;
              } catch(e) { return null; }
            })()
          ''');

          if (json != null && json.toString().isNotEmpty) {
            results['apiData'] = json.toString();

            // Try to extract name and document from JSON
            if (!results.containsKey('name')) {
              final nameFromJson =
                  await _extractJsonField(controller, json.toString(), [
                'nombre',
                'name',
                'nombreCompleto',
                'fullName',
                'paciente',
                'patient'
              ]);
              if (nameFromJson != null) results['name'] = nameFromJson;
            }

            if (!results.containsKey('documentId')) {
              final docFromJson =
                  await _extractJsonField(controller, json.toString(), [
                'documento',
                'cedula',
                'identificacion',
                'documentId',
                'nroDocumento'
              ]);
              if (docFromJson != null) results['documentId'] = docFromJson;
            }

            _scrapedFields.add('api:$path');
            break; // Got API data, stop trying more paths
          }
        } catch (_) {
          _errors.add('API $path: failed');
        }
      }
    }

    // Phase 3: Full page text as last resort for manual parsing
    if (!results.containsKey('name')) {
      try {
        final pageText = await controller.evaluateJavascript(
            source: 'document.body ? document.body.innerText : ""');
        if (pageText != null && pageText.toString().isNotEmpty) {
          results['rawPageText'] = pageText.toString().substring(
              0, pageText.toString().length.clamp(0, 5000));
        }
      } catch (_) {}
    }

    return results;
  }

  /// Extracts a field value from a JSON string by trying multiple key paths.
  Future<String?> _extractJsonField(
      InAppWebViewController controller, String jsonStr, List<String> keys) async {
    for (final key in keys) {
      try {
        final value = await controller.evaluateJavascript(source: '''
          (function() {
            try {
              const data = JSON.parse('${jsonStr.replaceAll("'", "\\'")}');
              let val = data['$key'];
              if (val && typeof val === 'object') {
                val = val.valor || val.value || val.nombre || val.name;
              }
              return val ? String(val) : '';
            } catch(e) { return ''; }
          })()
        ''');
        if (value != null && value.toString().trim().isNotEmpty) {
          return _cleanValue(value.toString());
        }
      } catch (_) {}
    }
    return null;
  }

  String _cleanValue(String raw) {
    return raw
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\S\r\n]+'), ' ')
        .trim();
  }
}

/// Tracks scraping progress for UI display.
class ScrapingProgress {
  final double progress;
  final String step;
  final String message;

  const ScrapingProgress({
    required this.progress,
    required this.step,
    required this.message,
  });

  factory ScrapingProgress.initial() => const ScrapingProgress(
        progress: 0.0,
        step: 'Preparando',
        message: 'Analizando el portal de la EPS...',
      );

  factory ScrapingProgress.scraping(String field) => ScrapingProgress(
        progress: 0.3,
        step: 'Extrayendo',
        message: 'Buscando $field...',
      );

  factory ScrapingProgress.processing() => const ScrapingProgress(
        progress: 0.7,
        step: 'Procesando',
        message: 'Organizando tus datos de salud...',
      );

  factory ScrapingProgress.done() => const ScrapingProgress(
        progress: 1.0,
        step: 'Completado',
        message: 'Datos importados exitosamente.',
      );
}
