import 'package:injectable/injectable.dart';

/// Configuration for [MedicalTextNormalizer].
///
/// Contains dictionary mappings for Spanish medical abbreviations
/// and stop words to be trimmed/filtered during text normalization.
@injectable
class MedicalTextNormalizationConfig {
  /// Map of medical abbreviations to their expanded form (case-insensitive key matching).
  final Map<String, String> abbreviations;

  /// List of stop words to remove or ignore.
  final List<String> stopWords;

  const MedicalTextNormalizationConfig({
    this.abbreviations = const {
      'TA': 'tensión arterial',
      'FC': 'frecuencia cardíaca',
      'IMC': 'índice de masa corporal',
      'FR': 'frecuencia respiratoria',
      'SpO2': 'saturación de oxígeno',
      'Hb': 'hemoglobina',
      'HTA': 'hipertensión arterial',
      'DM': 'diabetes mellitus',
      'EPOC': 'enfermedad pulmonar obstructiva crónica',
      'ECG': 'electrocardiograma',
      'PA': 'presión arterial',
      'Rx': 'radiografía',
      'SNC': 'sistema nervioso central',
      'UCI': 'unidad de cuidados intensivos',
      'EVA': 'escala visual analógica',
    },
    this.stopWords = const [
      'el',
      'la',
      'los',
      'las',
      'de',
      'del',
      'un',
      'una',
      'con',
      'sin',
      'por',
      'para',
      'en',
      'y',
      'o',
    ],
  });
}
