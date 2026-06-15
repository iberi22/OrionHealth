// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';

/// Local datasource for static/asset-based about content.
///
/// Encapsulates the source of truth for about info (assets, remote, etc.)
/// so the repository layer remains agnostic to data sourcing strategy.
@lazySingleton
class AboutLocalDataSource {
  /// Returns raw static about info data.
  /// Could be replaced with asset JSON loading or remote fetch later.
  Map<String, dynamic> getStaticAboutData() {
    return {
      'missionStatement':
          'Creemos que la salud es el activo más valioso de la humanidad. '
          'OrionHealth nace con la visión de poner la tecnología más avanzada '
          'al servicio del bienestar individual, garantizando la privacidad y '
          'el empoderamiento del paciente.',
      'values': [
        'Cada persona merece acceso a su historial médico completo',
        'La privacidad médica es un derecho fundamental',
        'La IA médica debe estar al servicio de la salud, no de corporaciones',
        'Los datos de salud empoderan a las personas para tomar mejores decisiones',
      ],
      'activities': [
        'Almacenamos datos médicos de forma segura y encriptada en tu dispositivo',
        'Permitimos que modelos de IA analicen tu información para ayudarte',
        'Buscamos información médica actualizada de fuentes científicas confiables',
        'Conectamos personas con estándares de medicina mundial',
      ],
      'blogPosts': [
        {
          'title': 'Avances médicos que impactan tu salud',
          'content':
              'La medicina personalizada está avanzando a pasos agigantados. '
              'Gracias al análisis de datos a gran escala, ahora es posible '
              'adaptar los tratamientos a la genética y el historial único de cada paciente.',
          'date': '10 de Mayo, 2024',
          'category': 'Ciencia',
        },
        {
          'title': 'Cómo proteger tus datos médicos',
          'content':
              'Tus datos de salud son los más sensibles que posees. Nunca los compartas '
              'en plataformas que no garanticen cifrado de extremo a extremo.',
          'date': '15 de Mayo, 2024',
          'category': 'Privacidad',
        },
        {
          'title': 'Nuevas features de OrionHealth',
          'content':
              'Hemos integrado modelos de IA locales para que puedas analizar '
              'tus laboratorios sin que un solo dato salga de tu teléfono.',
          'date': '20 de Mayo, 2024',
          'category': 'Actualizaciones',
        },
        {
          'title': 'Educación sobre estándares médicos mundiales',
          'content':
              'OrionHealth utiliza estándares universales como ICD-10 o LOINC para '
              'que tu historial sea válido en cualquier parte del planeta.',
          'date': '25 de Mayo, 2024',
          'category': 'Educación',
        },
      ],
    };
  }
}
