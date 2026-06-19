// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/privacy_policy_page.dart';

void main() {
  testWidgets('PrivacyPolicyPage renders correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyPage()));

    // It uses FutureBuilder, so first pump shows loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Política de Privacidad'), findsOneWidget);
    expect(find.textContaining('Bienvenido a Orion'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);
  });

  testWidgets('PrivacyPolicyPage back button works', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
          ),
          child: const Text('Open'),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(PrivacyPolicyPage), findsOneWidget);

    // Navigate back using the physical back button or appBar leading
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // Animation time

    expect(find.byType(PrivacyPolicyPage), findsNothing);
  });
}
