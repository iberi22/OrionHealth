import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/presentation/widgets/medication_list_tile.dart';
import 'package:orionhealth_health/core/theme/app_colors.dart';

void main() {
  final testDate = DateTime(2023, 10, 27);
  final formattedDate = DateFormat('dd MMM yyyy').format(testDate);

  group('MedicationListTile', () {
    testWidgets('renders all medication details correctly when active', (WidgetTester tester) async {
      final medication = Medication(
        id: 1,
        name: 'Paracetamol',
        dosage: '500mg',
        frequency: 'Cada 8 horas',
        startDate: testDate,
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationListTile(
              medication: medication,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Paracetamol'), findsOneWidget);
      expect(find.text('500mg'), findsOneWidget);
      expect(find.text('Cada 8 horas'), findsOneWidget);
      expect(find.text(formattedDate), findsOneWidget);
      expect(find.text('ACTIVO'), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.medication));
      expect(icon.color, AppColors.primary);
    });

    testWidgets('renders correctly when inactive', (WidgetTester tester) async {
      final medication = Medication(
        id: 1,
        name: 'Ibuprofeno',
        dosage: '400mg',
        frequency: 'Cada 12 horas',
        startDate: testDate,
        isActive: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationListTile(
              medication: medication,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Ibuprofeno'), findsOneWidget);
      expect(find.text('INACTIVO'), findsOneWidget);

      final nameText = tester.widget<Text>(find.text('Ibuprofeno'));
      expect(nameText.style?.decoration, TextDecoration.lineThrough);

      final icon = tester.widget<Icon>(find.byIcon(Icons.medication));
      expect(icon.color, Colors.grey);
    });

    testWidgets('renders fallback for frequency when null', (WidgetTester tester) async {
      final medication = Medication(
        id: 1,
        name: 'Aspirina',
        startDate: testDate,
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationListTile(
              medication: medication,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sin frecuencia especificada'), findsOneWidget);
    });

    testWidgets('triggers onTap callback', (WidgetTester tester) async {
      bool tapped = false;
      final medication = Medication(
        id: 1,
        name: 'Paracetamol',
        startDate: testDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MedicationListTile(
              medication: medication,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MedicationListTile));
      expect(tapped, isTrue);
    });
  });
}
