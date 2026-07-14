import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/pages/eps_patient_portal_screen.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';

class MockInAppWebViewController extends Mock implements InAppWebViewController {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  final testProvider = EPSProvider(
    id: 'EPS025',
    name: 'EPS SURA',
    discoveryUrl: '',
    clientId: '',
    redirectUrl: '',
    scopes: [],
  );

  late MockFlutterSecureStorage mockStorage;
  late MockInAppWebViewController mockController;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockController = MockInAppWebViewController();
    when(() => mockStorage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    when(() => mockStorage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
      iOptions: any(named: 'iOptions'),
      aOptions: any(named: 'aOptions'),
    )).thenAnswer((_) async => {});

    // Default mock for controller
    when(() => mockController.evaluateJavascript(source: any(named: 'source')))
        .thenAnswer((_) async => null);
  });

  testWidgets('EpsPatientPortalScreen renders initial state', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: EpsPatientPortalScreen(
            provider: testProvider,
            storage: mockStorage,
            webViewBuilder: (context, settings, onWebViewCreated, onLoadStop, onProgressChanged, shouldOverrideUrlLoading, shouldInterceptRequest, onReceivedError, initialUrl) {
              return const SizedBox.shrink(key: Key('mock_webview'));
            },
          ),
        ),
      );

      await tester.pump();

      expect(find.text('EPS SURA'), findsOneWidget);
      expect(find.textContaining('Portal seguro de EPS SURA'), findsOneWidget);
    });
  });

  testWidgets('EpsPatientPortalScreen shows instructions after load', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: EpsPatientPortalScreen(
            provider: testProvider,
            storage: mockStorage,
            webViewBuilder: (context, settings, onWebViewCreated, onLoadStop, onProgressChanged, shouldOverrideUrlLoading, shouldInterceptRequest, onReceivedError, initialUrl) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onLoadStop(mockController, WebUri(initialUrl));
              });
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Ingresa con tu documento y contraseña'), findsOneWidget);
    });
  });

  testWidgets('EpsPatientPortalScreen performs fallback DOM scraping when APIs fail', (WidgetTester tester) async {
    await tester.runAsync(() async {
      Map<String, dynamic>? popResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                popResult = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EpsPatientPortalScreen(
                      provider: testProvider,
                      storage: mockStorage,
                      webViewBuilder: (context, settings, onWebViewCreated, onLoadStop, onProgressChanged, shouldOverrideUrlLoading, shouldInterceptRequest, onReceivedError, initialUrl) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          onWebViewCreated(mockController);
                          onLoadStop(mockController, WebUri('https://portal.eps.com/dashboard'));
                        });
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Mock evaluateJavascript for:
      // 1. Probing (return nothing)
      // 2. DOM scraping (return data)
      when(() => mockController.evaluateJavascript(source: any(named: 'source')))
          .thenAnswer((invocation) async {
            final source = invocation.namedArguments[#source] as String;
            if (source.contains('fetch')) return ''; // API probe returns empty
            if (source.contains('const sels =')) {
              if (source.contains('.nombre-paciente')) return 'DOM Patient Name';
              if (source.contains('.documento')) return '987654321';
            }
            return '';
          });

      // Tap "Ya inicié sesión"
      await tester.tap(find.text('Ya inicié sesión'));

      // We need to pump several times because of the async scraping flow
      for(int i=0; i<10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(popResult, isNotNull);
      expect(popResult!['name'], 'DOM Patient Name');
      expect(popResult!['documentId'], '987654321');
    });
  });
}
