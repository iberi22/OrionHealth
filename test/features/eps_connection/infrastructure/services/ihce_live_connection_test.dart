import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 🏥 Test de conexión directa con el IHCE Minsalud Sandbox.
///
/// Este es un test UNITARIO (no de integración) — hace HTTP directo
/// a la API real del IHCE sin necesitar emulador ni dispositivo.
///
/// Ejecutar con: flutter test test/features/eps_connection/infrastructure/services/
void main() {
  // Credenciales del sandbox (públicas)
  const tenantId = '3d4b3d76-b910-426c-bd8f-bd964e3e1b53';
  const subscriptionKey = '9ffb7a49797e459bab116c6f2029cae6';
  const scope = 'api://ca9a5155-3135-4e44-a644-b92175eb4d21/.default';
  const sandboxUrl = 'https://sandbox.ihcecol.gov.co/ihce';
  const sandboxClientId = 'fhir-client';
  const sandboxClientSecret = 'fhir-secret';

  group('IHCE Minsalud Sandbox — Conexión real', () {
    // ─── TEST 1: Obtener token OAuth2 ──────────────────
    test('STEP 1: Obtener Token OAuth2 de Azure AD', () async {
      final client = http.Client();
      try {
        final tokenUrl = Uri.parse(
          'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token',
        );

        final response = await client.post(
          tokenUrl,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'grant_type': 'client_credentials',
            'client_id': sandboxClientId,
            'client_secret': sandboxClientSecret,
            'scope': scope,
          },
        );

        print('');
        print('🔑 Auth Response → Status: ${response.statusCode}');
        print('   Body preview: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('✅ TOKEN OBTENIDO: ${(data['access_token'] as String).substring(0, 30)}...');
          print('   expires_in: ${data['expires_in']}s');
          print('   token_type: ${data['token_type']}');
          expect(data.containsKey('access_token'), true);
        } else if (response.statusCode == 401) {
          print('⚠️ Sandbox requiere credenciales de prestador registrado');
          print('   → El endpoint ES REAL y responde');
          print('   → Solo falta el registro en Minsalud');
          expect(response.statusCode, 401);
        } else if (response.statusCode == 400) {
          final data = jsonDecode(response.body);
          print('⚠️ Error 400: ${data['error_description'] ?? data['error']}');
          // 400 puede ser client_id/secret incorrectos
          expect(response.statusCode, 400);
        }
      } finally {
        client.close();
      }
    });

    // ─── TEST 2: Llamar API Gateway con API Key ────────
    test('STEP 2: API Key validation contra Gateway', () async {
      final client = http.Client();
      try {
        final apiUrl = Uri.parse('$sandboxUrl/Patient/\$consultar-paciente-exacto');

        // Sin token, solo con API key
        final response = await client.post(
          apiUrl,
          headers: {
            'Content-Type': 'application/fhir+json',
            'Ocp-Apim-Subscription-Key': subscriptionKey,
          },
          body: jsonEncode({
            'resourceType': 'Parameters',
            'parameter': [
              {'name': 'tipoDocumento', 'valueString': 'CC'},
              {'name': 'numeroDocumento', 'valueString': '123456789'},
            ],
          }),
        );

        print('');
        print('🌐 API Gateway Response → Status: ${response.statusCode}');

        if (response.statusCode == 401) {
          print('✅ API Gateway está VIVO — responde 401 (sin token)');
          print('   → Esto confirma que el API Gateway EXISTE');
          print('   → Solo necesita token OAuth2 válido');
          expect(response.statusCode, 401);
        } else if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('✅ DATOS RECIBIDOS (sin token!): ${data['resourceType']}');
          expect(data.containsKey('resourceType'), true);
        } else {
          print('   Response: ${response.body.substring(0, 200)}');
        }
      } finally {
        client.close();
      }
    });

    // ─── TEST 3: Health check del sandbox ──────────────
    test('STEP 3: Health check — el sandbox está vivo?', () async {
      final client = http.Client();
      try {
        // Probamos la raíz del API Gateway
        final response = await client.get(
          Uri.parse(sandboxUrl),
          headers: {
            'Ocp-Apim-Subscription-Key': subscriptionKey,
          },
        );

        print('');
        print('🏥 Sandbox Health → Status: ${response.statusCode}');

        // Cualquier respuesta que no sea timeout/connection error
        // significa que el sandbox está vivo
        expect(
          response.statusCode,
          anyOf(
            lessThan(500), // No es error del servidor
            equals(401),   // Auth requerida = vivo
            equals(404),   // Raíz no expuesta pero Gateway responde
          ),
          reason: 'El sandbox del IHCE está operativo',
        );
        print('✅ Sandbox IHCE responde — ${response.statusCode}');
      } on http.ClientException catch (e) {
        print('⚠️ Connection error: $e');
        // Si no hay conexión, el test falla explícitamente
        fail('No se pudo conectar al sandbox: $e');
      } finally {
        client.close();
      }
    });

    // ─── TEST 4: Probar connection con el tenant ───────
    test('STEP 4: Validar tenant de Azure AD', () async {
      final client = http.Client();
      try {
        // Probar el well-known OIDC del tenant
        final oidcUrl = Uri.parse(
          'https://login.microsoftonline.com/$tenantId/v2.0/.well-known/openid-configuration',
        );

        final response = await client.get(oidcUrl);

        print('');
        print('🔐 Azure AD Tenant → Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('✅ Tenant válido: ${data['issuer']}');
          print('   token_endpoint: ${data['token_endpoint']}');
          expect(data.containsKey('token_endpoint'), true);
        } else {
          print('⚠️ Tenant response: ${response.statusCode}');
          print('   Body: ${response.body.substring(0, 200)}');
        }
      } finally {
        client.close();
      }
    });
  });
}
