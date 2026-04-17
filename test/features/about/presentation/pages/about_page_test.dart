import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/about/presentation/widgets/mission_section.dart';

void main() {
  testWidgets('AboutPage displays mission section and blog posts', (WidgetTester tester) async {
    // Set a larger surface size to ensure all widgets are laid out and potentially visible if needed by finders
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: AboutPage(),
      ),
    );

    // Check if the title is present
    expect(find.text('Sobre OrionHealth'), findsOneWidget);

    // Check if MissionSection is present
    expect(find.byType(MissionSection), findsOneWidget);

    // Scroll down to find the blog section if it's not in view
    await tester.scrollUntilVisible(find.text('Nuestro Blog de Salud'), 500.0);

    // Check if blog section header is present
    expect(find.text('Nuestro Blog de Salud'), findsOneWidget);

    // Check if at least one blog post title is present
    expect(find.text('Avances médicos que impactan tu salud'), findsOneWidget);

    // Reset view
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
