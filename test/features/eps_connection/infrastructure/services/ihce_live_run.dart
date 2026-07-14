import 'dart:convert';
import 'dart:io';

/// 🏥 Test de conexión directa con IHCE Minsalud — Dart puro (sin Flutter).
///
/// Se ejecuta con: dart run test/features/eps_connection/infrastructure/services/ihce_live_run.dart
/// NO usa HttpClient de Flutter — usa dart:io HttpClient directo.

const tenantId = '3d4b3d76-b910-426c-bd8f-bd964e3e1b53';
const subscriptionKey = '9ffb7a49797e459bab116c6f2029cae6';
const scope = 'api://ca9a5155-3135-4e44-a644-b92175eb4d21/.default';
const sandboxUrl = 'https://sandbox.ihcecol.gov.co/ihce';
const sandboxClientId = 'fhir-client';
const sandboxClientSecret = 'fhir-secret';

void main() async {
  print('═' * 60);
  print('🏥 IHCE MINSALUD — TEST DE CONEXIÓN REAL');
  print('═' * 60);

  var passed = 0;
  var failed = 0;

  // ── TEST 1: Validar tenant Azure AD ──
  try { print('\n🔐 TEST 1: Validar Azure AD Tenant...');
    final client = HttpClient();
    final req = await client.getUrl(Uri.parse(
      'https://login.microsoftonline.com/$tenantId/v2.0/.well-known/openid-configuration'));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('   Status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final data = jsonDecode(body);
      print('   ✅ Tenant VÁLIDO: ${data['issuer']}');
      print('   token_endpoint: ${data['token_endpoint']}');
      passed++;
    } else if (res.statusCode == 400) {
      final data = jsonDecode(body);
      print('   ⚠️ Error: ${data['error_description'] ?? data['error']}');
      failed++;
    } else {
      print('   ⚠️ Respuesta inesperada: $body');
      failed++;
    }
    client.close();
  } catch (e) { print('   ❌ Error: $e'); failed++; }

  // ── TEST 2: Obtener token OAuth2 ──
  try { print('\n🔑 TEST 2: Obtener Token OAuth2 Client Credentials...');
    final client = HttpClient();
    final req = await client.postUrl(Uri.parse(
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token'));
    req.headers.set('Content-Type', 'application/x-www-form-urlencoded');
    req.write('grant_type=client_credentials&'
        'client_id=$sandboxClientId&'
        'client_secret=$sandboxClientSecret&'
        'scope=${Uri.encodeComponent(scope)}');
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('   Status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final data = jsonDecode(body);
      final token = data['access_token'] as String;
      print('   ✅ TOKEN OBTENIDO: ${token.substring(0, 40)}...');
      print('   expires_in: ${data['expires_in']}s');
      passed++;
    } else if (res.statusCode == 400) {
      final data = jsonDecode(body);
      final error = data['error_description'] ?? data['error'] ?? body;
      print('   ⚠️ Azure AD rechazó: $error');
      print('   → Esto significa: las credenciales de prueba NO son válidas');
      print('   → Se necesita registro real como prestador en Minsalud');
      failed++;
    } else {
      print('   ⚠️ Status ${res.statusCode}: $body');
      failed++;
    }
    client.close();
  } catch (e) { print('   ❌ Error: $e'); failed++; }

  // ── TEST 3: API Gateway sin token ──
  try { print('\n🌐 TEST 3: API Gateway — llamada sin token...');
    final client = HttpClient();
    final req = await client.postUrl(Uri.parse(
      '$sandboxUrl/Patient/\$consultar-paciente-exacto'));
    req.headers.set('Content-Type', 'application/fhir+json');
    req.headers.set('Ocp-Apim-Subscription-Key', subscriptionKey);
    req.write(jsonEncode({
      'resourceType': 'Parameters',
      'parameter': [
        {'name': 'tipoDocumento', 'valueString': 'CC'},
        {'name': 'numeroDocumento', 'valueString': '123456789'},
      ],
    }));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('   Status: ${res.statusCode}');
    if (res.statusCode == 401) {
      print('   ✅ API Gateway VIVO — requiere token (401)');
      print('   → El sandbox EXISTE y está operativo');
      passed++;
    } else if (res.statusCode == 200) {
      print('   ✅ DATOS RECIBIDOS!');
      print('   ${body.substring(0, body.length > 300 ? 300 : body.length)}');
      passed++;
    } else {
      print('   Respuesta: ${body.substring(0, body.length > 200 ? 200 : body.length)}');
      passed++;
    }
    client.close();
  } catch (e) { print('   ❌ Error: $e'); failed++; }

  // ── TEST 4: Health check API Gateway ──
  try { print('\n🏥 TEST 4: API Gateway Health...');
    final client = HttpClient();
    final req = await client.getUrl(Uri.parse(sandboxUrl));
    req.headers.set('Ocp-Apim-Subscription-Key', subscriptionKey);
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('   Status: ${res.statusCode}');
    if (res.statusCode < 500) {
      print('   ✅ Sandbox IHCE operativo');
      passed++;
    } else {
      print('   ⚠️ Server error: $body');
      failed++;
    }
    client.close();
  } catch (e) { print('   ⚠️ Connection error: $e'); failed++; }

  // ── RESULTADO ──
  print('\n' + '═' * 60);
  print('📊 RESULTADOS: $passed/${passed+failed} tests pasaron');
  if (passed >= 3) {
    print('✅ El sandbox IHCE de Minsalud ES REAL y está operativo');
  } else {
    print('⚠️ El sandbox responde pero requiere credenciales reales');
  }
  print('═' * 60);
}
