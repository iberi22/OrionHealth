import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AppointmentRepository _repository = getIt<AppointmentRepository>();
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _pastAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final upcoming = await _repository.getUpcomingAppointments();
    final past = await _repository.getPastAppointments();
    if (!mounted) return;
    setState(() {
      _upcomingAppointments = upcoming;
      _pastAppointments = past;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appointments,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_upcomingAppointments.isEmpty && _pastAppointments.isEmpty)
                ? Stack(
                    children: [
                      ListView(),
                      _buildEmptyState(l10n),
                    ],
                  )
                : _buildAppointmentList(l10n),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          HapticFeedback.lightImpact();
          _showAppointmentForm(l10n);
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            l10n.noAppointments,
            style: const TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(AppLocalizations l10n) {
    final List<dynamic> items = [];

    if (_upcomingAppointments.isNotEmpty) {
      items.add(l10n.upcomingAppointments);
      items.addAll(_upcomingAppointments);
    }

    if (_pastAppointments.isNotEmpty) {
      items.add(l10n.pastAppointments);
      items.addAll(_pastAppointments);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is String) {
          return Padding(
            padding: EdgeInsets.only(
              top: index > 0 ? 24.0 : 0,
              bottom: 16.0,
            ),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          );
        } else if (item is Appointment) {
          return _buildAppointmentCard(item, l10n);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, AppLocalizations l10n) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showAppointmentForm(l10n, appointment: appointment);
          },
          child: GlassmorphicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appointment.dateTime != null
                              ? DateFormat('dd').format(appointment.dateTime!)
                              : '--',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          appointment.dateTime != null
                              ? DateFormat('MMM').format(appointment.dateTime!).toUpperCase()
                              : '---',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName ?? l10n.notSpecified,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          appointment.specialty ?? l10n.notSpecified,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              appointment.dateTime != null
                                  ? DateFormat('HH:mm').format(appointment.dateTime!)
                                  : '--:--',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                appointment.location ?? l10n.notSpecified,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                                overflow: TextOverflow.ellipsis,
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
                      color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getStatusColor(appointment.status).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      appointment.statusLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(appointment.status),
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

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blueAccent;
      case AppointmentStatus.confirmed:
        return Colors.greenAccent;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.redAccent;
      case AppointmentStatus.noShow:
        return Colors.orangeAccent;
    }
  }

  void _showAppointmentForm(AppLocalizations l10n, {Appointment? appointment}) {
    final doctorController = TextEditingController(text: appointment?.doctorName);
    final specialtyController = TextEditingController(text: appointment?.specialty);
    final locationController = TextEditingController(text: appointment?.location);
    final notesController = TextEditingController(text: appointment?.notes);
    final durationController = TextEditingController(text: appointment?.durationMinutes?.toString());

    DateTime selectedDate = appointment?.dateTime ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    AppointmentStatus selectedStatus = appointment?.status ?? AppointmentStatus.scheduled;
    AppointmentType selectedType = appointment?.type ?? AppointmentType.consultation;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
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
                      appointment == null ? l10n.newAppointment : l10n.editAppointment,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (appointment != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          await _repository.deleteAppointment(appointment.id);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          _loadAppointments();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(doctorController, l10n.doctor, Icons.person),
                const SizedBox(height: 12),
                _buildTextField(specialtyController, l10n.specialty, Icons.medical_services_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today, color: AppColors.secondary),
                        title: const Text('Fecha'),
                        subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (date != null) {
                            setModalState(() => selectedDate = date);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.access_time, color: AppColors.secondary),
                        title: const Text('Hora'),
                        subtitle: Text(selectedTime.format(context)),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setModalState(() => selectedTime = time);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Tipo de Cita', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppointmentType.values.map((type) {
                      final isSelected = selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(_getTypeLabel(type, l10n)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => selectedType = type);
                            }
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.3),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.white70,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(locationController, l10n.location, Icons.location_on_outlined),
                const SizedBox(height: 12),
                _buildTextField(durationController, l10n.duration, Icons.timer_outlined, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildTextField(notesController, l10n.notes, Icons.notes, maxLines: 3),
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
                      if (doctorController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.doctorNameRequired),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final finalDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      final newAppointment = (appointment ?? Appointment()).copyWith(
                        doctorName: doctorController.text,
                        specialty: specialtyController.text,
                        dateTime: finalDateTime,
                        status: selectedStatus,
                        type: selectedType,
                        location: locationController.text,
                        notes: notesController.text,
                        durationMinutes: int.tryParse(durationController.text),
                      );

                      await _repository.saveAppointment(newAppointment);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _loadAppointments();
                    },
                    child: Text(
                      appointment == null ? l10n.save : l10n.update,
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

  String _getTypeLabel(AppointmentType type, AppLocalizations l10n) {
    switch (type) {
      case AppointmentType.consultation: return l10n.typeConsultation;
      case AppointmentType.followUp: return l10n.typeFollowUp;
      case AppointmentType.checkup: return l10n.typeCheckup;
      case AppointmentType.emergency: return l10n.typeEmergency;
      case AppointmentType.telemedicine: return l10n.typeTelemedicine;
      case AppointmentType.laboratory: return l10n.typeLaboratory;
      case AppointmentType.imaging: return l10n.typeImaging;
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
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
