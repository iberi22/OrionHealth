import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/medical_research_cubit.dart';

class InteractionCheckerWidget extends StatefulWidget {
  const InteractionCheckerWidget({super.key});

  @override
  State<InteractionCheckerWidget> createState() => _InteractionCheckerWidgetState();
}

class _InteractionCheckerWidgetState extends State<InteractionCheckerWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _drugs = [];

  void _addDrug() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_drugs.contains(text)) {
      setState(() {
        _drugs.add(text);
        _controller.clear();
      });
      _check();
    }
  }

  void _removeDrug(String drug) {
    setState(() {
      _drugs.remove(drug);
    });
    if (_drugs.isNotEmpty) {
      _check();
    }
  }

  void _check() {
    context.read<MedicalResearchCubit>().checkInteractions(_drugs);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VERIFICADOR DE INTERACCIONES',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nombre del medicamento o RxNorm...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _addDrug(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addDrug,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: CyberTheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _drugs.map((drug) => Chip(
            label: Text(drug),
            onDeleted: () => _removeDrug(drug),
            backgroundColor: CyberTheme.primary.withValues(alpha: 0.2),
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
            deleteIconColor: Colors.white54,
            side: const BorderSide(color: CyberTheme.primary),
          )).toList(),
        ),
        const SizedBox(height: 16),
        BlocBuilder<MedicalResearchCubit, MedicalResearchState>(
          builder: (context, state) {
            if (state.status == MedicalResearchStatus.loading &&
                state.loadingMessage?.contains('interacciones') == true) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: CyberTheme.secondary),
                ),
              );
            }

            if (_drugs.isNotEmpty) {
              if (state.interactions.isEmpty && state.status == MedicalResearchStatus.success) {
                return const GlassmorphicCard(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.greenAccent),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No se encontraron interacciones conocidas entre estos medicamentos.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: state.interactions.map((interaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GlassmorphicCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              interaction,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
