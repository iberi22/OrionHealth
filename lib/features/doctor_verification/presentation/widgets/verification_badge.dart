import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final bool isVerified;
  final double fontSize;
  final double iconSize;

  const VerificationBadge({
    super.key,
    required this.isVerified,
    this.fontSize = 12,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isVerified ? Icons.verified : Icons.warning_amber_rounded,
          size: iconSize,
          color: isVerified ? Colors.greenAccent : Colors.orangeAccent,
        ),
        const SizedBox(width: 4),
        Text(
          isVerified ? 'Verificado' : 'Sin verificar',
          style: TextStyle(
            fontSize: fontSize,
            color: isVerified ? Colors.greenAccent : Colors.orangeAccent,
          ),
        ),
      ],
    );
  }
}
