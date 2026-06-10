import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../appointments/domain/entities/appointment.dart';
import '../application/calendar_import_cubit.dart';

class CalendarImportPage extends StatelessWidget {
  const CalendarImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CalendarImportCubit>()..scanCalendar(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Importar Citas'),
        ),
        body: BlocConsumer<CalendarImportCubit, CalendarImportState>(
          listener: (context, state) {
            if (state is CalendarImportSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Se importaron ${state.importedCount} citas con éxito')),
              );
              Navigator.pop(context, true);
            } else if (state is CalendarImportError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            } else if (state is CalendarImportPermissionDenied) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permiso de calendario denegado')),
              );
            }
          },
          builder: (context, state) {
            if (state is CalendarImportLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CalendarImportLoaded) {
              return _CalendarEventsList(appointments: state.foundAppointments);
            }

            if (state is CalendarImportPermissionDenied) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Se requiere permiso para acceder al calendario'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<CalendarImportCubit>().scanCalendar(),
                      child: const Text('Solicitar Permiso'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Iniciando escaneo...'));
          },
        ),
      ),
    );
  }
}

class _CalendarEventsList extends StatefulWidget {
  final List<Appointment> appointments;

  const _CalendarEventsList({required this.appointments});

  @override
  State<_CalendarEventsList> createState() => _CalendarEventsListState();
}

class _CalendarEventsListState extends State<_CalendarEventsList> {
  late List<bool> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.generate(widget.appointments.length, (index) => true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No se encontraron citas médicas en tu calendario'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<CalendarImportCubit>().scanCalendar(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Hemos encontrado los siguientes eventos médicos. Selecciona los que desees importar:',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.appointments.length,
            itemBuilder: (context, index) {
              final app = widget.appointments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: GlassmorphicCard(
                  child: CheckboxListTile(
                    value: _selected[index],
                    onChanged: (val) => setState(() => _selected[index] = val!),
                    title: Text(
                      app.doctorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.specialty, style: const TextStyle(color: CyberTheme.secondary)),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a', 'es').format(app.dateTime),
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                    activeColor: CyberTheme.primary,
                    checkColor: Colors.black,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: _selected.contains(true)
                ? () {
                    final toImport = <Appointment>[];
                    for (int i = 0; i < _selected.length; i++) {
                      if (_selected[i]) {
                        toImport.add(widget.appointments[i]);
                      }
                    }
                    context.read<CalendarImportCubit>().importAppointments(toImport);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberTheme.primary,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('IMPORTAR SELECCIONADOS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
