import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/swal_tooltip.dart';
import '../../../email-citas/presentation/email_connect_page.dart';
import '../../../calendar_import/presentation/calendar_import_page.dart';
import '../../application/services/appointments_lookup.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_form.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late final AppointmentRepository _repository;
  List<Appointment> _allAppointments = [];
  AppointmentsLookup _appointmentsLookup = AppointmentsLookup.empty();
  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _repository = getIt<AppointmentRepository>();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _repository.getAppointments();
      setState(() {
        _allAppointments = appointments;
        // Optimization: Pre-compute O(1) date lookup map once on load
        // What: Convert appointment list to date-indexed lookup map
        // Why: Avoid O(N) iterative searches on every calendar cell build
        // Impact: Reduces 42 grid cell lookups from O(42*N) to O(42) per frame
        _appointmentsLookup = AppointmentsLookup.fromList(appointments);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar citas: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming =
        _allAppointments
            .where(
              (a) =>
                  a.dateTime.isAfter(DateTime.now()) &&
                  a.status != AppointmentStatus.cancelled,
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final past =
        _allAppointments
            .where(
              (a) =>
                  a.dateTime.isBefore(DateTime.now()) ||
                  a.status == AppointmentStatus.cancelled,
            )
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        actions: [
          SWALTooltip(
            message: 'Importar desde correo',
            child: IconButton(
              icon: const Icon(Icons.email_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmailConnectPage(),
                ),
              ).then((_) => _loadAppointments()),
            ),
          ),
          SWALTooltip(
            message: 'Importar desde calendario',
            child: IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarImportPage(),
                  ),
                );
                if (result == true) {
                  _loadAppointments();
                }
              },
            ),
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
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: _buildCalendar(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Próximas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CyberTheme.secondary,
                        ),
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
                            (context, index) => AppointmentCard(
                              appointment: upcoming[index],
                              onTap: () => _showAppointmentForm(
                                appointment: upcoming[index],
                              ),
                            ),
                            childCount: upcoming.length,
                          ),
                        ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Historial',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
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
                            (context, index) => AppointmentCard(
                              appointment: past[index],
                              onTap: () => _showAppointmentForm(
                                appointment: past[index],
                              ),
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
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
    final firstDayOffset = DateUtils.firstDayOffset(
      _focusedDay.year,
      _focusedDay.month,
      MaterialLocalizations.of(context),
    );
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: () => setState(
                        () => _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: () => setState(
                        () => _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        ),
                      ),
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
final hasAppointment = _appointmentsLookup.hasAppointmentsOn(
                  date,
                );

                return InkWell(
                  onTap: () => setState(() => _selectedDay = date),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CyberTheme.primary.withValues(alpha: 0.2)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: CyberTheme.primary)
                          : (isToday
                                ? Border.all(
                                    color: CyberTheme.secondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  )
                                : null),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            color: isSelected
                                ? CyberTheme.primary
                                : (isToday
                                      ? CyberTheme.secondary
                                      : Colors.white),
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
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
      builder: (context) => AppointmentForm(
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
