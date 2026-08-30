/// FEAT-022: Emergency ID edit form
///
/// Owner-only. Full edit of all Medical ID fields.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/emergency_contact.dart';
import '../../domain/entities/medical_id.dart';
import '../cubit/emergency_cubit.dart';

class EmergencyEditPage extends StatefulWidget {
  final String userId;
  const EmergencyEditPage({super.key, required this.userId});

  @override
  State<EmergencyEditPage> createState() => _EmergencyEditPageState();
}

class _EmergencyEditPageState extends State<EmergencyEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  BloodType _bloodType = BloodType.unknown;
  OrganDonor _organDonor = OrganDonor.unknown;
  final _allergiesCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();
  final _iceNameCtrl = TextEditingController();
  final _icePhoneCtrl = TextEditingController();
  final _iceRelCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<EmergencyCubit>().state;
    if (state.medicalId != null) {
      final id = state.medicalId!;
      _nameCtrl.text = id.fullName;
      _dobCtrl.text = id.dateOfBirth.toIso8601String().split('T').first;
      _bloodType = id.bloodType;
      _organDonor = id.organDonor;
      _allergiesCtrl.text = id.allergies.join(', ');
      _medsCtrl.text = id.currentMedications.join(', ');
      _iceNameCtrl.text = id.primaryContact.name;
      _icePhoneCtrl.text = id.primaryContact.phone;
      _iceRelCtrl.text = id.primaryContact.relationship;
      _notesCtrl.text = id.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _allergiesCtrl.dispose();
    _medsCtrl.dispose();
    _iceNameCtrl.dispose();
    _icePhoneCtrl.dispose();
    _iceRelCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical ID')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _dobCtrl,
              decoration: const InputDecoration(
                  labelText: 'Fecha de nacimiento (YYYY-MM-DD)'),
              validator: _validateDate,
            ),
            DropdownButtonFormField<BloodType>(
              value: _bloodType,
              decoration: const InputDecoration(labelText: 'Tipo de sangre'),
              items: BloodType.values
                  .map((b) =>
                      DropdownMenuItem(value: b, child: Text(b.displayName)))
                  .toList(),
              onChanged: (v) => setState(() => _bloodType = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _allergiesCtrl,
              decoration: const InputDecoration(
                labelText: 'Alergias (separadas por coma)',
                helperText: 'Críticas para primeros respondedores',
              ),
              maxLines: 2,
            ),
            TextFormField(
              controller: _medsCtrl,
              decoration: const InputDecoration(
                labelText: 'Medicamentos actuales (separados por coma)',
              ),
              maxLines: 2,
            ),
            const Divider(height: 32),
            const Text('Contacto de emergencia (ICE)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _iceNameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _icePhoneCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _iceRelCtrl,
              decoration:
                  const InputDecoration(labelText: 'Relación'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<OrganDonor>(
              value: _organDonor,
              decoration: const InputDecoration(labelText: 'Donante de órganos'),
              items: OrganDonor.values
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o.name.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _organDonor = v!),
            ),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                  labelText: 'Notas adicionales para respondedores'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar Medical ID'),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  String? _validateDate(String? v) {
    if (v == null || v.isEmpty) return 'Requerido';
    if (DateTime.tryParse(v) == null) return 'Formato: YYYY-MM-DD';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final dob = DateTime.parse(_dobCtrl.text);
    final id = MedicalIdEntity(
      userId: widget.userId,
      fullName: _nameCtrl.text,
      dateOfBirth: dob,
      bloodType: _bloodType,
      allergies: _allergiesCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      currentMedications: _medsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      primaryContact: EmergencyContact(
        name: _iceNameCtrl.text,
        relationship: _iceRelCtrl.text,
        phone: _icePhoneCtrl.text,
      ),
      organDonor: _organDonor,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      lastUpdated: DateTime.now(),
    );
    context.read<EmergencyCubit>().save(id);
    Navigator.pop(context);
  }
}
