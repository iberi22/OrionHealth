import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../infrastructure/services/patient_portal_extractor.dart';
import '../../infrastructure/services/eps_url_validator.dart';
import '../../domain/entities/eps_provider.dart';
import '../../domain/entities/eps_providers_catalog.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../../core/theme/app_colors.dart';

/// EPS Patient Portal Authentication Screen
///
/// Displays the EPS provider's web portal in an embedded WebView
/// for the patient to authenticate using their existing EPS credentials.
/// Once authenticated, the PatientPortalExtractor intercepts the session
/// and extracts clinical data (history, medications, immunizations, etc.)
/// via on-device RPA with zero data leaving the device.
///
/// Architecture: Local-First Hybrid (Option C)
/// Compliance: Ley 2015 de 2020 (Colombia) — patient data portability
class EpsPatientPortalScreen extends StatefulWidget {
  final EPSProvider provider;

  const EpsPatientPortalScreen({super.key, required this.provider});

  @override
  State<EpsPatientPortalScreen> createState() => _EpsPatientPortalScreenState();
}

class _EpsPatientPortalScreenState extends State<EpsPatientPortalScreen> {
  late final PatientPortalExtractor _extractor;
  StreamSubscription<ExtractionProgress>? _progressSubscription;

  ExtractionProgress _currentStep = const ExtractionProgress(
    phase: ExtractionPhase.recognition,
    step: '',
    message: 'Initializing secure connection...',
    progress: 0.0,
  );

  UserProfile? _extractedProfile;
  bool _isComplete = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _extractor = PatientPortalExtractor(
      secureStorage: const FlutterSecureStorage(),
      epsId: widget.provider.id,
      epsPortalUrl: EpsProvidersCatalog.getPortalUrl(widget.provider.id),
      epsName: widget.provider.name,
    );
    _progressSubscription = _extractor.progress.listen(_onProgressUpdate);
  }

  void _onProgressUpdate(ExtractionProgress p) {
    if (mounted) {
      setState(() {
        _currentStep = p;
        if (p.phase == ExtractionPhase.complete) {
          _extractedProfile = _extractor.extractedProfile;
          _isComplete = true;
        } else if (p.phase == ExtractionPhase.error) {
          _errorMessage = p.message;
        }
      });
    }
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _extractor.dispose();
    super.dispose();
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.black54,
      child: Row(
        children: [
          const Icon(Icons.security, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Portal Seguro — Inicia sesión para importar tus datos',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.provider.name),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, Colors.black],
          ),
        ),
        child: SafeArea(
          child: _isComplete
              ? _buildCompleteView()
              : _errorMessage != null
                  ? _buildErrorView()
                  : _currentStep.phase == ExtractionPhase.recognition
                      ? Column(
                          children: [
                            _buildProgressHeader(),
                            Expanded(
                              child: InAppWebView(
                                initialUrlRequest: URLRequest(
                                  url: WebUri(EpsProvidersCatalog.getPortalUrl(widget.provider.id)),
                                ),
                                initialSettings: InAppWebViewSettings(
                                  javaScriptEnabled: true,
                                  domStorageEnabled: true,
                                  cacheEnabled: true,
                                  userAgent: _extractor.mobileUserAgent(),
                                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                                ),
                                shouldInterceptRequest: (controller, request) async {
                                  return await _extractor.onInterceptRequest(controller, request);
                                },
                                shouldOverrideUrlLoading: (controller, navigationAction) async {
                                  final url = navigationAction.request.url.toString();
                                  if (EpsUrlValidator.isUrlAllowed(url, widget.provider.id)) {
                                    return NavigationActionPolicy.ALLOW;
                                  } else {
                                    debugPrint('Blocked navigation to unauthorized URL: $url');
                                    return NavigationActionPolicy.CANCEL;
                                  }
                                },
                                onLoadStop: (controller, url) {
                                  _extractor.onPageLoadComplete(controller, url);
                                },
                                onUpdateVisitedHistory: (controller, url, isReload) {
                                  _extractor.onNavigationChange(controller, url, isReload);
                                },
                              ),
                            ),
                          ],
                        )
                      : _buildExtractionProgressView(),
        ),
      ),
    );
  }

  Widget _buildExtractionProgressView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Provider logo area
          const Icon(Icons.local_hospital, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            widget.provider.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Local Patient Data Import',
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

          // Progress indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _currentStep.progress,
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),

          // Phase badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _phaseLabel(_currentStep.phase),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status message
          Text(
            _currentStep.message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),

          const SizedBox(height: 48),

          // Security notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.green, size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'On-device processing only.\n'
                    'OrionHealth does not store your EPS password.',
                    style: TextStyle(color: Colors.green, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          // Instruction for recognition phase
          if (_currentStep.phase == ExtractionPhase.recognition)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                'The ${widget.provider.name} portal will open.\n'
                'Log in with your normal credentials.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompleteView() {
    final p = _extractedProfile!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.check_circle_outline, size: 72, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Data Import Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Source: ${widget.provider.name}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          ),
          const SizedBox(height: 32),

          // Extracted data summary
          _summaryRow('Name', p.name ?? 'Not detected'),
          _summaryRow('Document', p.epsPatientId ?? 'Not detected'),
          _summaryRow('Sex', p.sex ?? 'Not specified'),
          if (p.birthDate != null)
            _summaryRow(
              'Date of Birth',
              '${p.birthDate!.day}/${p.birthDate!.month}/${p.birthDate!.year}',
            ),
          if (p.conditions.isNotEmpty)
            _summaryRow('Conditions', p.conditions.join(', ')),
          if (p.medications.isNotEmpty)
            _summaryRow('Medications', p.medications.join(', ')),
          if (p.allergies.isNotEmpty)
            _summaryRow('Allergies', p.allergies.join(', ')),

          const SizedBox(height: 32),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(p),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Import Error',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _phaseLabel(ExtractionPhase phase) {
    switch (phase) {
      case ExtractionPhase.recognition:
        return 'Phase 1/3 — Endpoint Discovery';
      case ExtractionPhase.extraction:
        return 'Phase 2/3 — Data Extraction';
      case ExtractionPhase.mapping:
        return 'Phase 3/3 — Profile Mapping';
      case ExtractionPhase.complete:
        return 'Complete';
      case ExtractionPhase.error:
        return 'Error';
    }
  }
}
