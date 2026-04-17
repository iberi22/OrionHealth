import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/onboarding_cubit.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class ConditionsStep extends StatefulWidget {
  const ConditionsStep({super.key});

  @override
  State<ConditionsStep> createState() => _ConditionsStepState();
}

class _ConditionsStepState extends State<ConditionsStep> {
  final _controller = TextEditingController();
  final List<String> _conditions = [];

  static const _commonConditions = [
    'Diabetes', 'Hipertensión', 'Asma', 'Artritis',
    'Epilepsia', 'Cardiopatía', 'Cáncer', 'Obesidad',
    'Hipotiroidismo', 'Hipertiroidismo',
  ];

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _add(String condition) {
    if (condition.trim().isNotEmpty && !_conditions.contains(condition.trim())) {
      setState(() => _conditions.add(condition.trim()));
      _controller.clear();
      context.read<OnboardingCubit>().updateConditions(List.from(_conditions));
    }
  }

  void _remove(String condition) {
    setState(() => _conditions.remove(condition));
    context.read<OnboardingCubit>().updateConditions(List.from(_conditions));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Condiciones de Salud', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Selecciona o agrega condiciones médicas que tengas diagnosticadas.',
              style: TextStyle(color: Colors.white.withAlpha(179))),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _commonConditions.map((c) {
              final isSelected = _conditions.contains(c);
              return FilterChip(
                label: Text(c),
                selected: isSelected,
                onSelected: (selected) => selected ? _add(c) : _remove(c),
                selectedColor: CyberTheme.primary.withAlpha(77),
                checkmarkColor: CyberTheme.primary,
                labelStyle: TextStyle(color: isSelected ? CyberTheme.primary : Colors.white70),
                backgroundColor: CyberTheme.surfaceDark,
                side: BorderSide(color: isSelected ? CyberTheme.primary : Colors.white24),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          GlassmorphicCard(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Agregar otra condición...',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(102)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _add,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: CyberTheme.primary),
                  onPressed: () => _add(_controller.text),
                ),
              ],
            ),
          ),
          if (_conditions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Condiciones agregadas:', style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _conditions.map((c) {
                return Chip(
                  label: Text(c), deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _remove(c),
                  backgroundColor: CyberTheme.primary.withAlpha(51),
                  deleteIconColor: CyberTheme.primary,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 48),
          _navButtons(context),
        ],
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
              backgroundColor: CyberTheme.primary, foregroundColor: CyberTheme.backgroundDark,
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
