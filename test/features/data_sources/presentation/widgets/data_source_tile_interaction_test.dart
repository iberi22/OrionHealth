import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/data_sources/presentation/widgets/data_source_tile.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';

void main() {
  testWidgets('tile is tappable', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DataSourceTile(
        source: DataSourceEntity(name: 'Test', type: DataSourceType.file),
        onTap: () => tapped = true,
      ))),
    );
    await tester.tap(find.byType(DataSourceTile));
    expect(tapped, isTrue);
  });

  testWidgets('tile shows enabled state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DataSourceTile(
        source: DataSourceEntity(name: 'Test', type: DataSourceType.file),
        isEnabled: true,
      ))),
    );
    expect(find.byType(DataSourceTile), findsOneWidget);
  });
}
