import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/widgets/share_card.dart';

void main() {
  group('ShareCard Widget Tests', () {
    testWidgets('should render correctly in inactive state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCard(
              method: TransferMethod.nfc,
              categories: const {DataCategory.labResults, DataCategory.vitalSigns},
              isSharing: false,
              onShare: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Compartir vía NFC'), findsOneWidget);
      expect(find.text('2 categorías seleccionadas'), findsOneWidget);
      expect(find.text('Compartir Ahora'), findsOneWidget);
      expect(find.byIcon(Icons.nfc), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Cancelar'), findsNothing);
    });

    testWidgets('should render correctly in active sharing state', (tester) async {
      const statusMsg = 'Enviando datos...';
      const progress = 0.45;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCard(
              method: TransferMethod.ble,
              categories: const {DataCategory.medications},
              isSharing: true,
              progress: progress,
              statusMessage: statusMsg,
              onShare: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Compartir vía Bluetooth'), findsOneWidget);
      expect(find.text(statusMsg), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      expect(progressIndicator.value, progress);

      expect(find.text('Compartir Ahora'), findsNothing);
    });

    testWidgets('should call onShare when button is pressed', (tester) async {
      bool shareCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCard(
              method: TransferMethod.wifi,
              categories: const {DataCategory.labResults},
              isSharing: false,
              onShare: () => shareCalled = true,
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Compartir Ahora'));
      expect(shareCalled, isTrue);
    });

    testWidgets('should call onCancel when cancel button is pressed', (tester) async {
      bool cancelCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCard(
              method: TransferMethod.wifi,
              categories: const {DataCategory.labResults},
              isSharing: true,
              onShare: () {},
              onCancel: () => cancelCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancelar'));
      expect(cancelCalled, isTrue);
    });

    testWidgets('should disable share button when no categories are selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCard(
              method: TransferMethod.nfc,
              categories: const {},
              isSharing: false,
              onShare: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      final shareButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Compartir Ahora')
      );
      expect(shareButton.onPressed, isNull);
    });
  });
}
