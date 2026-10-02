import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:health_contract/health_contract.dart' as contract;
import 'package:share_plus/share_plus.dart';
import '../../../../core/di/injection.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../domain/services/ecosystem_import_service.dart';
import '../../domain/services/ecosystem_dietary_export_service.dart';
import '../../infrastructure/parsers/health_data_parser.dart';
import 'ecosystem_confirmation_page.dart';

Future<void> reviewEcosystemRecords(
  BuildContext context,
  List<contract.Envelope> records,
) async {
  final service = getIt<EcosystemImportService>();
  final preview = await service.preview(
    records.map((r) => r.toJson()).toList(),
  );
  if (!context.mounted) return;
  final count = await Navigator.push<int>(
    context,
    MaterialPageRoute(
      builder: (_) => EcosystemConfirmationPage(
        preview: preview,
        save: (bind) => service.save(preview, consent: true, bindSubject: bind),
      ),
    ),
  );
  if (context.mounted && count != null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$count registros importados')));
  }
}

Future<void> reviewEcosystemLink(BuildContext context, Uri uri) async {
  try {
    await reviewEcosystemRecords(context, contract.decodeDeepLink(uri));
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enlace inválido, demasiado grande o incompatible con tu perfil. Usa un archivo .swalhealth.json válido.',
          ),
        ),
      );
    }
  }
}

class EcosystemTransferPage extends StatefulWidget {
  const EcosystemTransferPage({super.key});
  @override
  State<EcosystemTransferPage> createState() => _EcosystemTransferPageState();
}

class _EcosystemTransferPageState extends State<EcosystemTransferPage> {
  final _dataset = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _diets = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await getIt<UserProfileRepository>().getUserProfile();
    final dataset = await getIt<EcosystemRecordStore>().latestDataset();
    if (!mounted) return;
    _kcal.text = profile?.dietaryGoalsKcalPerDay?.toString() ?? '';
    _protein.text = profile?.dietaryGoalsProteinGPerDay?.toString() ?? '';
    _diets.text = profile?.dietaryPreferences.join(', ') ?? '';
    _dataset.text = dataset ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _dataset.dispose();
    _kcal.dispose();
    _protein.dispose();
    _diets.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ecosistema de salud')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          onPressed: _busy ? null : _importFile,
          icon: const Icon(Icons.file_open),
          label: const Text('Importar .swalhealth.json'),
        ),
        const SizedBox(height: 24),
        Text(
          'Compartir perfil alimentario',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Text(
          'Solo se compartirán alérgenos reconocidos, dietas y metas que indiques. Vigencia: 30 días.',
        ),
        TextField(
          controller: _kcal,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Meta kcal/día (opcional)',
          ),
        ),
        TextField(
          controller: _protein,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Meta proteína g/día (opcional)',
          ),
        ),
        TextField(
          controller: _diets,
          decoration: const InputDecoration(
            labelText: 'Referencias de dietas separadas por coma',
            hintText: 'gos:diet/mediterranean',
          ),
        ),
        TextField(
          controller: _dataset,
          decoration: const InputDecoration(
            labelText: 'Versión del dataset GOS',
            hintText: 'x.y.z+sha256:<hash del manifest>',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy ? null : _exportProfile,
          icon: const Icon(Icons.share),
          label: const Text('Revisar y compartir archivo'),
        ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
  );

  Future<void> _importFile() => _run(() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null) return;
    final file = result.files.single;
    if (!file.name.endsWith('.swalhealth.json') || file.bytes == null) {
      throw const FormatException('Elige un archivo .swalhealth.json.');
    }
    final records = HealthDataParser().parseSwalHealth(
      utf8.decode(file.bytes!, allowMalformed: false),
    );
    if (mounted) await reviewEcosystemRecords(context, records);
  });

  Future<void> _exportProfile() => _run(() async {
    double? number(TextEditingController controller, bool positive) {
      if (controller.text.trim().isEmpty) return null;
      final n = double.tryParse(controller.text.trim());
      if (n == null || !n.isFinite || (positive ? n <= 0 : n < 0)) {
        throw const FormatException('Las metas deben ser números válidos.');
      }
      return n;
    }

    final kcal = number(_kcal, true);
    final protein = number(_protein, false);
    final diets = _diets.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    if (diets.any(
      (s) => !RegExp(r'^gos:diet/[a-z0-9]+(?:[-_][a-z0-9]+)*$').hasMatch(s),
    )) {
      throw const FormatException('Usa referencias gos:diet/<slug> válidas.');
    }
    if (!RegExp(
      r'^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?\+sha256:[a-f0-9]{64}$',
    ).hasMatch(_dataset.text.trim())) {
      throw const FormatException(
        'Introduce la versión y hash del manifest GOS.',
      );
    }
    final repository = getIt<UserProfileRepository>();
    final profile = await repository.getUserProfile();
    if (profile == null)
      throw const FormatException('Primero configura tu perfil.');
    profile.dietaryGoalsKcalPerDay = kcal;
    profile.dietaryGoalsProteinGPerDay = protein;
    profile.dietaryPreferences = diets;
    await repository.saveUserProfile(profile);
    final draft = await getIt<DietaryProfileExportService>().build(
      gosDataset: _dataset.text.trim(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
    final record = contract.Envelope.fromJson(draft.record);
    final text = contract.toFile([record]);
    if (!mounted) return;
    final consent = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Autorizar compartir perfil alimentario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                const JsonEncoder.withIndent(
                  '  ',
                ).convert(draft.record['data']),
              ),
              if (draft.unmappedAllergens.isNotEmpty)
                Text(
                  'Estos alérgenos no se pueden representar y NO se incluirán: ${draft.unmappedAllergens.join(', ')}. El perfil no representa todas tus restricciones.',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Autorizar y compartir'),
          ),
        ],
      ),
    );
    if (consent != true || !mounted) return;
    await getIt<DietaryProfileExportService>().confirm(draft, consent: true);
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(utf8.encode(text), mimeType: 'application/json'),
        ],
        fileNameOverrides: ['dietary-profile.swalhealth.json'],
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  });

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted)
        setState(
          () => _error = error is FormatException
              ? error.message.toString()
              : 'No se pudo completar. Revisa el formato, la identidad y la vigencia de los registros.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
