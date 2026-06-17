import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/health_status_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const IndexingStatusBanner(),
            Text('Gestiona tu salud y consulta con tu asistente IA'),
            const HealthStatusGrid(),
            const Text('Información Reciente'),
            const Text('100% Local y Privado'),
            const Text('Consulta a tu Asistente IA'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Iniciar Consulta'),
            ),
          ],
        ),
      ),
    );
  }
}
