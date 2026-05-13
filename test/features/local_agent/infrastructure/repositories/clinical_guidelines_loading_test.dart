import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetMedicalKnowledgeRepository repository;

  const mockGuidelinesJson = {
    "metadata": {
      "standard": "Clinical Guidelines",
      "version": "1.0.0",
      "lastUpdated": "2025-05-15",
      "source": "WHO, CDC",
      "totalCount": 1
    },
    "data": [
      {
        "code": "I10",
        "displayName": "Essential (primary) hypertension",
        "category": "Cardiovascular",
        "searchTerms": ["Hipertensión arterial"],
        "definition": "High blood pressure definition.",
        "firstLineTreatment": "DASH diet and Thiazide diuretics.",
        "alternatives": "ACE inhibitors.",
        "redFlags": "BP >180/120 mmHg.",
        "followUp": "Re-evaluate 1 month."
      }
    ]
  };

  const mockIcd10Json = {
    "metadata": {"standard": "ICD-10"},
    "data": []
  };
  const mockLoincJson = {
    "metadata": {"standard": "LOINC"},
    "data": []
  };
  const mockRxNormJson = {
    "metadata": {"standard": "RxNorm"},
    "data": []
  };
  const mockSnomedJson = {
    "metadata": {"standard": "SNOMED"},
    "data": []
  };

  setUp(() {
    repository = AssetMedicalKnowledgeRepository();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        final String key = utf8.decode(message!.buffer.asUint8List());
        if (key.contains('clinical_guidelines.json')) {
          return ByteData.view(utf8.encode(jsonEncode(mockGuidelinesJson)).buffer);
        } else if (key.contains('icd10.json')) {
          return ByteData.view(utf8.encode(jsonEncode(mockIcd10Json)).buffer);
        } else if (key.contains('loinc.json')) {
          return ByteData.view(utf8.encode(jsonEncode(mockLoincJson)).buffer);
        } else if (key.contains('rxnorm.json')) {
          return ByteData.view(utf8.encode(jsonEncode(mockRxNormJson)).buffer);
        } else if (key.contains('snomed.json')) {
          return ByteData.view(utf8.encode(jsonEncode(mockSnomedJson)).buffer);
        }
        return null;
      },
    );
  });

  group('Clinical Guidelines Loading', () {
    test('should load clinical guidelines and populate new fields', () async {
      await repository.initialize();

      final code = await repository.searchByCode('I10');

      expect(code, isNotNull);
      expect(code!.code, 'I10');
      expect(code.standard, 'Clinical Guidelines');
      expect(code.firstLineTreatment, 'DASH diet and Thiazide diuretics.');
      expect(code.alternatives, 'ACE inhibitors.');
      expect(code.redFlags, 'BP >180/120 mmHg.');
      expect(code.followUp, 'Re-evaluate 1 month.');

      // Verify embeddingText contains new fields
      expect(code.embeddingText, contains('First-line Treatment: DASH diet and Thiazide diuretics.'));
      expect(code.embeddingText, contains('Alternatives: ACE inhibitors.'));
      expect(code.embeddingText, contains('Red Flags: BP >180/120 mmHg.'));
      expect(code.embeddingText, contains('Follow-up: Re-evaluate 1 month.'));
    });
  });
}
