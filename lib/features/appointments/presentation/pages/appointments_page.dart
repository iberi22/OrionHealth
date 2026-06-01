import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../calendar_import/presentation/calendar_import_page.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AppointmentRepository _repository = getIt<AppointmentRepository>();
  List<Appointment> _allAppointments = [];
  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _repository.getAllAppointments();
      setState(() {
        _allAppointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar citas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _allAppointments
        .where((a) => a.dateTime.isAfter(DateTime.now()) && a.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final past = _allAppointments
        .where((a) => a.dateTime.isBefore(DateTime.now()) || a.status == AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Importar desde calendario',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarImportPage()),
              );
              if (result == true) {
                _loadAppointments();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAppointmentForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAppointments,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildCalendar(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Próximas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CyberTheme.secondary),
                      ),
                    ),
                  ),
                  upcoming.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('No hay citas próximas')),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _AppointmentCard(
                              appointment: upcoming[index],
                              onTap: () => _showAppointmentForm(appointment: upcoming[index]),
                            ),
                            childCount: upcoming.length,
                          ),
                        ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Historial',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white54),
                      ),
                    ),
                  ),
                  past.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('No hay citas pasadas')),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _AppointmentCard(
                              appointment: past[index],
                              onTap: () => _showAppointmentForm(appointment: past[index]),
                            ),
                            childCount: past.length,
                          ),
                        ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAppointmentForm(),
        backgroundColor: CyberTheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildCalendar() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOffset = DateUtils.firstDayOffset(_focusedDay.year, _focusedDay.month, MaterialLocalizations.of(context));
    final monthName = DateFormat.MMMM('es').format(_focusedDay);

    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${monthName.toUpperCase()} ${_focusedDay.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: daysInMonth + firstDayOffset,
              itemBuilder: (context, index) {
                if (index < firstDayOffset) return const SizedBox.shrink();
                final day = index - firstDayOffset + 1;
                final date = DateTime(_focusedDay.year, _focusedDay.month, day);
                final isSelected = DateUtils.isSameDay(date, _selectedDay);
                final isToday = DateUtils.isSameDay(date, DateTime.now());
                final hasAppointment = _allAppointments.any((a) => DateUtils.isSameDay(a.dateTime, date));

                return InkWell(
                  onTap: () => setState(() => _selectedDay = date),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? CyberTheme.primary.withOpacity(0.2) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: CyberTheme.primary) : (isToday ? Border.all(color: CyberTheme.secondary.withOpacity(0.5)) : null),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            color: isSelected ? CyberTheme.primary : (isToday ? CyberTheme.secondary : Colors.white),
                            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (hasAppointment)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: CyberTheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentForm({Appointment? appointment}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentForm(
        appointment: appointment,
        onSave: (newApp) async {
          await _repository.saveAppointment(newApp);
          _loadAppointments();
        },
        onDelete: (id) async {
          await _repository.deleteAppointment(id);
          _loadAppointments();
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const _AppointmentCard({required this.appointment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = appointment.status == AppointmentStatus.upcoming
        ? Colors.teal
        : (appointment.status == AppointmentStatus.completed ? Colors.green : Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: GlassmorphicCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appointment.specialty,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: CyberTheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM, hh:mm a', 'es').format(appointment.dateTime),
                            style: const TextStyle(color: CyberTheme.secondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text(
                    appointment.status.name.toUpperCase(),
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentForm extends StatefulWidget {
  final Appointment? appointment;
  final Function(Appointment) onSave;
  final Function(int) onDelete;

  const _AppointmentForm({this.appointment, required this.onSave, required this.onDelete});

  @override
  State<_AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<_AppointmentForm> {
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
                Expanded(
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
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AppointmentStatus>(
              value: _status,
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
