import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/medication.dart';
import '../../application/medications_cubit.dart';
import '../../application/medications_state.dart';
import 'package:intl/intl.dart';

final getIt = GetIt.instance;

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  late final MedicationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt.isRegistered<MedicationsCubit>() 
        ? getIt<MedicationsCubit>() 
        : MedicationsCubit(getIt());
    _cubit.loadMedications();
  }

  @override
  void dispose() {
    if (!getIt.isRegistered<MedicationsCubit>()) {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Medicamentos',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                onPressed: () => _showMedicationForm(context),
              ),
            ),
          ],
        ),
        body: BlocBuilder<MedicationsCubit, MedicationsState>(
          builder: (context, state) {
            if (state is MedicationsLoading || state is MedicationsInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MedicationsError) {
              return Center(child: Text(state.message));
            } else if (state is MedicationsLoaded) {
              if (state.medications.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildMedicationsList(context, state.medications);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_liquid, size: 80, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          Text(
            'No hay medicamentos registrados',
            style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showMedicationForm(context),
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

  Widget _buildMedicationsList(BuildContext context, List<Medication> medications) {
    return RefreshIndicator(
      onRefresh: () => context.read<MedicationsCubit>().loadMedications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return _buildMedicationCard(context, medication);
        },
      ),
    );
  }

  Widget _buildMedicationCard(BuildContext context, Medication medication) {
    final bool isArchived = !medication.isActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showMedicationForm(context, medication: medication),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isArchived
                          ? Colors.grey.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: isArchived ? Colors.grey : AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isArchived ? Colors.grey[400] : Colors.white,
                            decoration: isArchived ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (medication.dosage != null && medication.dosage!.isNotEmpty)
                          Text(
                            medication.dosage!,
                            style: TextStyle(
                              color: isArchived ? Colors.grey[600] : AppColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          medication.frequency ?? 'Sin frecuencia especificada',
                          style: TextStyle(
                            fontSize: 13,
                            color: isArchived ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: isArchived ? Colors.grey[600] : AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy').format(medication.startDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: isArchived ? Colors.grey[600] : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isArchived
                          ? Colors.grey.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isArchived
                            ? Colors.grey.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      isArchived ? 'INACTIVO' : 'ACTIVO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isArchived ? Colors.grey : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMedicationForm(BuildContext context, {Medication? medication}) {
    final nameController = TextEditingController(text: medication?.name);
    final dosageController = TextEditingController(text: medication?.dosage);
    final frequencyController = TextEditingController(text: medication?.frequency);
    final notesController = TextEditingController(text: medication?.notes);
    DateTime selectedDate = medication?.startDate ?? DateTime.now();
    bool isActive = medication?.isActive ?? true;

    final cubit = context.read<MedicationsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (bottomSheetContext, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      medication == null ? 'Nuevo Medicamento' : 'Editar Medicamento',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (medication != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          await cubit.deleteMedication(medication.id);
                          if (!bottomSheetContext.mounted) return;
                          Navigator.pop(bottomSheetContext);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(nameController, 'Nombre', Icons.medication),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(dosageController, 'Dosis', Icons.scale)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(frequencyController, 'Frecuencia', Icons.repeat)),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: AppColors.secondary),
                  title: const Text('Fecha de inicio'),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: bottomSheetContext,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.primary,
                              onPrimary: Colors.black,
                              surface: AppColors.surface,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setModalState(() => selectedDate = date);
                    }
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activo'),
                  secondary: Icon(
                    isActive ? Icons.check_circle : Icons.pause_circle,
                    color: isActive ? AppColors.primary : Colors.grey,
                  ),
                  value: isActive,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setModalState(() => isActive = val),
                ),
                _buildTextField(notesController, 'Notas', Icons.notes, maxLines: 3),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                          const SnackBar(
                            content: Text('El nombre es requerido'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final newMedication = Medication(
                        id: medication?.id ?? Isar.autoIncrement,
                        name: nameController.text,
                        dosage: dosageController.text,
                        frequency: frequencyController.text,
                        startDate: selectedDate,
                        isActive: isActive,
                        notes: notesController.text,
                      );

                      await cubit.saveMedication(newMedication);
                      if (!bottomSheetContext.mounted) return;
                      Navigator.pop(bottomSheetContext);
                    },
                    child: Text(
                      medication == null ? 'GUARDAR' : 'ACTUALIZAR',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}
