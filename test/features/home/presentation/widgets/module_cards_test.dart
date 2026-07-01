import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_module.dart';
import 'package:orionhealth_health/features/home/presentation/widgets/module_cards.dart';

void main() {
  final tModules = [
    HomeModule(
      title: 'Module 1',
      iconCode: Icons.add.codePoint,
      color: Colors.red,
      route: '/1',
    ),
    HomeModule(
      title: 'Module 2',
      iconCode: Icons.remove.codePoint,
      color: Colors.blue,
      route: '/2',
    ),
  ];

  testWidgets('displays modules correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModuleCards(
            modules: tModules,
            onModuleTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Module 1'), findsOneWidget);
    expect(find.text('Module 2'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
  });

  testWidgets('calls onModuleTap when a card is tapped', (tester) async {
    HomeModule? tappedModule;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModuleCards(
            modules: tModules,
            onModuleTap: (m) => tappedModule = m,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Module 1'));
    await tester.pump();

    expect(tappedModule, equals(tModules[0]));
  });
}
