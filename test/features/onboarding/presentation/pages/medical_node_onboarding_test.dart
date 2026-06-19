import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/medical_node_onboarding.dart';

void main() {
  testWidgets('MedicalNodeOnboarding slides through steps', (tester) async {
    // Set larger surface size to avoid overflow errors in tests
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(
      home: MedicalNodeOnboarding(),
    ));

    expect(find.text('¿Qué es la Red Médica?'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Tus datos, seguros'), findsOneWidget);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Beneficios para ti'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    // The widget pops itself on the last page's "Entendido"
    expect(find.byType(MedicalNodeOnboarding), findsNothing);
  });

  testWidgets('MedicalNodeOnboarding close button pops', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(
      home: MedicalNodeOnboarding(),
    ));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(MedicalNodeOnboarding), findsNothing);
  });
}
