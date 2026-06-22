import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/utils/icon_fallbacks.dart';

void main() {
  group('IconFallbacks', () {
    testWidgets('getFallbackIcon returns Text widget for known icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconFallbacks.getFallbackIcon(const IconData(0xe8b8, fontFamily: 'MaterialIcons')),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
      expect(find.text('🧠'), findsOneWidget);
    });

    testWidgets('getFallbackIcon returns Container for unknown icon', (tester) async {
      const unknownIcon = IconData(0x1234, fontFamily: 'MaterialIcons');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconFallbacks.getFallbackIcon(unknownIcon),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('smartIcon renders Icon by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconFallbacks.smartIcon(Icons.add),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('IconData extensions work correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const IconData(0xe8b8, fontFamily: 'MaterialIcons').toSmartIcon(),
                const IconData(0xe029, fontFamily: 'MaterialIcons').toFallbackIcon(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsNWidgets(1)); // toSmartIcon
      expect(find.text('🎤'), findsOneWidget); // toFallbackIcon
    });
  });
}
