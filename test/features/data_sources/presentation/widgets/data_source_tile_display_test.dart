import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';
import 'package:orionhealth_health/features/data_sources/presentation/widgets/data_source_tile.dart';

void main() {
  const testSource = DataSource(
    id: '1',
    name: 'Test Source',
    description: 'Test Description',
    type: DataSourceType.file,
    status: DataSourceStatus.disconnected,
  );

  group('DataSourceTile Display', () {
    testWidgets('renders source name and description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataSourceTile(
              source: testSource,
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Source'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('shows sync button when connected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataSourceTile(
              source: testSource.copyWith(status: DataSourceStatus.connected),
              onToggle: () {},
              onSync: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('shows last sync time', (WidgetTester tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataSourceTile(
              source: testSource.copyWith(lastSync: now),
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Last sync:'), findsOneWidget);
    });

    testWidgets('shows error icon when status is error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataSourceTile(
              source: testSource.copyWith(status: DataSourceStatus.error),
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows progress indicator when status is connecting', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataSourceTile(
              source: testSource.copyWith(status: DataSourceStatus.connecting),
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
