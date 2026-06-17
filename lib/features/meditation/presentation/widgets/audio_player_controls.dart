// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';

class AudioPlayerControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePause;
  final VoidCallback onNext;

  const AudioPlayerControls({
    super.key,
    required this.isPlaying,
    required this.onPrevious,
    required this.onTogglePause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
          onPressed: onPrevious,
        ),
        const SizedBox(width: 24),
        FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: onTogglePause,
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: const Color(0xFF101828),
            size: 36,
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
          onPressed: onNext,
        ),
      ],
    );
  }
}
