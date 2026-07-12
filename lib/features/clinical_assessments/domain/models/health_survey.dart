import 'package:research_package/research_package.dart';

class LocalHealthSurvey {
  static RPOrderedTask get surveyTask {
    // Instruction Step
    RPInstructionStep instructionStep = RPInstructionStep(
      identifier: "instructionID",
      title: "Cuestionario de Salud General",
      detailText: "Para personalizar tu experiencia, responde a estas preguntas.",
      text: "Todos tus datos se guardan solo en este dispositivo.",
    );

    // Question Step 1: Pain Level
    RPIntegerAnswerFormat painFormat = RPIntegerAnswerFormat(minValue: 0, maxValue: 10);
    RPQuestionStep painStep = RPQuestionStep(
      identifier: "pain_level_step",
      title: "¿Cuál es tu nivel de dolor actual?",
      answerFormat: painFormat,
    );

    // Question Step 2: Medication
    RPChoiceAnswerFormat medicationFormat = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
      choices: [
        RPChoice(text: "Sí", value: 1),
        RPChoice(text: "No", value: 0),
      ],
    );
    RPQuestionStep medicationStep = RPQuestionStep(
      identifier: "medication_step",
      title: "¿Estás tomando alguna medicación actualmente?",
      answerFormat: medicationFormat,
    );

    // Completion Step
    RPCompletionStep completionStep = RPCompletionStep(
      identifier: "completionID",
      title: "¡Gracias!",
      text: "Tus respuestas han sido guardadas de forma segura y local.",
    );

    RPOrderedTask task = RPOrderedTask(
      identifier: "health_survey_task",
      steps: [
        instructionStep,
        painStep,
        medicationStep,
        completionStep,
      ],
    );

    return task;
  }
}
