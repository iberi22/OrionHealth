import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/data_sources/presentation/pages/data_sources_config_page.dart';

void main() {
  testWidgets('config page renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DataSourcesConfigPage()));
    expect(find.byType(DataSourcesConfigPage), findsOneWidget);
  });

  testWidgets('config page has data sources text', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DataSourcesConfigPage()));
    expect(find.byType(DataSourcesConfigPage), findsOneWidget);
  });
}
