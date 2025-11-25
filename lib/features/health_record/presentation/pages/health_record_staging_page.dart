import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../application/bloc/health_record_cubit.dart';
import '../../domain/entities/medical_record.dart';

class HealthRecordStagingPage extends StatelessWidget {
  const HealthRecordStagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HealthRecordCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Nuevo Registro Médico')),
        body: BlocConsumer<HealthRecordCubit, HealthRecordState>(
          listener: (context, state) {
            if (state is HealthRecordSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registro guardado exitosamente')),
              );
              context.read<HealthRecordCubit>().reset();
            } else if (state is HealthRecordError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            if (state is HealthRecordLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HealthRecordFilePicked) {
              return _RecordForm(
                filePath: state.filePath,
                initialText: state.extractedText,
              );
            }
            return _SelectionView();
          },
        ),
      ),
    );
  }
}

class _SelectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => context.read<HealthRecordCubit>().pickPdf(),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Subir PDF'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<HealthRecordCubit>().pickImage(true),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Tomar Foto'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<HealthRecordCubit>().pickImage(false),
            icon: const Icon(Icons.image),
            label: const Text('Galería'),
          ),
        ],
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
            Text('Archivo: ${widget.filePath.split('/').last}', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            DropdownButtonFormField<RecordType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Tipo de Documento'),
              items: RecordType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            const SizedBox(height: 16),
            InkWell(
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
                decoration: const InputDecoration(labelText: 'Fecha del Documento'),
                child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(labelText: 'Resumen Breve'),
              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Texto Extraído (Editable)'),
              maxLines: 10,
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
