import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/responsive/responsive_layout.dart';

void main() {
  group('ResponsiveLayout', () {
    testWidgets('renders mobile widget on small screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobile: Text('Mobile View'),
            desktop: Text('Desktop View'),
          ),
        ),
      );

      expect(find.text('Mobile View'), findsOneWidget);
      expect(find.text('Desktop View'), findsNothing);

      // Reset
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('renders tablet widget (or mobile fallback) on medium screens', (tester) async {
      // Test tablet widget
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobile: Text('Mobile View'),
            tablet: Text('Tablet View'),
            desktop: Text('Desktop View'),
          ),
        ),
      );
      expect(find.text('Tablet View'), findsOneWidget);

      // Test mobile fallback
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobile: Text('Mobile View'),
            desktop: Text('Desktop View'),
          ),
        ),
      );
      expect(find.text('Mobile View'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('renders desktop widget on large screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobile: Text('Mobile View'),
            desktop: Text('Desktop View'),
          ),
        ),
      );

      expect(find.text('Desktop View'), findsOneWidget);
      expect(find.text('Mobile View'), findsNothing);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
