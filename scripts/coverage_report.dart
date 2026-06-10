import 'dart:io';
import 'dart:convert';

void main() async {
  final featuresDir = Directory('lib/features');
  if (!featuresDir.existsSync()) {
    print('Error: lib/features directory not found');
    exit(1);
  }

  final testFeaturesDir = Directory('test/features');
  final features = featuresDir
      .listSync()
      .whereType<Directory>()
      .map((d) => d.path.split(Platform.pathSeparator).last)
      .toList()
    ..sort();

  final List<Map<String, dynamic>> report = [];

  for (final feature in features) {
    final featureReport = {
      'name': feature,
      'layers': {
        'domain': _checkLayer(feature, 'domain'),
        'application': _checkLayer(feature, 'application'),
        'infrastructure': _checkLayer(feature, 'infrastructure'),
        'presentation': _checkLayer(feature, 'presentation'),
        'goldens': _checkGoldens(feature),
      }
    };
    report.add(featureReport);
  }

  // Output JSON
  final jsonFile = File('coverage_report.json');
  await jsonFile.writeAsString(const JsonEncoder.withIndent('  ').convert(report));
  print('Generated coverage_report.json');

  // Output Markdown
  final mdFile = File('coverage_report.md');
  final sink = mdFile.openWrite();
  sink.writeln('# Feature Test Coverage Report');
  sink.writeln('\nGenerated on: ${DateTime.now()}\n');
  sink.writeln('| Feature | Domain | Application | Infrastructure | Presentation | Goldens |');
  sink.writeln('| :--- | :---: | :---: | :---: | :---: | :---: |');

  for (final f in report) {
    final layers = f['layers'] as Map<String, bool>;
    sink.writeln('| ${f['name']} | ${_status(layers['domain'])} | ${_status(layers['application'])} | ${_status(layers['infrastructure'])} | ${_status(layers['presentation'])} | ${_status(layers['goldens'])} |');
  }

  await sink.close();
  print('Generated coverage_report.md');
}

bool _checkLayer(String feature, String layer) {
  final layerDir = Directory('test/features/$feature/$layer');
  if (!layerDir.existsSync()) return false;

  // Check if there are any .dart files in this layer (recursively)
  return layerDir.listSync(recursive: true).any((entity) => entity is File && entity.path.endsWith('_test.dart'));
}

bool _checkGoldens(String feature) {
  final presentationDir = Directory('test/features/$feature/presentation');
  if (!presentationDir.existsSync()) return false;

  return presentationDir.listSync(recursive: true).any((entity) =>
    entity is File && entity.path.endsWith('_golden_test.dart'));
}

String _status(bool? present) {
  return (present ?? false) ? '✅' : '❌';
}
