import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/onboarding_cubit.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class FamilyHistoryStep extends StatefulWidget {
  const FamilyHistoryStep({super.key});

  @override
  State<FamilyHistoryStep> createState() => _FamilyHistoryStepState();
}

class _FamilyHistoryStepState extends State<FamilyHistoryStep> {
  final _controller = TextEditingController();
  final List<String> _history = [];

  static const _commonHistory = [
    'Diabetes', 'Hipertensión', 'Cáncer de mama', 'Cáncer de colon',
    'Enfermedad cardíaca', 'Infarto', 'Accidente cerebrovascular',
    'Alzheimer', 'Osteoporosis', 'Asma',
  ];

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _add(String item) {
    if (item.trim().isNotEmpty && !_history.contains(item.trim())) {
      setState(() => _history.add(item.trim()));
      _controller.clear();
      context.read<OnboardingCubit>().updateFamilyHistory(List.from(_history));
    }
  }

  void _remove(String item) {
    setState(() => _history.remove(item));
    context.read<OnboardingCubit>().updateFamilyHistory(List.from(_history));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Historial Familiar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Indica condiciones de salud que hayan tenido familiares directos.',
              style: TextStyle(color: Colors.white.withAlpha(179))),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _commonHistory.map((h) {
              final isSelected = _history.contains(h);
              return FilterChip(
                label: Text(h),
                selected: isSelected,
                onSelected: (selected) => selected ? _add(h) : _remove(h),
                selectedColor: CyberTheme.secondary.withAlpha(77),
                checkmarkColor: CyberTheme.secondary,
                labelStyle: TextStyle(color: isSelected ? CyberTheme.secondary : Colors.white70),
                backgroundColor: CyberTheme.surfaceDark,
                side: BorderSide(color: isSelected ? CyberTheme.secondary : Colors.white24),
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
                  icon: const Icon(Icons.add_circle, color: CyberTheme.secondary),
                  onPressed: () => _add(_controller.text),
                ),
              ],
            ),
          ),
          if (_history.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Agregadas:', style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _history.map((h) {
                return Chip(
                  label: Text(h), deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _remove(h),
                  backgroundColor: CyberTheme.secondary.withAlpha(51),
                  deleteIconColor: CyberTheme.secondary,
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
