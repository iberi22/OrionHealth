import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../infrastructure/services/data_export_service.dart';

class DataExportConsentPage extends StatefulWidget {
  final DataExportService exportService;

  const DataExportConsentPage({Key? key, required this.exportService})
      : super(key: key);

  @override
  State<DataExportConsentPage> createState() => _DataExportConsentPageState();
}

class _DataExportConsentPageState extends State<DataExportConsentPage> {
  bool _consented = false;
  ExportSummary? _summary;
  bool _isLoading = true;
  String _passphrase = '';
  String _passphraseConfirm = '';

  // Hardcoded per D-health-export = A
  final ExportMode _mode = ExportMode.a;

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
        _isLoading = false;
      });
    }
  }

  bool get _canSubmit {
    if (!_consented) return false;
    if (_mode == ExportMode.a || _mode == ExportMode.c) {
      return _passphrase.length >= 12 && _passphrase == _passphraseConfirm;
    }
    return true;
  }

  Future<void> _exportData() async {
    if (!_canSubmit) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final file = await widget.exportService.exportUserData(
        mode: _mode,
        userConsented: _consented,
        passphrase: _mode == ExportMode.b ? null : _passphrase,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exportación completada. Guardada en: ${file.path}')),
        );

        // Share file
        await Share.shareXFiles([XFile(file.path)], text: 'Mi archivo de exportación de salud (OrionHealth)');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error durante la exportación: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar mis datos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advertencia: Datos de Salud y GDPR',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Esta acción exportará todos sus datos personales de salud generados en este dispositivo, incluyendo perfiles, registros médicos, medicación y más.\n\n'
                    'De acuerdo con el Art. 20 del GDPR (Derecho a la portabilidad de los datos), usted tiene derecho a descargar una copia de estos datos.\n\n'
                    'Por favor, asegúrese de guardar este archivo en un lugar seguro. No lo comparta con terceros sin entender las implicaciones de privacidad.',
                  ),
                  const SizedBox(height: 24),
                  if (_summary != null) ...[
                    const Text(
                      'Resumen de datos a exportar:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Total de registros: ${_summary!.total}'),
                    Text('- Perfiles: ${_summary!.userProfile}'),
                    Text('- Registros Médicos: ${_summary!.medicalRecords}'),
                    Text('- Medicaciones: ${_summary!.medications}'),
                    Text('- Alergias: ${_summary!.allergies}'),
                    Text('- Citas: ${_summary!.appointments}'),
                    Text('- Signos Vitales: ${_summary!.vitalSigns}'),
                    Text('- Reportes: ${_summary!.reports}'),
                    Text('- Perfiles de Doctores: ${_summary!.doctorProfiles}'),
                    Text('- Configuración: ${_summary!.appSettings}'),
                    Text('- Registros de Ecosistema: ${_summary!.ecosystemRecords}'),
                    const SizedBox(height: 24),
                  ],
                  if (_mode == ExportMode.a || _mode == ExportMode.c) ...[
                    const Text(
                      'Protección con Contraseña (Recomendado)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Introduzca una contraseña de al menos 12 caracteres para encriptar su exportación (Argon2id + AES-256-GCM).'),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña (mínimo 12 caracteres)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() => _passphrase = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() => _passphraseConfirm = val),
                    ),
                    if (_passphrase.isNotEmpty && _passphrase.length < 12)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'La contraseña debe tener al menos 12 caracteres.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (_passphraseConfirm.isNotEmpty && _passphrase != _passphraseConfirm)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Las contraseñas no coinciden.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                  CheckboxListTile(
                    title: const Text(
                      'Entiendo que esto es información médica sensible y consiento explícitamente descargar estos datos a mi dispositivo local.',
                    ),
                    value: _consented,
                    onChanged: (val) {
                      setState(() {
                        _consented = val ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: _canSubmit ? _exportData : null,
                        child: const Text('Exportar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}