import 'package:flutter_test/flutter_test.dart';
import 'package:research_package/research_package.dart';
import 'package:orionhealth_health/features/clinical_assessments/domain/models/health_survey.dart';

void main() {
  group('LocalHealthSurvey', () {
    test('surveyTask returns an RPOrderedTask with the correct identifier', () {
      final task = LocalHealthSurvey.surveyTask;

      expect(task, isA<RPOrderedTask>());
      expect(task.identifier, 'health_survey_task');
    });

    test('surveyTask has 4 steps in correct order', () {
      final task = LocalHealthSurvey.surveyTask;
      final steps = task.steps;

      expect(steps.length, 4);
      expect(steps[0], isA<RPInstructionStep>());
      expect(steps[0].identifier, 'instructionID');
      expect(steps[1], isA<RPQuestionStep>());
      expect(steps[1].identifier, 'pain_level_step');
      expect(steps[2], isA<RPQuestionStep>());
      expect(steps[2].identifier, 'medication_step');
      expect(steps[3], isA<RPCompletionStep>());
      expect(steps[3].identifier, 'completionID');
    });

    test('instruction step has correct title and detailText', () {
      final task = LocalHealthSurvey.surveyTask;
      final instruction = task.steps[0] as RPInstructionStep;

      expect(instruction.title, 'Cuestionario de Salud General');
      expect(instruction.detailText, 'Para personalizar tu experiencia, responde a estas preguntas.');
      expect(instruction.text, 'Todos tus datos se guardan solo en este dispositivo.');
    });

    test('pain_level_step uses integer answer format 0-10', () {
      final task = LocalHealthSurvey.surveyTask;
      final painStep = task.steps[1] as RPQuestionStep;

      expect(painStep.title, '¿Cuál es tu nivel de dolor actual?');
      expect(painStep.answerFormat, isA<RPIntegerAnswerFormat>());

      final answerFormat = painStep.answerFormat as RPIntegerAnswerFormat;
      expect(answerFormat.minValue, 0);
      expect(answerFormat.maxValue, 10);
    });

    test('medication_step uses single choice with Sí/No', () {
      final task = LocalHealthSurvey.surveyTask;
      final medicationStep = task.steps[2] as RPQuestionStep;

      expect(medicationStep.title, '¿Estás tomando alguna medicación actualmente?');
      expect(medicationStep.answerFormat, isA<RPChoiceAnswerFormat>());

      final answerFormat = medicationStep.answerFormat as RPChoiceAnswerFormat;
      expect(answerFormat.answerStyle, RPChoiceAnswerStyle.SingleChoice);
      expect(answerFormat.choices.length, 2);
      expect(answerFormat.choices[0].text, 'Sí');
      expect(answerFormat.choices[0].value, 1);
      expect(answerFormat.choices[1].text, 'No');
      expect(answerFormat.choices[1].value, 0);
    });

    test('completion step has correct title and text', () {
      final task = LocalHealthSurvey.surveyTask;
      final completion = task.steps[3] as RPCompletionStep;

      expect(completion.identifier, 'completionID');
      expect(completion.title, '¡Gracias!');
      expect(completion.text, 'Tus respuestas han sido guardadas de forma segura y local.');
    });
  });
}
