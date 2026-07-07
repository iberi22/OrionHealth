import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MedicationEmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const MedicationEmptyView({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_liquid,
              size: 80, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          Text(
            'No hay medicamentos registrados',
            style: TextStyle(
                fontSize: 18, color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Medicamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
