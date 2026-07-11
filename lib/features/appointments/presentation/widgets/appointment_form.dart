import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../domain/entities/appointment.dart';

class AppointmentForm extends StatefulWidget {
  final Appointment? appointment;
  final Function(Appointment) onSave;
  final Function(int) onDelete;

  const AppointmentForm({super.key, this.appointment, required this.onSave, required this.onDelete});

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  late TextEditingController _doctorController;
  late TextEditingController _specialtyController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late AppointmentStatus _status;

  @override
  void initState() {
    super.initState();
    _doctorController = TextEditingController(text: widget.appointment?.doctorName ?? '');
    _specialtyController = TextEditingController(text: widget.appointment?.specialty ?? '');
    _notesController = TextEditingController(text: widget.appointment?.notes ?? '');
    _selectedDate = widget.appointment?.dateTime ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    _status = widget.appointment?.status ?? AppointmentStatus.upcoming;
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _specialtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CyberTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.appointment == null ? 'Nueva Cita' : 'Editar Cita',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _doctorController,
              decoration: const InputDecoration(labelText: 'Nombre del Doctor', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _specialtyController,
              decoration: const InputDecoration(labelText: 'Especialidad', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      title: const Text('Fecha'),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      title: const Text('Hora'),
                      subtitle: Text(_selectedTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AppointmentStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
              items: AppointmentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notas (Opcional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final finalDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );
                final app = Appointment(
                  id: widget.appointment?.id ?? Isar.autoIncrement,
                  doctorName: _doctorController.text,
                  specialty: _specialtyController.text,
                  dateTime: finalDateTime,
                  notes: _notesController.text,
                  status: _status,
                );
                widget.onSave(app);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: CyberTheme.primary, foregroundColor: Colors.black),
              child: const Text('GUARDAR'),
            ),
            if (widget.appointment != null)
              TextButton(
                onPressed: () {
                  widget.onDelete(widget.appointment!.id);
                  Navigator.pop(context);
                },
                child: const Text('ELIMINAR', style: TextStyle(color: Colors.redAccent)),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
