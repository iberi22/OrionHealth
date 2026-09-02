// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/swal_responsive.dart';
import '../../domain/entities/home_module.dart';

class ModuleCards extends StatelessWidget {
  final List<HomeModule> modules;
  final Function(HomeModule) onModuleTap;

  const ModuleCards({
    super.key,
    required this.modules,
    required this.onModuleTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    // ignore_for_file: non_const_argument_for_const_parameter
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isCompact ? 2 : 3,
        crossAxisSpacing: SWALSpacing.md,
        mainAxisSpacing: SWALSpacing.md,
        childAspectRatio: isCompact ? 1.1 : 1.2,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _ModuleCard(
          module: module,
          onTap: () => onModuleTap(module),
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final HomeModule module;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.module,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconData(
                module.iconCode,
                fontFamily: module.iconFontFamily ?? 'MaterialIcons',
                fontPackage: module.iconFontPackage,
              ),
              color: module.color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              module.title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: SWALFonts.body,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
