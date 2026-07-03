import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../domain/entities/allergy.dart';

class AllergyForm extends StatefulWidget {
  final Allergy? allergy;
  final Function(Allergy) onSave;
  final VoidCallback? onDelete;

  const AllergyForm({
    super.key,
    this.allergy,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<AllergyForm> createState() => _AllergyFormState();
}

class _AllergyFormState extends State<AllergyForm> {
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
