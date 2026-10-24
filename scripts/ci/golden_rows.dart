import 'dart:io';

void main() {
  final file = File('tests/known_failures.txt');
  if (!file.existsSync()) {
    stderr.writeln('Error: tests/known_failures.txt not found');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  final newLines = <String>[];
  final targetFiles = <String>{};

  for (final line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) {
      newLines.add(line);
      continue;
    }

    final parts = line.split(' :: ');
    if (parts.length >= 3) {
      final filePath = parts[0].trim();
      final reason = parts[2].trim();

      if (reason.contains('needs regeneration with 3.44.0')) {
        targetFiles.add(filePath);
        continue;
      }
    }
    newLines.add(line);
  }

  file.writeAsStringSync('${newLines.join('\n')}\n');

  if (targetFiles.isNotEmpty) {
    stdout.write(targetFiles.join(' '));
  }
}
