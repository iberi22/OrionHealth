import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/bloc/health_record_cubit.dart';
import '../../domain/entities/medical_record.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HealthRecordCubit, HealthRecordState>(
      listener: (context, state) {
        if (state is HealthRecordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        } else if (state is HealthRecordSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Registro guardado con éxito!')),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Subir Registro'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.read<HealthRecordCubit>().reset();
                Navigator.of(context).pop();
              },
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HealthRecordState state) {
    if (state is HealthRecordLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: CyberTheme.primary),
            SizedBox(height: 24),
            Text('Procesando documento...',
                style: TextStyle(color: CyberTheme.secondary, fontSize: 18)),
            SizedBox(height: 8),
            Text('Extrayendo información médica con IA',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (state is HealthRecordFilePicked) {
      return _UploadDetailsStep(
        filePath: state.filePath,
        extractedText: state.extractedText,
      );
    }

    return _SourceSelectionStep();
  }
}

class _SourceSelectionStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona el origen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CyberTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sube tus documentos médicos para que nuestra IA pueda analizarlos y organizarlos por ti.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 32),

          // Primary CTA: PDF
          _OptionCard(
            title: 'Subir Documento PDF',
            description: 'Ideal para informes de laboratorio, recetas digitales y epicrisis.',
            icon: Icons.picture_as_pdf,
            isPrimary: true,
            onTap: () => context.read<HealthRecordCubit>().pickPdf(),
          ),

          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('O OTRAS OPCIONES', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
              Expanded(child: Divider(color: Colors.white24)),
            ],
          ),
          const SizedBox(height: 16),

          // Secondary: Camera
          _OptionCard(
            title: 'Tomar Foto',
            description: 'Captura una imagen de un documento físico usando tu cámara.',
            icon: Icons.camera_alt,
            onTap: () => context.read<HealthRecordCubit>().pickImage(true),
          ),

          const SizedBox(height: 16),

          // Secondary: Gallery
          _OptionCard(
            title: 'Elegir de la Galería',
            description: 'Selecciona una foto de un documento que ya tengas en tu dispositivo.',
            icon: Icons.image,
            onTap: () => context.read<HealthRecordCubit>().pickImage(false),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _OptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassmorphicCard(
        borderColor: isPrimary ? CyberTheme.primary.withValues(alpha: 0.5) : Colors.white10,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isPrimary ? CyberTheme.primary : CyberTheme.secondary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? CyberTheme.primary : CyberTheme.secondary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? CyberTheme.primary : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadDetailsStep extends StatefulWidget {
  final String filePath;
  final String extractedText;

  const _UploadDetailsStep({
    required this.filePath,
    required this.extractedText,
  });

  @override
  State<_UploadDetailsStep> createState() => _UploadDetailsStepState();
}

class _UploadDetailsStepState extends State<_UploadDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  // We'll just use a simple form here, but ideally we'd reuse the logic from the other page
  // For now, I'll implement a clean version here.

  // NOTE: In a real app, I'd refactor the RecordForm into a shared widget.
  // But to satisfy the "Redesign records upload into guided step-based flow"
  // I will make this part of the new flow.

  late TextEditingController _summaryController;
  late TextEditingController _textController;
  late DateTime _selectedDate;
  RecordType _selectedType = RecordType.clinicalNote;

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController();
    _textController = TextEditingController(text: widget.extractedText);
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verificar Información',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CyberTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Revisa y completa los detalles extraídos del documento.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),

            Text('Archivo: ${widget.filePath.split('/').last}',
                style: const TextStyle(color: CyberTheme.secondary, fontSize: 12)),
            const SizedBox(height: 16),

            GlassmorphicCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        labelText: 'Resumen o Título',
                        labelStyle: TextStyle(color: CyberTheme.secondary),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RecordType>(
                      value: _selectedType,
                      dropdownColor: CyberTheme.surfaceDark,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Documento',
                        labelStyle: TextStyle(color: CyberTheme.secondary),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                      items: RecordType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name, style: const TextStyle(color: Colors.white)),
                              ))
                          .toList(),
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
                        decoration: const InputDecoration(
                          labelText: 'Fecha del Documento',
                          labelStyle: TextStyle(color: CyberTheme.secondary),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        ),
                        child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text('Texto Extraído', style: TextStyle(color: CyberTheme.secondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GlassmorphicCard(
              child: TextFormField(
                controller: _textController,
                maxLines: 8,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberTheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('GUARDAR REGISTRO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.read<HealthRecordCubit>().reset(),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
