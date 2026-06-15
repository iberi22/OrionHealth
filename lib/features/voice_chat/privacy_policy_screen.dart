import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Política de Privacidad',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<String>(
        future: _loadPrivacyPolicy(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar la política de privacidad',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Entendido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<String> _loadPrivacyPolicy() async {
    try {
      return await rootBundle.loadString('assets/privacy_policy.md');
    } catch (e) {
      return _getDefaultPrivacyPolicy();
    }
  }

  String _getDefaultPrivacyPolicy() {
    return '''
# Política de Privacidad - Orion

**Última actualización: Junio 2026**

## Introducción

Bienvenido a Orion, tu compañero de bienestar 100% local. Esta Política de Privacidad explica cómo manejamos tu información. Orion está diseñado con una filosofía "local-first", lo que significa que tus datos permanecen en tu dispositivo.

## Manejo de la Información

### Información Personal
- **Perfil Local**: Tu nombre y preferencias se almacenan localmente en tu dispositivo.
- **Datos de Voz**: Las grabaciones de audio se procesan localmente y no se almacenan permanentemente.
- **Datos de Bienestar**: Las sesiones y el progreso se guardan exclusivamente en tu base de datos local.

### Almacenamiento y Seguridad
- **Sin Nube**: Orion no utiliza Firebase ni almacenamiento en la nube para tus datos de bienestar.
- **Base de Datos Local**: Todo se almacena en una base de datos Isar en tu dispositivo.
- **Privacidad Total**: El procesamiento de voz ocurre localmente y nada sale de tu dispositivo.

## Tus Derechos
- Tienes control total: puedes acceder, exportar o eliminar todos tus datos desde la configuración de la app en cualquier momento.

## Contacto
- **Email**: privacy@orion-wellness.com

---

*Orion: Tu privacidad, tu dispositivo, tu crecimiento.*
    ''';
  }
}
