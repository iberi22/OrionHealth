import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_monitor_page.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/core/di/injection.dart';

class MockBleSharingService extends Mock implements BleSharingService {}

void main() {
  late MockBleSharingService mockBleService;

  setUp(() {
    mockBleService = MockBleSharingService();
    getIt.allowReassignment = true;
    getIt.registerSingleton<BleSharingService>(mockBleService);

    when(() => mockBleService.initialize()).thenAnswer((_) async {});
  });

  tearDown(() {
    getIt.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: VitalsMonitorPage(),
    );
  }

  group('VitalsMonitorPage', () {
    testWidgets('shows initial state', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Vitals Monitor'), findsOneWidget);
      expect(find.text('--'), findsOneWidget); // Initial HR
      expect(find.text('Connect a clinical device\nto see live vitals'), findsOneWidget);
    });

    testWidgets('starts scanning and shows devices', (tester) async {
      final devices = [
        BleDevice(id: '1', name: 'Heart Monitor', type: 'HRM'),
      ];
      when(() => mockBleService.scanForDevices()).thenAnswer((_) async => devices);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Search Devices'));
      await tester.pump(); // Start scan

      await tester.pumpAndSettle();

      expect(find.text('Heart Monitor'), findsOneWidget);
      expect(find.text('Select a device to connect'), findsOneWidget);
    });

    testWidgets('connects to a device', (tester) async {
      final devices = [
        BleDevice(id: '1', name: 'Heart Monitor', type: 'HRM'),
      ];
      when(() => mockBleService.scanForDevices()).thenAnswer((_) async => devices);
      when(() => mockBleService.connect(any())).thenAnswer((_) async => true);
      when(() => mockBleService.startMedicalDataStream(any())).thenAnswer((_) async => {});

      await tester.runAsync(() async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Search Devices'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('CONNECT'));
        await tester.pump();

        // Wait for the status message to update
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.textContaining('Connected to Heart Monitor'), findsWidgets);
    });
  });
}
