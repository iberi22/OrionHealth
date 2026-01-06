import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/bloc/health_record_cubit.dart';
import '../../domain/entities/medical_record.dart';

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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          if (state is HealthRecordFilePicked) {
            return Scaffold(
              appBar: AppBar(title: const Text('Nuevo Registro Médico')),
              body: _RecordForm(
                filePath: state.filePath,
                initialText: state.extractedText,
              ),
            );
          }
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
      appBar: AppBar(
        leading: Icon(Icons.shield, color: CyberTheme.secondary),
        title: const Text('Historial Médico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: CyberTheme.secondary),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
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
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          if (state is HealthRecordLoadedState)
            _Timeline(records: (state as HealthRecordLoadedState).records),
          if (state is HealthRecordInitial &&
              (state as HealthRecordInitial).records.isNotEmpty)
            _Timeline(records: (state as HealthRecordInitial).records),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSelectionModal(context),
        label: const Text('Añadir Registro'),
        icon: const Icon(Icons.add),
        backgroundColor: CyberTheme.primary,
        foregroundColor: Colors.black,
      ),
    );
  }

  void _showSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<HealthRecordCubit>(context),
        child: _SelectionView(),
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
          hintStyle: TextStyle(color: CyberTheme.secondary.withOpacity(0.7)),
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
        Chip(
          label: const Text('Todos'),
          backgroundColor: CyberTheme.primary.withOpacity(0.3),
        ),
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
      return const SliverFillRemaining(
        child: Center(child: Text('No hay registros.')),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final record = records[index];
        return _TimelineItem(record: record);
      }, childCount: records.length),
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
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.medical_services,
                      color: CyberTheme.secondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: CyberTheme.secondary.withOpacity(0.3),
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
                    DateFormat(
                      'dd MMMM, yyyy',
                    ).format(record.date ?? DateTime.now()),
                    style: const TextStyle(color: CyberTheme.secondary),
                  ),
                  const SizedBox(height: 8),
                  GlassmorphicCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.summary ?? 'Sin resumen',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.type.name,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
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

class _SelectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf,
                color: CyberTheme.secondary,
              ),
              title: const Text('Subir PDF'),
              onTap: () {
                Navigator.pop(context);
                context.read<HealthRecordCubit>().pickPdf();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: CyberTheme.secondary,
              ),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                context.read<HealthRecordCubit>().pickImage(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: CyberTheme.secondary),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                context.read<HealthRecordCubit>().pickImage(false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordForm extends StatefulWidget {
  final String filePath;
  final String initialText;
  const _RecordForm({required this.filePath, required this.initialText});
  @override
  State<_RecordForm> createState() => _RecordFormState();
}

class _RecordFormState extends State<_RecordForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late TextEditingController _summaryController;
  late DateTime _selectedDate;
  RecordType _selectedType = RecordType.clinicalNote;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _summaryController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _textController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Archivo: ${widget.filePath.split('/').last}'),
            const SizedBox(height: 16),
            GlassmorphicCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButtonFormField<RecordType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Documento',
                    border: InputBorder.none,
                  ),
                  items: RecordType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphicCard(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha del Documento',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphicCard(
              child: TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Resumen Breve',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
              ),
            ),
            const SizedBox(height: 16),
            GlassmorphicCard(
              child: TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Texto Extraído (Editable)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 10,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.read<HealthRecordCubit>().reset(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<HealthRecordCubit>().saveRecord(
                          filePath: widget.filePath,
                          extractedText: _textController.text,
                          summary: _summaryController.text,
                          type: _selectedType,
                          date: _selectedDate,
                        );
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
