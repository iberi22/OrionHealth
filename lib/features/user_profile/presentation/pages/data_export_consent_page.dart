import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../infrastructure/services/data_export_service.dart';

class DataExportConsentPage extends StatefulWidget {
  final DataExportService exportService;
  final ExportMode mode;

  const DataExportConsentPage({
    Key? key,
    required this.exportService,
    this.mode = ExportMode.a,
  }) : super(key: key);

  @override
  State<DataExportConsentPage> createState() => _DataExportConsentPageState();
}

class _DataExportConsentPageState extends State<DataExportConsentPage> {
  bool _consentGiven = false;
  String _passphrase = '';
  String _confirmPassphrase = '';
  bool _isExporting = false;
  ExportSummary? _summary;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final summary = await widget.exportService.getExportSummary();
    if (mounted) {
      setState(() {
        _summary = summary;
      });
    }
  }

  void _exportData() async {
    if (!_consentGiven) return;

    if (widget.mode == ExportMode.a || widget.mode == ExportMode.c) {
      if (_passphrase.length < 12) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña debe tener al menos 12 caracteres.'),
          ),
        );
        return;
      }
      if (_passphrase != _confirmPassphrase) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden.')),
        );
        return;
      }
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final file = await widget.exportService.exportUserData(
        mode: widget.mode,
        passphrase: widget.mode == ExportMode.a || widget.mode == ExportMode.c
            ? _passphrase
            : null,
      );

      if (mounted) {
        setState(() {
          _isExporting = false;
        });

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Mis datos de salud exportados de OrionHealth.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar mis datos')),
      body: _summary == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ATENCIÓN: DATOS DE SALUD',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Se exportarán los siguientes registros de su cuenta:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('• Perfil: ${_summary!.userProfile}'),
                  Text('• Registros médicos: ${_summary!.medicalRecords}'),
                  Text('• Medicamentos: ${_summary!.medications}'),
                  Text('• Alergias: ${_summary!.allergies}'),
                  Text('• Citas: ${_summary!.appointments}'),
                  Text('• Signos vitales: ${_summary!.vitalSigns}'),
                  Text('• Reportes: ${_summary!.reports}'),
                  Text('• Doctores: ${_summary!.doctorProfiles}'),
                  Text('• Configuraciones: ${_summary!.appSettings}'),
                  Text('• Ecosistema: ${_summary!.ecosystemRecords}'),
                  const SizedBox(height: 24),
                  if (widget.mode == ExportMode.a ||
                      widget.mode == ExportMode.c) ...[
                    const Text(
                      'Protección con contraseña (Requerido)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'El archivo se cifrará. Debe ingresar una contraseña de al menos 12 caracteres.',
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                      ),
                      obscureText: true,
                      onChanged: (v) => setState(() => _passphrase = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Contraseña',
                      ),
                      obscureText: true,
                      onChanged: (v) => setState(() => _confirmPassphrase = v),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const Text(
                      'ADVERTENCIA: EXPORTACIÓN SIN CIFRAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Text(
                      'Los datos se guardarán en un archivo ZIP sin cifrar. Cualquiera que acceda al archivo podrá leer su información médica.',
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: [
                      Checkbox(
                        value: _consentGiven,
                        onChanged: (v) {
                          setState(() {
                            _consentGiven = v ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Doy mi consentimiento explícito para exportar mis datos médicos personales y entiendo los riesgos asociados.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_consentGiven && !_isExporting)
                          ? _exportData
                          : null,
                      child: _isExporting
                          ? const CircularProgressIndicator()
                          : const Text('Exportar y Compartir'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
