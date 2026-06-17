// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';

class MeditationTimer extends StatelessWidget {
  final int elapsedSeconds;

  const MeditationTimer({
    super.key,
    required this.elapsedSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(elapsedSeconds),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
