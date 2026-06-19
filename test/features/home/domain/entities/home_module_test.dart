import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_module.dart';

void main() {
  group('HomeModule', () {
    test('should support value equality', () {
      const module1 = HomeModule(
        title: 'Title',
        icon: Icons.add,
        color: Colors.red,
        route: '/route',
      );
      const module2 = HomeModule(
        title: 'Title',
        icon: Icons.add,
        color: Colors.red,
        route: '/route',
      );

      expect(module1, equals(module2));
    });

    test('should have correct props', () {
      const module = HomeModule(
        title: 'Title',
        icon: Icons.add,
        color: Colors.red,
        route: '/route',
      );

      expect(module.props, ['Title', Icons.add, Colors.red, '/route']);
    });
  });
}
