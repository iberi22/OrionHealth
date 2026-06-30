// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import '../../domain/entities/home_module.dart';

class HomeModuleModel extends HomeModule {
  const HomeModuleModel({
    required super.title,
    required super.iconCode,
    super.iconFontFamily,
    super.iconFontPackage,
    required super.color,
    required super.route,
  });

  factory HomeModuleModel.fromJson(Map<String, dynamic> json) {
    return HomeModuleModel(
      title: json['title'] as String,
      iconCode: json['icon'] as int,
      iconFontFamily: json['iconFontFamily'] as String?,
      iconFontPackage: json['iconFontPackage'] as String?,
      color: Color(json['color'] as int),
      route: json['route'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': iconCode,
      'iconFontFamily': iconFontFamily,
      'iconFontPackage': iconFontPackage,
      'color': color.toARGB32(),
      'route': route,
    };
  }

  factory HomeModuleModel.fromEntity(HomeModule entity) {
    return HomeModuleModel(
      title: entity.title,
      iconCode: entity.iconCode,
      iconFontFamily: entity.iconFontFamily,
      iconFontPackage: entity.iconFontPackage,
      color: entity.color,
      route: entity.route,
    );
  }
}
