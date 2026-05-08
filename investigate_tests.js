#!/usr/bin/env node
/**
 * MedicalAssistantCubit Test Investigation - Analysis Script
 * 
 * Implements Option B from the investigation:
 * Factory Constructor Pattern for testability without breaking API changes.
 */

const fs = require('fs');
const path = require('path');

const CUBIT_FILE = 'lib/features/medical_assistant/application/medical_assistant_cubit.dart';
const TEST_FILE = 'test/features/medical_assistant/application/medical_assistant_cubit_test.dart';

console.log('🔍 MedicalAssistantCubit Test Investigation\n');
console.log('='.repeat(60));

// Read files
const cubitContent = fs.readFileSync(path.join(process.cwd(), CUBIT_FILE), 'utf8');
const testContent = fs.readFileSync(path.join(process.cwd(), TEST_FILE), 'utf8');

// Analysis
console.log('\n📊 Current State Analysis:\n');

// Find submitQuery signature
const submitMatch = cubitContent.match(/Future<void> submitQuery.*?\n\s*\{/);
if (submitMatch) {
  console.log('✅ submitQuery uses Future<void> (NOT Stream)');
  console.log('   Signature:', submitMatch[0].trim());
}

// Find all emit() calls
const emitMatches = cubitContent.match(/emit\([^)]+\)/g) || [];
console.log(`\n📍 Found ${emitMatches.length} emit() calls`);

// Find _buildCubit pattern
const buildCubitMatch = testContent.match(/MedicalAssistantCubit _buildCubit\([^)]+\) \{[\s\S]*?\n\}/);
if (buildCubitMatch) {
  console.log('\n⚠️  _buildCubit helper found - OVERWRITES stubs after receiving mock!');
  console.log('   This is the ROOT CAUSE of test failures.');
}

// Generate solution
console.log('\n' + '='.repeat(60));
console.log('📋 RECOMMENDED SOLUTION: Factory Constructor Pattern\n');

const solution = `
// ============================================================================
// OPTION B: Factory Constructor (Recommended)
// ============================================================================
//
// Add to medical_assistant_cubit.dart:
//
// class MedicalAssistantCubit extends Cubit<MedicalAssistantState> {
//   
//   // Private constructor for production use (dependency injection)
//   MedicalAssistantCubit._internal({
//     required MedicalLlmAdapter llmAdapter,
//     MedicalAnalysisService? analysisService,
//     ClinicalReasonerService? reasoner,
//     HealthContextService? healthContext,
//     PromptScrubber? scrubber,
//     LabInterpreter? labInterpreter,
//     VitalSignAnalyzer? vitalAnalyzer,
//     RiskCalculator? riskCalculator,
//   }) : _llmAdapter = llmAdapter,
//        _analysisService = analysisService ?? getIt<MedicalAnalysisService>(),
//        _reasoner = reasoner ?? getIt<ClinicalReasonerService>(),
//        _healthContext = healthContext ?? getIt<HealthContextService>(),
//        _scrubber = scrubber ?? getIt<PromptScrubber>(),
//        _labInterpreter = labInterpreter ?? getIt<LabInterpreter>(),
//        _vitalAnalyzer = vitalAnalyzer ?? getIt<VitalSignAnalyzer>(),
//        _riskCalculator = riskCalculator ?? getIt<RiskCalculator>();
//   
//   // Factory for production (backward compatible)
//   factory MedicalAssistantCubit() {
//     return MedicalAssistantCubit._internal(
//       llmAdapter: getIt<MedicalLlmAdapter>(),
//     );
//   }
//   
//   // Factory for testing (CONTROLS stubs)
//   @visibleForTesting
//   factory MedicalAssistantCubit.withMocks({
//     required MedicalLlmAdapter llmAdapter,
//     MedicalAnalysisService? analysisService,
//     ClinicalReasonerService? reasoner,
//     HealthContextService? healthContext,
//     PromptScrubber? scrubber,
//     LabInterpreter? labInterpreter,
//     VitalSignAnalyzer? vitalAnalyzer,
//     RiskCalculator? riskCalculator,
//   }) {
//     return MedicalAssistantCubit._internal(
//       llmAdapter: llmAdapter,
//       analysisService: analysisService,
//       reasoner: reasoner,
//       healthContext: healthContext,
//       scrubber: scrubber,
//       labInterpreter: labInterpreter,
//       vitalAnalyzer: vitalAnalyzer,
//       riskCalculator: riskCalculator,
//     );
//   }
//   
//   // ... rest of cubit
// }

// ============================================================================
// TEST REFACTORING
// ============================================================================
// Replace _buildCubit usage with:
//
// final mockReasoner = MockClinicalReasonerService();
// when(() => mockReasoner.analyzeSymptoms(any()))
//     .thenAnswer((_) async => [...]);
//
// final cubit = MedicalAssistantCubit.withMocks(
//   llmAdapter: mockAdapter,
//   reasoner: mockReasoner,
//   // ... other mocks
// );
//
// This way stubs are NOT overwritten because we DON'T use _buildCubit.
`;

console.log(solution);

// Implementation plan
console.log('\n' + '='.repeat(60));
console.log('📅 IMPLEMENTATION PLAN\n');

const steps = [
  { step: 1, action: 'Create _internal private constructor', effort: '15 min', risk: 'Low' },
  { step: 2, action: 'Create factory constructors (production + testing)', effort: '10 min', risk: 'Low' },
  { step: 3, action: 'Add @visibleForTesting annotation', effort: '5 min', risk: 'Low' },
  { step: 4, action: 'Refactor _buildCubit helper to use .withMocks()', effort: '30 min', risk: 'Medium' },
  { step: 5, action: 'Run tests to verify all pass', effort: '10 min', risk: 'Low' },
  { step: 6, action: 'Commit with message: "refactor: add factory constructor for testability"', effort: '5 min', risk: 'Low' },
];

steps.forEach(s => {
  console.log(\`  \${s.step}. \${s.action}\`);
  console.log(\`     Effort: \${s.effort} | Risk: \${s.risk}\`);
});

console.log('\n' + '='.repeat(60));
console.log('✅ Total estimated time: ~1.5 hours');
console.log('🎯 Result: All tests pass without breaking API changes\n');
