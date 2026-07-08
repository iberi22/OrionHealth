import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_list_page.dart';

void main() {
  testWidgets('DoctorListPage golden test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DoctorListPage()),
    );
    await expectLater(
      find.byType(DoctorListPage),
      matchesGoldenFile('goldens/doctor_list_page.png'),
    );
  });
}
