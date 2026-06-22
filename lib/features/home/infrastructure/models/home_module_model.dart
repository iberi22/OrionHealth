// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import '../../domain/entities/home_module.dart';

class HomeModuleModel extends HomeModule {
  const HomeModuleModel({
    required super.title,
    required super.icon,
    required super.color,
    required super.route,
  });

  factory HomeModuleModel.fromJson(Map<String, dynamic> json) {
    return HomeModuleModel(
      title: json['title'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      route: json['route'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon.codePoint,
      'color': color.value,
      'route': route,
    };
  }

  factory HomeModuleModel.fromEntity(HomeModule entity) {
    return HomeModuleModel(
      title: entity.title,
      icon: entity.icon,
      color: entity.color,
      route: entity.route,
    );
  }
}
