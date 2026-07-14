import 'package:flutter/material.dart';
import '../../domain/entities/home_module.dart';

/// Constant icon registry for tree-shaking compatibility.
/// Maps HomeModule icon codes to const IconData instances.
class ModuleIconRegistry {
  ModuleIconRegistry._();

  static const _iconMap = <int, IconData>{
    // Material Icons (default font)
    0xe000: Icons.home,
    0xe001: Icons.person,
    0xe002: Icons.medical_services,
    0xe003: Icons.calendar_month,
    0xe004: Icons.medication,
    0xe005: Icons.monitor_heart,
    0xe006: Icons.settings,
    0xe007: Icons.folder_shared,
    0xe008: Icons.vaccines,
    0xe009: Icons.psychology,
    0xe010: Icons.mic,
    0xe011: Icons.cloud_sync,
    0xe012: Icons.local_hospital,
    0xe013: Icons.verified_user,
    0xe014: Icons.science,
    0xe015: Icons.description,
    0xe016: Icons.assignment,
    0xe017: Icons.notifications,
    0xe018: Icons.favorite,
    0xe019: Icons.share,
    0xe01a: Icons.public,
    0xe01b: Icons.email,
    0xe01c: Icons.groups,
    0xe01d: Icons.self_improvement,
    0xe01e: Icons.security,
    0xe01f: Icons.health_and_safety,
  };

  /// Returns a const IconData for the given module, or a safe fallback.
  static IconData getIcon(HomeModule module) {
    return _iconMap[module.iconCode] ?? Icons.widgets;
  }
}
