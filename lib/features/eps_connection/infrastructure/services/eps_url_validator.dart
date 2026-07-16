import 'package:flutter/foundation.dart';

class EpsUrlValidator {
  EpsUrlValidator._();

  /// Checks if a [url] is allowed for a given [epsId].
  static bool isUrlAllowed(String url, String epsId) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final host = uri.host.toLowerCase();

    // Universal allowed hosts (Minsalud Sandbox and standard identity providers)
    final universalAllowedHosts = const [
      'sandbox.ihcecol.gov.co',
      'login.microsoftonline.com',
      'login.live.com',
      'accounts.google.com',
    ];

    if (universalAllowedHosts.contains(host)) {
      return true;
    }

    // EPS-specific allowed domains (precompiled configuration)
    final Map<String, List<String>> epsAllowedDomains = const {
      'EPS020': ['coosalud.com', 'coosalud.com.co'],
      'EPS037': ['nuevaeps.co', 'nuevaeps.com.co'],
      'EPS005': ['epssanitas.com', 'epssanitas.com.co', 'colsanitas.com'],
      'EPS025': ['epssura.com', 'epssura.com.co', 'sura.com', 'login.sura.com'],
      'EPS002': ['saludtotal.com.co', 'saludtotal.com'],
      'EPS008': ['compensar.com', 'compensarsalud.com'],
      'EPS017': ['famisanar.com.co', 'famisanar.com'],
    };

    final allowedDomains = epsAllowedDomains[epsId];
    if (allowedDomains == null) {
      // If we don't have specific rules for this EPS, deny external hosts
      return false;
    }

    for (final domain in allowedDomains) {
      if (host == domain || host.endsWith('.$domain')) {
        return true;
      }
    }

    return false;
  }
}
