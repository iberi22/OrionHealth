import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/onboarding_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class MedicationsStep extends StatefulWidget {
  const MedicationsStep({super.key});

  @override
  State<MedicationsStep> createState() => _MedicationsStepState();
}

class _MedicationsStepState extends State<MedicationsStep> {
  final _medController = TextEditingController();
  final _allergyController = TextEditingController();
  final List<String> _medications = [];
  final List<String> _allergies = [];

  @override
  void dispose() { _medController.dispose(); _allergyController.dispose(); super.dispose(); }

  void _addMed(String med) {
    if (med.trim().isNotEmpty && !_medications.contains(med.trim())) {
      setState(() => _medications.add(med.trim()));
      _medController.clear();
      context.read<OnboardingCubit>().updateMedications(List.from(_medications));
    }
  }

  void _removeMed(String med) {
    setState(() => _medications.remove(med));
    context.read<OnboardingCubit>().updateMedications(List.from(_medications));
  }

  void _addAllergy(String allergy) {
    if (allergy.trim().isNotEmpty && !_allergies.contains(allergy.trim())) {
      setState(() => _allergies.add(allergy.trim()));
      _allergyController.clear();
      context.read<OnboardingCubit>().updateAllergies(List.from(_allergies));
    }
  }

  void _removeAllergy(String allergy) {
    setState(() => _allergies.remove(allergy));
    context.read<OnboardingCubit>().updateAllergies(List.from(_allergies));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Medicamentos y Alergias', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Lista los medicamentos que tomas actualmente y cualquier alergia known.',
              style: TextStyle(color: Colors.white.withAlpha(179))),
          const SizedBox(height: 32),
          const Text('Medicamentos actuales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          GlassmorphicCard(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _medController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nombre del medicamento...',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _addMed,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () => _addMed(_medController.text),
                ),
              ],
            ),
          ),
          if (_medications.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._medications.map((m) => _buildChip(m, AppColors.primary, () => _removeMed(m))),
          ],
          const SizedBox(height: 32),
          const Text('Alergias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          GlassmorphicCard(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _allergyController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Alergeno (medicamento, alimento...)...',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _addAllergy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.red),
                  onPressed: () => _addAllergy(_allergyController.text),
                ),
              ],
            ),
          ),
          if (_allergies.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._allergies.map((a) => _buildChip(a, Colors.red, () => _removeAllergy(a))),
          ],
          const SizedBox(height: 48),
          _navButtons(context),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Chip(
        label: Text(label), deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDelete,
        backgroundColor: color.withAlpha(51),
        deleteIconColor: color,
        labelStyle: const TextStyle(color: Colors.white),
        side: BorderSide(color: color.withAlpha(128)),
      ),
    );
  }

  Widget _navButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.read<OnboardingCubit>().previousStep(),
            child: const Text('Atrás'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.read<OnboardingCubit>().nextStep(),
            child: const Text('Siguiente', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
