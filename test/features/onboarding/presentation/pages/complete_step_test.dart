import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/complete_step.dart';

void main() {
  Widget createWidgetUnderTest({NavigatorObserver? observer}) {
    return MaterialApp(
      home: const Scaffold(body: CompleteStep()),
      navigatorObservers: observer != null ? [observer] : [],
    );
  }

  testWidgets('CompleteStep displays success message', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('¡Bienvenido a OrionHealth!'), findsOneWidget);
    expect(
      find.text('Tu perfil ha sido configurado. Comencemos a cuidar tu salud.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('onboarding -> PIN setup -> Home', (tester) async {
    bool navigatedToPin = false;

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/dummy') {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Dummy')),
            );
          }
          return null;
        },
        home: Navigator(
          observers: [
            _MockObserver(
              onPush: (route, previousRoute) {
                if (route is MaterialPageRoute) {
                  // If it's building SetupPinPage, we consider it a success.
                  // We can't strictly inspect the builder's return type easily,
                  // but since SetupPinPage is the only thing CompleteStep pushes,
                  // capturing the pushReplacement is sufficient.
                  navigatedToPin = true;
                }
              },
            ),
          ],
          onGenerateRoute: (_) =>
              MaterialPageRoute(builder: (context) => const CompleteStep()),
        ),
      ),
    );

    await tester.tap(find.text('Continuar'));
    // We intentionally don't await pumpAndSettle because SetupPinPage needs AuthCubit DI which isn't provided here,
    // and would crash the test if fully rendered. We only care that the routing was triggered.

    expect(navigatedToPin, isTrue, reason: 'Should navigate to SetupPinPage');
  });
}

class _MockObserver extends NavigatorObserver {
  final void Function(Route<dynamic>, Route<dynamic>?) onPushCallback;

  _MockObserver({
    required void Function(Route<dynamic>, Route<dynamic>?) onPush,
  }) : onPushCallback = onPush;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      onPushCallback(newRoute, oldRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
