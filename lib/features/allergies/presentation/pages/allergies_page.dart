import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import '../../application/allergies_cubit.dart';
import '../../application/allergies_state.dart';
import '../../domain/entities/allergy.dart';
import '../widgets/allergy_card.dart';
import '../widgets/allergy_form.dart';

class AllergiesPage extends StatelessWidget {
  const AllergiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AllergiesCubit>()..loadAllergies(),
      child: const _AllergiesView(),
    );
  }
}

class _AllergiesView extends StatelessWidget {
  const _AllergiesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alergias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: CyberTheme.primary),
            tooltip: 'Añadir alergia',
            onPressed: () => _showAllergyForm(context),
          ),
        ],
      ),
      body: BlocBuilder<AllergiesCubit, AllergiesState>(
        builder: (context, state) {
          if (state is AllergiesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AllergiesLoaded) {
            return _buildAllergyList(context, state.allergies);
          } else if (state is AllergiesError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No hay alergias registradas'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CyberTheme.primary,
        onPressed: () => _showAllergyForm(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildAllergyList(BuildContext context, List<Allergy> allergies) {
    if (allergies.isEmpty) {
      return const Center(child: Text('No hay alergias registradas'));
    }

    final severeAllergies =
        allergies.where((a) => a.severity == AllergySeverity.severe).toList();
    final otherAllergies =
        allergies.where((a) => a.severity != AllergySeverity.severe).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (severeAllergies.isNotEmpty) ...[
          const Text(
            'CRÍTICAS',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...severeAllergies.map((a) => AllergyCard(
                allergy: a,
                isCritical: true,
                onTap: () => _showAllergyForm(context, allergy: a),
              )),
          const SizedBox(height: 24),
        ],
        if (otherAllergies.isNotEmpty) ...[
          const Text(
            'OTRAS ALERGIAS',
            style: TextStyle(
              color: CyberTheme.secondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...otherAllergies.map((a) => AllergyCard(
                allergy: a,
                onTap: () => _showAllergyForm(context, allergy: a),
              )),
        ],
      ],
    );
  }

  void _showAllergyForm(BuildContext context, {Allergy? allergy}) {
    final cubit = context.read<AllergiesCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AllergyForm(
        allergy: allergy,
        onSave: (savedAllergy) {
          cubit.saveAllergy(savedAllergy);
          Navigator.pop(context);
        },
        onDelete: allergy != null
            ? () {
                cubit.deleteAllergy(allergy.id);
                Navigator.pop(context);
              }
            : null,
      ),
    );
  }
}
