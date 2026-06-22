import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/config/environment.dart';

void main() {
  group('AppEnvironment', () {
    test('development environment properties', () {
      const env = AppEnvironment.development;
      expect(env.label, 'DEV');
      expect(env.verboseLogging, isTrue);
      expect(env.fhirBaseUrl, 'http://localhost:8080/fhir');
      expect(env.aiBaseUrl, 'http://localhost:8000');
      expect(env.cmsBaseUrl, 'http://localhost:3000');
      expect(env.enableCrashReporting, isFalse);
      expect(env.enablePerformanceMonitor, isTrue);
      expect(env.showDebugBanner, isTrue);
    });

    test('staging environment properties', () {
      const env = AppEnvironment.staging;
      expect(env.label, 'STAGING');
      expect(env.verboseLogging, isTrue);
      expect(env.fhirBaseUrl, 'https://staging-api.orionhealth.app/fhir');
      expect(env.aiBaseUrl, 'https://staging-ai.orionhealth.app');
      expect(env.cmsBaseUrl, 'https://staging-api.orionhealth.app');
      expect(env.enableCrashReporting, isFalse);
      expect(env.enablePerformanceMonitor, isTrue);
      expect(env.showDebugBanner, isFalse);
    });

    test('production environment properties', () {
      const env = AppEnvironment.production;
      expect(env.label, 'PROD');
      expect(env.verboseLogging, isFalse);
      expect(env.fhirBaseUrl, 'https://api.orionhealth.app/fhir');
      expect(env.aiBaseUrl, 'https://ai.orionhealth.app');
      expect(env.cmsBaseUrl, 'https://api.orionhealth.app');
      expect(env.enableCrashReporting, isTrue);
      expect(env.enablePerformanceMonitor, isFalse);
      expect(env.showDebugBanner, isFalse);
    });

    test('current environment returns development by default in tests', () {
      // kReleaseMode and kProfileMode are false in standard tests
      expect(AppEnvironment.current, AppEnvironment.development);
    });
  });
}
