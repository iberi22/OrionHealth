// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/error_boundary.dart';

void main() {
  group('ErrorBoundary', () {
    testWidgets('renders child when no error occurs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorBoundary(
            child: Text('Safe Content'),
          ),
        ),
      );

      expect(find.text('Safe Content'), findsOneWidget);
      expect(find.text('Algo salió mal'), findsNothing);
    });

    testWidgets('renders error UI when child throws during build', (tester) async {
      final originalOnError = FlutterError.onError;
      final originalBuilder = ErrorWidget.builder;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: Builder(
              builder: (context) {
                throw Exception('Test build error');
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Algo salió mal'), findsOneWidget);
      expect(find.text('Ocurrió un error inesperado. Puedes reiniciar la aplicación.'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalBuilder;
    });

    testWidgets('uses custom error builder if provided', (tester) async {
      final originalOnError = FlutterError.onError;
      final originalBuilder = ErrorWidget.builder;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorBuilder: (context, error) => const Scaffold(
              body: Text('Custom Error UI'),
            ),
            child: Builder(
              builder: (context) {
                throw Exception('Test build error');
              },
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Custom Error UI'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalBuilder;
    });
  });
}
