import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import '../../domain/entities/allergy.dart';
import '../../domain/repositories/allergy_repository.dart';

class AllergiesPage extends StatefulWidget {
  const AllergiesPage({super.key});

  @override
  State<AllergiesPage> createState() => _AllergiesPageState();
}

class _AllergiesPageState extends State<AllergiesPage> {
  final AllergyRepository _repository = getIt<AllergyRepository>();
  List<Allergy> _allergies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllergies();
  }

  Future<void> _loadAllergies() async {
    setState(() => _isLoading = true);
    final allergies = await _repository.getAllergies();
    setState(() {
      _allergies = allergies;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alergias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: CyberTheme.primary),
            onPressed: () => _showAllergyForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAllergyList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CyberTheme.primary,
        onPressed: () => _showAllergyForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildAllergyList() {
    if (_allergies.isEmpty) {
      return const Center(child: Text('No hay alergias registradas'));
    }

    final severeAllergies = _allergies.where((a) => a.severity == AllergySeverity.severe).toList();
    final otherAllergies = _allergies.where((a) => a.severity != AllergySeverity.severe).toList();

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
          ...severeAllergies.map((a) => _buildAllergyCard(a, isCritical: true)),
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
          ...otherAllergies.map((a) => _buildAllergyCard(a)),
        ],
      ],
    );
  }

  Widget _buildAllergyCard(Allergy allergy, {bool isCritical = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showAllergyForm(allergy: allergy),
        child: GlassmorphicCard(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: isCritical
                ? BoxDecoration(
                    border: Border.all(color: Colors.red.withValues(alpha: 0.5), width: 2),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.red.withValues(alpha: 0.05),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      allergy.allergen ?? 'Desconocido',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    _buildSeverityBadge(allergy.severity),
                  ],
                ),
                if (allergy.notes != null && allergy.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    allergy.notes!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(AllergySeverity severity) {
    Color color;
    String label;

    switch (severity) {
      case AllergySeverity.mild:
        color = Colors.green;
        label = 'Leve';
        break;
      case AllergySeverity.moderate:
        color = Colors.yellow;
        label = 'Moderada';
        break;
      case AllergySeverity.severe:
        color = Colors.red;
        label = 'Severa';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAllergyForm({Allergy? allergy}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AllergyForm(
        allergy: allergy,
        onSave: (savedAllergy) async {
          await _repository.saveAllergy(savedAllergy);
          _loadAllergies();
          if (mounted) Navigator.pop(context);
        },
        onDelete: allergy != null
            ? () async {
                await _repository.deleteAllergy(allergy.id);
                _loadAllergies();
                if (mounted) Navigator.pop(context);
              }
            : null,
      ),
    );
  }
}

class _AllergyForm extends StatefulWidget {
  final Allergy? allergy;
  final Function(Allergy) onSave;
  final VoidCallback? onDelete;

  const _AllergyForm({
    this.allergy,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_AllergyForm> createState() => _AllergyFormState();
}

class _AllergyFormState extends State<_AllergyForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _allergenController;
  late TextEditingController _notesController;
  late AllergySeverity _severity;

  @override
  void initState() {
    super.initState();
    _allergenController = TextEditingController(text: widget.allergy?.allergen);
    _notesController = TextEditingController(text: widget.allergy?.notes);
    _severity = widget.allergy?.severity ?? AllergySeverity.mild;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: CyberTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.allergy == null ? 'Nueva Alergia' : 'Editar Alergia',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CyberTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _allergenController,
                decoration: const InputDecoration(
                  labelText: 'Alérgeno',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              const Text('Severidad', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              SegmentedButton<AllergySeverity>(
                segments: const [
                  ButtonSegment(
                    value: AllergySeverity.mild,
                    label: Text('Leve'),
                  ),
                  ButtonSegment(
                    value: AllergySeverity.moderate,
                    label: Text('Moderada'),
                  ),
                  ButtonSegment(
                    value: AllergySeverity.severe,
                    label: Text('Severa'),
                  ),
                ],
                selected: {_severity},
                onSelectionChanged: (value) {
                  setState(() => _severity = value.first);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final allergy = Allergy(
                      id: widget.allergy?.id ?? Isar.autoIncrement,
                      allergen: _allergenController.text,
                      severity: _severity,
                      notes: _notesController.text,
                    );
                    widget.onSave(allergy);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('GUARDAR'),
              ),
              if (widget.onDelete != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onDelete,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('ELIMINAR'),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _allergenController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
