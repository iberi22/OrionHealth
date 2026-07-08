import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/doctor_card.dart';

void main() {
  testWidgets('DoctorCard golden test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DoctorCard())),
    );
    await expectLater(
      find.byType(DoctorCard),
      matchesGoldenFile('goldens/doctor_card.png'),
    );
  });
}
