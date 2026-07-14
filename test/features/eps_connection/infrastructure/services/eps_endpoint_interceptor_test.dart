import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/eps_endpoint_interceptor.dart';

class MockInAppWebViewController extends Mock implements InAppWebViewController {}
class MockWebResourceRequest extends Mock implements WebResourceRequest {}

void main() {
  late EpsEndpointInterceptor interceptor;
  late MockInAppWebViewController mockController;
  const epsId = 'test_eps';
  const portalUrl = 'https://portal.eps.com';

  setUp(() {
    interceptor = EpsEndpointInterceptor(epsId: epsId, epsPortalUrl: portalUrl);
    mockController = MockInAppWebViewController();
  });

  group('EpsEndpointInterceptor', () {
    test('interceptRequest captures auth token and catalogs endpoints', () {
      interceptor.startInterception();

      final mockRequest = MockWebResourceRequest();
      when(() => mockRequest.url).thenReturn(WebUri('https://api.eps.com/fhir/Patient'));
      when(() => mockRequest.method).thenReturn('GET');
      when(() => mockRequest.headers).thenReturn({
        'Authorization': 'Bearer test_token',
        'X-Requested-With': 'XMLHttpRequest',
      });

      interceptor.interceptRequest(mockRequest);

      expect(interceptor.authToken, 'Bearer test_token');
      expect(interceptor.discoveredCount, 1);

      final endpoint = interceptor.discoveredEndpoints.first;
      expect(endpoint.url, 'https://api.eps.com/fhir/Patient');
      expect(endpoint.category, 'fhir');
    });

    test('interceptRequest ignores assets', () {
      interceptor.startInterception();

      final mockRequest = MockWebResourceRequest();
      when(() => mockRequest.url).thenReturn(WebUri('https://portal.eps.com/style.css'));
      when(() => mockRequest.method).thenReturn('GET');
      when(() => mockRequest.headers).thenReturn({});

      interceptor.interceptRequest(mockRequest);

      expect(interceptor.discoveredCount, 0);
    });

    test('categorizeEndpoint correctly identifies categories', () {
      interceptor.startInterception();

      final testCases = {
        'https://api.com/fhir/Patient': 'fhir',
        'https://api.com/v1/perfil': 'profile',
        'https://api.com/citas/pendientes': 'appointments',
        'https://api.com/history/clinical': 'clinicalHistory',
        'https://api.com/medicamentos/all': 'medications',
        'https://api.com/vacunas/list': 'immunizations',
        'https://api.com/diagnosticos/current': 'conditions',
        'https://api.com/api/other': 'unknown',
      };

      testCases.forEach((url, category) {
        final mockRequest = MockWebResourceRequest();
        when(() => mockRequest.url).thenReturn(WebUri(url));
        when(() => mockRequest.method).thenReturn('GET');
        when(() => mockRequest.headers).thenReturn({});

        interceptor.interceptRequest(mockRequest);
      });

      expect(interceptor.discoveredCount, testCases.length);
      for (final entry in testCases.entries) {
        final ep = interceptor.discoveredEndpoints.firstWhere((e) => e.url == entry.key);
        expect(ep.category, entry.value, reason: 'URL ${entry.key} should be categorized as ${entry.value}');
      }
    });

    test('probeDiscoveredEndpoints extracts patient data from mocked responses', () async {
      // 1. Discover some endpoints
      interceptor.startInterception();
      final mockRequest = MockWebResourceRequest();
      when(() => mockRequest.url).thenReturn(WebUri('https://api.eps.com/profile'));
      when(() => mockRequest.method).thenReturn('GET');
      when(() => mockRequest.headers).thenReturn({});
      interceptor.interceptRequest(mockRequest);

      // 2. Mock JS evaluation for probing
      final profileResponse = jsonEncode({
        'ok': true,
        'type': 'json',
        'url': 'https://api.eps.com/profile',
        'category': 'profile',
        'data': {
          'nombreCompleto': 'John Doe',
          'identificacion': '12345678',
          'fechaNacimiento': '1990-01-01',
          'genero': 'M',
        }
      });

      when(() => mockController.evaluateJavascript(source: any(named: 'source')))
          .thenAnswer((invocation) async {
            final source = invocation.namedArguments[#source] as String;
            if (source.contains('https://api.eps.com/profile')) {
              return profileResponse;
            }
            return jsonEncode({'ok': false});
          });

      final patientData = await interceptor.probeDiscoveredEndpoints(mockController);

      expect(patientData['name'], 'John Doe');
      expect(patientData['documentId'], '12345678');
      expect(patientData['birthDate'], '1990-01-01');
      expect(patientData['sex'], 'M');
    });

    test('probeDiscoveredEndpoints extracts lists (meds, conditions)', () async {
      interceptor.startInterception();
      final mockRequest = MockWebResourceRequest();
      when(() => mockRequest.url).thenReturn(WebUri('https://api.eps.com/clinical/history'));
      when(() => mockRequest.method).thenReturn('GET');
      when(() => mockRequest.headers).thenReturn({});
      interceptor.interceptRequest(mockRequest);

      final clinicalResponse = jsonEncode({
        'ok': true,
        'type': 'json',
        'url': 'https://api.eps.com/clinical/history',
        'category': 'clinicalHistory',
        'data': {
          'medicamentos': ['Aspirina', 'Metformina'],
          'diagnosticos': ['Hipertensión', 'Diabetes'],
          'alergias': ['Polen'],
        }
      });

      when(() => mockController.evaluateJavascript(source: any(named: 'source')))
          .thenAnswer((invocation) async {
             final source = invocation.namedArguments[#source] as String;
             if (source.contains('https://api.eps.com/clinical/history')) {
               return clinicalResponse;
             }
             return jsonEncode({'ok': false});
          });

      final patientData = await interceptor.probeDiscoveredEndpoints(mockController);

      expect(patientData['medications'], containsAll(['Aspirina', 'Metformina']));
      expect(patientData['conditions'], containsAll(['Hipertensión', 'Diabetes']));
      expect(patientData['allergies'], containsAll(['Polen']));
    });

    test('probeDiscoveredEndpoints handles API failures gracefully', () async {
      interceptor.startInterception();
      final mockRequest = MockWebResourceRequest();
      when(() => mockRequest.url).thenReturn(WebUri('https://api.eps.com/fail'));
      when(() => mockRequest.method).thenReturn('GET');
      when(() => mockRequest.headers).thenReturn({});
      interceptor.interceptRequest(mockRequest);

      // Mock JS evaluation to return an error object
      when(() => mockController.evaluateJavascript(source: any(named: 'source')))
          .thenAnswer((invocation) async {
            final source = invocation.namedArguments[#source] as String;
            if (source.contains('https://api.eps.com/fail')) {
              return jsonEncode({'ok': false, 'error': 'Network error'});
            }
            return null; // For common paths
          });

      final patientData = await interceptor.probeDiscoveredEndpoints(mockController);

      // Should be empty but not throw
      expect(patientData, isEmpty);
    });

    test('probeDiscoveredEndpoints continues after partial API failure', () async {
      interceptor.startInterception();

      // 1. Discover two endpoints (one profile which has higher priority)
      final mockReq1 = MockWebResourceRequest();
      when(() => mockReq1.url).thenReturn(WebUri('https://api.eps.com/fail'));
      when(() => mockReq1.method).thenReturn('GET');
      when(() => mockReq1.headers).thenReturn({});
      interceptor.interceptRequest(mockReq1);

      final mockReq2 = MockWebResourceRequest();
      when(() => mockReq2.url).thenReturn(WebUri('https://api.eps.com/profile-success'));
      when(() => mockReq2.method).thenReturn('GET');
      when(() => mockReq2.headers).thenReturn({});
      interceptor.interceptRequest(mockReq2);

      // 2. Mock JS: first fails, second succeeds
      when(() => mockController.evaluateJavascript(source: any(named: 'source')))
          .thenAnswer((invocation) async {
            final source = invocation.namedArguments[#source] as String;
            if (source.contains('https://api.eps.com/fail')) {
              return jsonEncode({'ok': false});
            }
            if (source.contains('https://api.eps.com/profile-success')) {
              return jsonEncode({
                'ok': true,
                'type': 'json',
                'url': 'https://api.eps.com/profile-success',
                'data': {'nombre': 'Recovered Name'}
              });
            }
            return null;
          });

      final patientData = await interceptor.probeDiscoveredEndpoints(mockController);

      expect(patientData['name'], 'Recovered Name');
    });

    test('probeDiscoveredEndpoints tries common API paths if none discovered', () async {
      // No endpoints discovered
      interceptor.startInterception();

      when(() => mockController.evaluateJavascript(source: any(named: 'source')))
          .thenAnswer((invocation) async {
            final source = invocation.namedArguments[#source] as String;
            if (source.contains('/api/afiliado/perfil')) {
              return jsonEncode({
                'ok': true,
                'type': 'json',
                'url': '/api/afiliado/perfil',
                'data': {'nombre': 'Common Path Patient'}
              });
            }
            return null;
          });

      final patientData = await interceptor.probeDiscoveredEndpoints(mockController);

      expect(patientData['name'], 'Common Path Patient');
    });
  });
}
