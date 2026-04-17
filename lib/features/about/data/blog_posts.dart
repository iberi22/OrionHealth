class BlogPost {
  final String title;
  final String content;
  final String date;
  final String category;

  const BlogPost({
    required this.title,
    required this.content,
    required this.date,
    required this.category,
  });
}

const List<BlogPost> staticBlogPosts = [
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
