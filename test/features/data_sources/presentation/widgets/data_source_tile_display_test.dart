import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/data_sources/presentation/widgets/data_source_tile.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';

void main() {
  testWidgets('tile shows name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DataSourceTile(source: DataSourceEntity(name: 'Test', type: DataSourceType.file)))),
    );
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('tile shows type', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DataSourceTile(source: DataSourceEntity(name: 'Test', type: DataSourceType.file)))),
    );
    expect(find.byType(DataSourceTile), findsOneWidget);
  });
}
