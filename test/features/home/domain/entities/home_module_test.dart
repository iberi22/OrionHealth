import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_module.dart';

void main() {
  group('HomeModule', () {
    test('should support value equality', () {
      final module1 = HomeModule(
        title: 'Title',
        iconCode: Icons.add.codePoint,
        color: Colors.red,
        route: '/route',
      );
      final module2 = HomeModule(
        title: 'Title',
        iconCode: Icons.add.codePoint,
        color: Colors.red,
        route: '/route',
      );

      expect(module1, equals(module2));
    });

    test('should have correct props', () {
      final module = HomeModule(
        title: 'Title',
        iconCode: Icons.add.codePoint,
        iconFontFamily: 'MaterialIcons',
        iconFontPackage: 'package',
        color: Colors.red,
        route: '/route',
      );

      expect(module.props, [
        'Title',
        Icons.add.codePoint,
        'MaterialIcons',
        'package',
        Colors.red,
        '/route',
      ]);
    });
  });
}
