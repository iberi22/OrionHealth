import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../application/bloc/health_record_cubit.dart';
import '../../domain/entities/medical_record.dart';
import 'upload_page.dart';

class HealthRecordStagingPage extends StatelessWidget {
  const HealthRecordStagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HealthRecordCubit>()..loadRecords(),
      child: BlocConsumer<HealthRecordCubit, HealthRecordState>(
        listener: (context, state) {
          if (state is HealthRecordSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registro guardado exitosamente')),
            );
            context.read<HealthRecordCubit>().resetAndLoad();
          } else if (state is HealthRecordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return _RecordHistoryView(state: state);
        },
      ),
    );
  }
}

class _RecordHistoryView extends StatelessWidget {
  final HealthRecordState state;
  const _RecordHistoryView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: PageHeader(
                title: 'Historial Médico',
                subtitle: 'Tus registros de salud protegidos por cifrado de extremo a extremo',
                leading: const Icon(Icons.security, color: CyberTheme.secondary),
                trailing: IconButton(
                  icon: const Icon(Icons.ios_share, color: CyberTheme.secondary),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _SearchBar(),
                  const SizedBox(height: 16),
                  _FilterChips(),
                ],
              ),
            ),
          ),
          if (state is HealthRecordLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          if (state is HealthRecordLoaded)
            _Timeline(records: state.records),
          if (state is HealthRecordInitial && state.records.isNotEmpty)
             _Timeline(records: state.records),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (innerContext) => BlocProvider.value(
                value: context.read<HealthRecordCubit>(),
                child: const UploadPage(),
              ),
            ),
          );
        },
        label: const Text('Añadir Registro'),
        icon: const Icon(Icons.add),
        backgroundColor: CyberTheme.primary,
        foregroundColor: Colors.black,
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por diagnóstico, medicación...',
          prefixIcon: const Icon(Icons.search, color: CyberTheme.secondary),
          border: InputBorder.none,
          hintStyle: TextStyle(color: CyberTheme.secondary.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Chip(label: const Text('Todos'), backgroundColor: CyberTheme.primary.withValues(alpha: 0.3)),
        Chip(label: const Text('Diagnóstico'), backgroundColor: Colors.white10),
        Chip(label: const Text('Medicación'), backgroundColor: Colors.white10),
        Chip(label: const Text('Documentos'), backgroundColor: Colors.white10),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<MedicalRecord> records;
  const _Timeline({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No hay registros.')));
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final record = records[index];
          return _TimelineItem(record: record);
        },
        childCount: records.length,
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final MedicalRecord record;
  const _TimelineItem({required this.record});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                GlassmorphicCard(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.medical_services, color: CyberTheme.secondary),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: CyberTheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMMM, yyyy').format(record.date ?? DateTime.now()),
                    style: const TextStyle(color: CyberTheme.secondary),
                  ),
                  const SizedBox(height: 8),
                  GlassmorphicCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.summary ?? 'Sin resumen', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(record.type.name, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Ver Detalles'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

