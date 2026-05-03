import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';

class MedicalNodeOnboarding extends StatefulWidget {
  const MedicalNodeOnboarding({super.key});

  @override
  State<MedicalNodeOnboarding> createState() => _MedicalNodeOnboardingState();
}

class _MedicalNodeOnboardingState extends State<MedicalNodeOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: const [
                  _WhatIsMedicalNetworkStep(),
                  _SecureDataSharingStep(),
                  _PatientBenefitsStep(),
                ],
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                '${_currentPage + 1} de $_totalPages',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(CyberTheme.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final isLastPage = _currentPage == _totalPages - 1;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CyberTheme.primary,
            foregroundColor: CyberTheme.backgroundDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _nextPage,
          child: Text(
            isLastPage ? 'Entendido' : 'Siguiente',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

/// Step 1: What is the medical network
class _WhatIsMedicalNetworkStep extends StatelessWidget {
  const _WhatIsMedicalNetworkStep();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: CyberTheme.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_hospital,
              size: 50,
              color: CyberTheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '¿Qué es la Red Médica?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'La Red Médica OrionHealth es una red de centros de salud, laboratorios y especialistas conectados para brindarte atención integral.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildFeatureItem(
            Icons.location_on,
            'Red de atención en todo el país',
          ),
          _buildFeatureItem(
            Icons.medical_services,
            'Especialistas en múltiples áreas',
          ),
          _buildFeatureItem(
            Icons.access_time,
            'Agenda de citas en línea',
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: CyberTheme.secondary, size: 20),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 2: How data is shared securely
class _SecureDataSharingStep extends StatelessWidget {
  const _SecureDataSharingStep();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: CyberTheme.secondary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security,
              size: 50,
              color: CyberTheme.secondary,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Tus datos, seguros',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tu información médica se comparte de forma segura y solo con tu consentimiento entre los profesionales de la red.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildSecurityItem(
            Icons.lock,
            'Cifrado de extremo a extremo',
          ),
          _buildSecurityItem(
            Icons.verified_user,
            'Autenticación biométrica',
          ),
          _buildSecurityItem(
            Icons.privacy_tip,
            'Tú controlas quién accede',
          ),
          _buildSecurityItem(
            Icons.rule,
            'Cumplimiento HIPAA',
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: CyberTheme.secondary, size: 20),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 3: Benefits for the patient
class _PatientBenefitsStep extends StatelessWidget {
  const _PatientBenefitsStep();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: CyberTheme.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              size: 50,
              color: CyberTheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Beneficios para ti',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Al unirte a la Red Médica OrionHealth, obtienes acceso a beneficios exclusivos para tu salud.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildBenefitItem(
            Icons.history,
            'Historial médico unificado',
          ),
          _buildBenefitItem(
            Icons.receipt_long,
            'Resultados en línea',
          ),
          _buildBenefitItem(
            Icons.card_membership,
            'Descuentos en medicamentos',
          ),
          _buildBenefitItem(
            Icons.support_agent,
            'Asistente de salud 24/7',
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: CyberTheme.primary, size: 20),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
