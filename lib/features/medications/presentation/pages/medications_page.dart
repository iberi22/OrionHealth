import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import 'package:intl/intl.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  final MedicationRepository _repository = getIt<MedicationRepository>();
  List<Medication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final medications = await _repository.getAllMedications();
    if (!mounted) return;
    setState(() {
      _medications = medications;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medicamentos',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: CyberTheme.primary),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showMedicationForm();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMedications,
        color: CyberTheme.primary,
        backgroundColor: CyberTheme.surfaceDark,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _medications.isEmpty
                ? Stack(
                    children: [
                      ListView(),
                      _buildEmptyState(),
                    ],
                  )
                : _buildMedicationList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CyberTheme.primary,
        onPressed: () {
          HapticFeedback.lightImpact();
          _showMedicationForm();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No hay medicamentos registrados',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    final activeMedications = _medications.where((m) => m.isActive).toList();
    final inactiveMedications = _medications.where((m) => !m.isActive).toList();

    final List<dynamic> items = [];
    if (activeMedications.isNotEmpty) {
      items.add('Activos');
      items.addAll(activeMedications);
    }
    if (inactiveMedications.isNotEmpty) {
      items.add('Archivados');
      items.addAll(inactiveMedications);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is String) {
          return Padding(
            padding: EdgeInsets.only(
              top: item == 'Archivados' && activeMedications.isNotEmpty ? 24.0 : 0,
              bottom: 16.0,
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: item == 'Activos' ? CyberTheme.primary : Colors.grey,
              ),
            ),
          );
        } else if (item is Medication) {
          return _buildMedicationCard(item, isArchived: !item.isActive);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMedicationCard(Medication medication, {bool isArchived = false}) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showMedicationForm(medication: medication);
        },
          child: GlassmorphicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isArchived ? Colors.grey : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${medication.dosage ?? ''} • ${medication.frequency ?? ''}',
                          style: TextStyle(
                            color: isArchived ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: isArchived ? Colors.grey[600] : CyberTheme.secondary,
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
                          ? Colors.grey.withOpacity(0.1)
                          : CyberTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isArchived
                            ? Colors.grey.withOpacity(0.3)
                            : CyberTheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      isArchived ? 'INACTIVO' : 'ACTIVO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isArchived ? Colors.grey : CyberTheme.primary,
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

  void _showMedicationForm({Medication? medication}) {
    final nameController = TextEditingController(text: medication?.name);
    final dosageController = TextEditingController(text: medication?.dosage);
    final frequencyController = TextEditingController(text: medication?.frequency);
    final notesController = TextEditingController(text: medication?.notes);
    DateTime selectedDate = medication?.startDate ?? DateTime.now();
    bool isActive = medication?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: CyberTheme.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                        color: CyberTheme.primary,
                      ),
                    ),
                    if (medication != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          await _repository.deleteMedication(medication.id);
                          if (mounted) Navigator.pop(context);
                          _loadMedications();
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
                  leading: const Icon(Icons.calendar_today, color: CyberTheme.secondary),
                  title: const Text('Fecha de inicio'),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: CyberTheme.primary,
                              onPrimary: Colors.black,
                              surface: CyberTheme.surfaceDark,
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
                    color: isActive ? CyberTheme.primary : Colors.grey,
                  ),
                  value: isActive,
                  activeColor: CyberTheme.primary,
                  onChanged: (val) => setModalState(() => isActive = val),
                ),
                _buildTextField(notesController, 'Notas', Icons.notes, maxLines: 3),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberTheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
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

                      await _repository.saveMedication(newMedication);
                      if (mounted) Navigator.pop(context);
                      _loadMedications();
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
        prefixIcon: Icon(icon, color: CyberTheme.secondary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CyberTheme.primary),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
