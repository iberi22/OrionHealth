import 'package:flutter/material.dart';
import '../../domain/services/ecosystem_import_service.dart';

class EcosystemConfirmationPage extends StatefulWidget {
  const EcosystemConfirmationPage({
    super.key,
    required this.preview,
    required this.save,
  });
  final EcosystemImportPreview preview;
  final Future<int> Function(bool bindSubject) save;

  @override
  State<EcosystemConfirmationPage> createState() =>
      _EcosystemConfirmationPageState();
}

class _EcosystemConfirmationPageState extends State<EcosystemConfirmationPage> {
  bool _belongsToMe = false;
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Revisar importación')),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Estos registros se guardarán en este dispositivo. Revisa su origen y confirma antes de importar.',
          ),
        ),
        if (widget.preview.requiresSubjectBinding)
          CheckboxListTile(
            value: _belongsToMe,
            onChanged: _saving
                ? null
                : (value) => setState(() => _belongsToMe = value ?? false),
            title: const Text('Confirmo que estos registros son míos'),
            subtitle: const Text(
              'Este identificador se vinculará a mi perfil local.',
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.preview.records.length,
            itemBuilder: (context, index) {
              final record = widget.preview.records[index];
              final data = record['data'] as Map<String, dynamic>;
              final schema = record['schema'] as String;
              final label = schema.endsWith('meal-log')
                  ? 'Comida'
                  : schema.endsWith('workout-session')
                  ? 'Entrenamiento'
                  : 'Perfil alimentario';
              final date =
                  data['consumedAt'] ??
                  data['startedAt'] ??
                  record['createdAt'];
              return ExpansionTile(
                title: Text(label),
                subtitle: Text('$date · ${(record['source'] as Map)['app']}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_describe(data)),
                  ),
                ],
              );
            },
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed:
                      _saving ||
                          widget.preview.records.isEmpty ||
                          (widget.preview.requiresSubjectBinding &&
                              !_belongsToMe)
                      ? null
                      : _save,
                  child: Text(_saving ? 'Guardando…' : 'Confirmar importación'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  String _describe(Map<String, dynamic> data) {
    if (data.containsKey('items')) {
      final items = (data['items'] as List)
          .map(
            (item) =>
                '${item['ref']}: ${item['grams'] ?? item['servings']} ${item.containsKey('grams') ? 'g' : 'porciones'}',
          )
          .join('\n');
      return '$items\nNutrición (${data['nutritionSource']}): ${data['nutrition']}';
    }
    if (data.containsKey('exercises')) {
      return '${(data['exercises'] as List).map((e) => '${e['ref']}: ${e['sets']}').join('\n')}\nFin: ${data['endedAt']}\nEnergía: ${data['energy'] ?? 'No declarada'}';
    }
    return 'Alérgenos: ${data['allergens']}\nDietas: ${data['diets']}\nMetas: ${data['targets']}\nVigencia: ${data['expiresAt']}';
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final count = await widget.save(_belongsToMe);
      if (mounted) Navigator.pop(context, count);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error =
              'No se pudo guardar. Revisa la identidad y vigencia de los registros.';
        });
      }
    }
  }
}
