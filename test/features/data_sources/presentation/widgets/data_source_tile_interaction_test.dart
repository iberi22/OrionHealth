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

  group('DataSourceTile Interaction', () {
    testWidgets('calls onToggle when switch is flipped', (WidgetTester tester) async {
      bool toggled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataSourceTile(
              source: testSource,
              onToggle: () => toggled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      expect(toggled, isTrue);
    });

    testWidgets('calls onSync when sync button is pressed', (WidgetTester tester) async {
      bool synced = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataSourceTile(
              source: testSource.copyWith(status: DataSourceStatus.connected),
              onToggle: () {},
              onSync: () => synced = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.sync));
      expect(synced, isTrue);
    });
  });
}
