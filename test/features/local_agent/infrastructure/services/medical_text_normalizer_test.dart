import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/medical_text_normalizer.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/medical_text_normalizer_config.dart';

void main() {
  group('MedicalTextNormalizer', () {
    late MedicalTextNormalizer normalizer;

    setUp(() {
      normalizer = MedicalTextNormalizer();
    });

    test('normalize expands TA abbreviation', () {
      expect(
        normalizer.normalize('TA: 120/80'),
        equals('tensión arterial: 120/80'),
      );
    });

    test('normalize expands FC abbreviation', () {
      expect(
        normalizer.normalize('FC 75 lpm'),
        equals('frecuencia cardíaca 75 lpm'),
      );
    });

    test('normalize expands IMC abbreviation', () {
      expect(
        normalizer.normalize('Paciente con IMC de 28'),
        equals('paciente índice de masa corporal 28'),
      );
    });

    test('normalize expands FR abbreviation', () {
      expect(
        normalizer.normalize('FR de 18 rpm'),
        equals('frecuencia respiratoria 18 rpm'),
      );
    });

    test('normalize expands SpO2 abbreviation', () {
      expect(
        normalizer.normalize('SpO2 98%'),
        equals('saturación de oxígeno 98%'),
      );
    });

    test('normalize expands Hb abbreviation', () {
      expect(normalizer.normalize('Hb 14 g/dL'), equals('hemoglobina 14 g/dl'));
    });

    test('normalize expands HTA abbreviation', () {
      expect(
        normalizer.normalize('Paciente con HTA'),
        equals('paciente hipertensión arterial'),
      );
    });

    test('normalize expands DM abbreviation', () {
      expect(
        normalizer.normalize('Diagnóstico de DM2'),
        equals('diagnóstico dm2'),
      );
    });

    test('normalize expands EPOC abbreviation', () {
      expect(
        normalizer.normalize('Síntomas de EPOC'),
        equals('síntomas enfermedad pulmonar obstructiva crónica'),
      );
    });

    test('normalize expands ECG abbreviation', () {
      expect(
        normalizer.normalize('ECG normal'),
        equals('electrocardiograma normal'),
      );
    });

    test('normalize expands PA, Rx, SNC, UCI, EVA abbreviations', () {
      expect(
        normalizer.normalize('PA elevada'),
        equals('presión arterial elevada'),
      );
      expect(normalizer.normalize('Rx de tórax'), equals('radiografía tórax'));
      expect(
        normalizer.normalize('Afección del SNC'),
        equals('afección sistema nervioso central'),
      );
      expect(
        normalizer.normalize('Ingreso en UCI'),
        equals('ingreso unidad de cuidados intensivos'),
      );
      expect(
        normalizer.normalize('EVA 7/10'),
        equals('escala visual analógica 7/10'),
      );
    });

    test('normalize handles empty string', () {
      expect(normalizer.normalize(''), equals(''));
      expect(normalizer.normalize('   '), equals(''));
    });

    test('normalize respects custom MedicalTextNormalizationConfig', () {
      final customConfig = MedicalTextNormalizationConfig(
        abbreviations: const {'BP': 'blood pressure'},
        stopWords: const ['the', 'is'],
      );
      final customNormalizer = MedicalTextNormalizer(config: customConfig);

      expect(
        customNormalizer.normalize('The BP is high'),
        equals('blood pressure high'),
      );
    });
  });
}
