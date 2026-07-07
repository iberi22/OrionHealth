import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';
import 'package:orionhealth_health/features/data_sources/presentation/widgets/data_source_tile.dart';

void main() {
  group('DataSourceTile', () {
    final tDataSource = DataSource(
      id: '1',
      name: 'Google Fit',
      description: 'Health data from Google',
      type: DataSourceType.healthConnect,
      status: DataSourceStatus.disconnected,
    );

    Widget createWidgetUnderTest({
      required DataSource source,
      required VoidCallback onToggle,
      VoidCallback? onSync,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DataSourceTile(
            source: source,
            onToggle: onToggle,
            onSync: onSync,
          ),
        ),
      );
    }

    testWidgets('should render name and description', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        source: tDataSource,
        onToggle: () {},
      ));

      expect(find.text('Google Fit'), findsOneWidget);
      expect(find.text('Health data from Google'), findsOneWidget);
    });

    testWidgets('should show Switch OFF when status is disconnected', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        source: tDataSource.copyWith(status: DataSourceStatus.disconnected),
        onToggle: () {},
      ));

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('should show Switch ON and sync button when status is connected', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        source: tDataSource.copyWith(status: DataSourceStatus.connected),
        onToggle: () {},
        onSync: () {},
      ));

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('should NOT show sync button when status is connected but onSync is null', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        source: tDataSource.copyWith(status: DataSourceStatus.connected),
        onToggle: () {},
        onSync: null,
      ));

      expect(find.byIcon(Icons.sync), findsNothing);
    });

    testWidgets('should show CircularProgressIndicator when status is connecting', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        source: tDataSource.copyWith(status: DataSourceStatus.connecting),
        onToggle: () {},
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error icon when status is error', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        source: tDataSource.copyWith(status: DataSourceStatus.error),
        onToggle: () {},
      ));

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should show last sync time when available', (tester) async {
      final lastSync = DateTime(2023, 10, 27, 10, 30);
      await tester.pumpWidget(createWidgetUnderTest(
        source: tDataSource.copyWith(lastSync: lastSync),
        onToggle: () {},
      ));

      expect(find.textContaining('Last sync:'), findsOneWidget);
      expect(find.textContaining(lastSync.toLocal().toString()), findsOneWidget);
    });

    testWidgets('should call onToggle when switch is toggled', (tester) async {
      bool toggleCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        source: tDataSource,
        onToggle: () => toggleCalled = true,
      ));

      await tester.tap(find.byType(Switch));
      expect(toggleCalled, isTrue);
    });

    testWidgets('should call onSync when sync button is pressed', (tester) async {
      bool syncCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        source: tDataSource.copyWith(status: DataSourceStatus.connected),
        onToggle: () {},
        onSync: () => syncCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.sync));
      expect(syncCalled, isTrue);
    });
  });
}
