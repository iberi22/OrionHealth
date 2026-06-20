import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final bool isVerified;

  const VerificationBadge({
    super.key,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.warning_amber_rounded,
            color: isVerified ? Colors.greenAccent : Colors.orangeAccent,
          ),
          const SizedBox(width: 8),
          Text(
            isVerified ? 'MÉDICO VERIFICADO' : 'PENDIENTE DE VERIFICACIÓN',
            style: TextStyle(
              color: isVerified ? Colors.greenAccent : Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
