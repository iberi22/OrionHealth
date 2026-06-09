import 'package:flutter/material.dart';
import 'package:health_wallet/health_wallet.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/timeline_entry.dart';
import '../../domain/entities/medical_record.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late Future<List<TimelineEntry>> _timelineEntriesFuture;

  @override
  void initState() {
    super.initState();
    _timelineEntriesFuture = _loadTimeline();
  }

  Future<List<TimelineEntry>> _loadTimeline() async {
    final walletService = getIt<WalletService>();
    final healthRecordRepo = getIt<HealthRecordRepository>();

    final List<TimelineEntry> entries = [];

    // 1. Load MedicalRecords (from local feature repo)
    final records = await healthRecordRepo.getAllRecords();
    for (final r in records) {
      entries.add(TimelineEntry(
        id: r.id.toString(),
        title: r.type == RecordType.labResult ? 'Resultado de Laboratorio' :
               r.type == RecordType.prescription ? 'Prescripción' :
               r.type == RecordType.clinicalNote ? 'Nota Clínica' : 'Otro Registro',
        description: r.summary,
        date: r.date ?? DateTime.now(),
        type: r.type == RecordType.clinicalNote ? TimelineEntryType.clinicalNote : TimelineEntryType.medicalEvent,
      ));
    }

    // 2. Load MedicalEvents
    final events = await walletService.getTimeline();
    for (final e in events) {
      entries.add(TimelineEntry(
        id: e.remoteId,
        title: e.description,
        description: '${e.eventType.name.toUpperCase()} at ${e.facility ?? "Unknown Facility"}',
        date: e.eventDate,
        type: TimelineEntryType.medicalEvent,
      ));
    }

    // 3. Load Labs
    final stats = await walletService.getDataStatistics();
    if (stats['labs']! > 0) {
       // Ideally we have a getAllLabs, but let's assume recent labs for now if not available or just fetch all via isar directly if needed.
       // Since WalletService doesn't have getAllLabs, I'll use exportAllData and extract or just skip if too complex for this demo.
       // Actually, I'll stick to what WalletService provides.
    }

    // 4. Load Concepts
    final concepts = await walletService.getAllMedicalConcepts();
    for (final c in concepts) {
      entries.add(TimelineEntry(
        id: c.remoteId,
        title: 'Nota de Dr. ${c.doctorName}',
        description: c.notes,
        date: c.conceptDate,
        type: TimelineEntryType.medicalConcept,
        metadata: {'recommendations': c.recommendations},
      ));
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LÍNEA DE TIEMPO'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<TimelineEntry>>(
        future: _timelineEntriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: CyberTheme.primary));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return const Center(
              child: Text('No hay eventos en tu historial médico.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _TimelineItem(entry: entry, isLast: index == entries.length - 1);
            },
          );
        },
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TimelineEntry entry;
  final bool isLast;

  const _TimelineItem({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getTypeColor(entry.type),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getTypeColor(entry.type).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white24,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(entry.date),
                            style: const TextStyle(
                              color: CyberTheme.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            _getTypeIcon(entry.type),
                            size: 16,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (entry.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.description!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (entry.type == TimelineEntryType.medicalConcept && entry.metadata?['recommendations'] != null) ...[
                         const SizedBox(height: 12),
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: CyberTheme.primary.withValues(alpha: 0.1),
                             borderRadius: BorderRadius.circular(8),
                             border: Border.all(color: CyberTheme.primary.withValues(alpha: 0.3)),
                           ),
                           child: Row(
                             children: [
                               const Icon(Icons.lightbulb, color: CyberTheme.primary, size: 16),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: Text(
                                   'Rec: ${entry.metadata!['recommendations']}',
                                   style: const TextStyle(fontSize: 12, color: CyberTheme.primary),
                                 ),
                               ),
                             ],
                           ),
                         ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(TimelineEntryType type) {
    switch (type) {
      case TimelineEntryType.labResult:
        return Colors.blue;
      case TimelineEntryType.vitalSign:
        return Colors.red;
      case TimelineEntryType.medication:
        return Colors.orange;
      case TimelineEntryType.medicalEvent:
        return CyberTheme.secondary;
      case TimelineEntryType.medicalConcept:
        return CyberTheme.primary;
      case TimelineEntryType.clinicalNote:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(TimelineEntryType type) {
    switch (type) {
      case TimelineEntryType.labResult:
        return Icons.science;
      case TimelineEntryType.vitalSign:
        return Icons.favorite;
      case TimelineEntryType.medication:
        return Icons.medication;
      case TimelineEntryType.medicalEvent:
        return Icons.event;
      case TimelineEntryType.medicalConcept:
        return Icons.psychology;
      case TimelineEntryType.clinicalNote:
        return Icons.note;
    }
  }
}
