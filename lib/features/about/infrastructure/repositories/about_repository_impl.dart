import 'package:injectable/injectable.dart';
import '../../domain/entities/about_info.dart';
import '../../domain/repositories/i_about_repository.dart';

@LazySingleton(as: IAboutRepository)
class AboutRepositoryImpl implements IAboutRepository {
  @override
  Future<AboutInfo> getAboutInfo() async {
    // In a real app, this might come from an API or local DB.
    // For now, we use the static data moved from the legacy data folder.
    return const AboutInfo(
      blogPosts: _staticBlogPosts,
      missionStatement: 'Creemos que la salud es el activo más valioso de la humanidad. OrionHealth nace con la visión de poner la tecnología más avanzada al servicio del bienestar individual, garantizando la privacidad y el empoderamiento del paciente.',
      values: [
        'Cada persona merece acceso a su historial médico completo',
        'La privacidad médica es un derecho fundamental',
        'La IA médica debe estar al servicio de la salud, no de corporaciones',
        'Los datos de salud empoderan a las personas para tomar mejores decisiones',
      ],
      activities: [
        'Almacenamos datos médicos de forma segura y encriptada en tu dispositivo',
        'Permitimos que modelos de IA analicen tu información para ayudarte',
        'Buscamos información médica actualizada de fuentes científicas confiables',
        'Conectamos personas con estándares de medicina mundial',
      ],
    );
  }
}

const List<BlogPost> _staticBlogPosts = [
  BlogPost(
    title: 'Avances médicos que impactan tu salud',
    content: 'La medicina personalizada está avanzando a pasos agigantados. Gracias al análisis de datos a gran escala, ahora es posible adaptar los tratamientos a la genética y el historial único de cada paciente. En OrionHealth, te preparamos para esta revolución permitiéndote ser el dueño de tu propia información médica.',
    date: '10 de Mayo, 2024',
    category: 'Ciencia',
  ),
  BlogPost(
    title: 'Cómo proteger tus datos médicos',
    content: 'Tus datos de salud son los más sensibles que posees. Nunca los compartas en plataformas que no garanticen cifrado de extremo a extremo o que almacenen tu información en la nube sin tu consentimiento explícito. OrionHealth almacena todo localmente en tu dispositivo, asegurando que solo tú tengas la llave.',
    date: '15 de Mayo, 2024',
    category: 'Privacidad',
  ),
  BlogPost(
    title: 'Nuevas features de OrionHealth',
    content: 'Hemos integrado modelos de IA locales (Gemma y Ollama) para que puedas analizar tus laboratorios sin que un solo dato salga de tu teléfono. Además, nuestra nueva función de intercambio seguro por BLE permite que muestres tu historial al médico sin necesidad de internet.',
    date: '20 de Mayo, 2024',
    category: 'Actualizaciones',
  ),
  BlogPost(
    title: 'Educación sobre estándares médicos mundiales',
    content: '¿Sabías qué es ICD-10 o LOINC? Son lenguajes universales que permiten que médicos de todo el mundo entiendan tus diagnósticos y exámenes. OrionHealth utiliza estos estándares para que tu historial sea válido y comprensible en cualquier parte del planeta.',
    date: '25 de Mayo, 2024',
    category: 'Educación',
  ),
];
