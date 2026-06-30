import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class ScraperConfigPage extends StatefulWidget {
  const ScraperConfigPage({super.key});

  @override
  State<ScraperConfigPage> createState() => _ScraperConfigPageState();
}

class _ScraperConfigPageState extends State<ScraperConfigPage> {
  bool _enablePubMed = true;
  bool _enableFDA = true;
  bool _enableWHO = true;
  bool _enableClinicalTrials = true;
  double _timeout = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CONFIGURACIÓN DEL SCRAPER'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'FUENTES DE DATOS',
            style: TextStyle(
              color: CyberTheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          GlassmorphicCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('PubMed'),
                  value: _enablePubMed,
                  onChanged: (v) => setState(() => _enablePubMed = v),
                  activeThumbColor: CyberTheme.secondary,
                ),
                SwitchListTile(
                  title: const Text('FDA'),
                  value: _enableFDA,
                  onChanged: (v) => setState(() => _enableFDA = v),
                  activeThumbColor: CyberTheme.secondary,
                ),
                SwitchListTile(
                  title: const Text('WHO / OMS'),
                  value: _enableWHO,
                  onChanged: (v) => setState(() => _enableWHO = v),
                  activeThumbColor: CyberTheme.secondary,
                ),
                SwitchListTile(
                  title: const Text('ClinicalTrials.gov'),
                  value: _enableClinicalTrials,
                  onChanged: (v) => setState(() => _enableClinicalTrials = v),
                  activeThumbColor: CyberTheme.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'PARÁMETROS TÉCNICOS',
            style: TextStyle(
              color: CyberTheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          GlassmorphicCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Timeout de búsqueda: ${_timeout.toInt()}s'),
                  Slider(
                    value: _timeout,
                    min: 5,
                    max: 60,
                    divisions: 11,
                    onChanged: (v) => setState(() => _timeout = v),
                    activeColor: CyberTheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
