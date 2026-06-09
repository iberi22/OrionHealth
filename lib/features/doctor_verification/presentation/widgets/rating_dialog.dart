import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../domain/entities/doctor_rating.dart';

class RatingDialog extends StatefulWidget {
  final String doctorId;
  final Function(DoctorRating) onSubmitted;

  const RatingDialog({
    super.key,
    required this.doctorId,
    required this.onSubmitted,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isAnonymous = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0D1117),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: CyberTheme.primary, width: 0.5),
      ),
      title: const Text(
        'Calificar Médico',
        style: TextStyle(color: CyberTheme.primary, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Cómo fue tu experiencia?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tu comentario (opcional)',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (val) => setState(() => _isAnonymous = val ?? false),
                  activeColor: CyberTheme.primary,
                ),
                const Text('Publicar de forma anónima', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: () {
            final rating = DoctorRating(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              doctorId: widget.doctorId,
              overallScore: _rating,
              categoriesJson: '{}', // Placeholder
              comment: _commentController.text.isEmpty ? null : _commentController.text,
              createdAt: DateTime.now(),
              isAnonymous: _isAnonymous,
              verifiedVisit: true,
            );
            widget.onSubmitted(rating);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: CyberTheme.primary),
          child: const Text('ENVIAR', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
