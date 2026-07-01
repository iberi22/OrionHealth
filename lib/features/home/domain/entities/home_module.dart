// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class HomeModule extends Equatable {
  final String title;
  final int iconCode;
  final String? iconFontFamily;
  final String? iconFontPackage;
  final Color color;
  final String route;

  const HomeModule({
    required this.title,
    required this.iconCode,
    this.iconFontFamily,
    this.iconFontPackage,
    required this.color,
    required this.route,
  });

  @override
  List<Object?> get props => [
    title,
    iconCode,
    iconFontFamily,
    iconFontPackage,
    color,
    route,
  ];
}
