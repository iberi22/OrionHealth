import 'package:research_package/research_package.dart';

class LocalConsentDocument {
  static RPConsentDocument get consentDocument {
    final dataGatheringSection = RPConsentSection(
      type: RPConsentSectionType.DataGathering,
      summary: 'Recolección de Datos Locales',
      content:
          'Esta aplicación utiliza tu dispositivo móvil para recolectar información sobre tu salud. Todos los datos, incluyendo métricas y respuestas, se procesan y almacenan EXCLUSIVAMENTE en tu dispositivo personal.',
    );

    final privacySection = RPConsentSection(
      type: RPConsentSectionType.Privacy,
      summary: 'Privacidad 100% Local',
      content:
          'Tus datos no se subirán a ninguna nube ni servidor externo. Orion Health opera de forma totalmente local, asegurando tu privacidad según los estándares HIPAA y garantizando que solo tú tienes acceso a esta información.',
    );

    return RPConsentDocument(
      title: 'Consentimiento Informado - Orion Health',
      sections: [dataGatheringSection, privacySection],
    )..signatures = [RPConsentSignature(identifier: 'patient_signature')];
  }
}
