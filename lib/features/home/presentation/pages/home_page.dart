import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../local_agent/infrastructure/services/medical_indexing_service.dart';
import '../../../medical_assistant/domain/entities/medical_insight.dart';
import '../../../medical_assistant/domain/services/medical_analysis_service.dart';
import '../../../medical_assistant/presentation/pages/medical_assistant_page.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../vitals/domain/entities/vital_sign.dart';
import '../../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../../vitals/presentation/pages/vitals_monitor_page.dart';
import '../../application/home_cubit.dart';
import '../../application/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => HomeCubit(
        getIt<VitalSignRepository>(),
        getIt<MedicalIndexingService>(),
        getIt<MedicalAnalysisService>(),
        getIt<UserProfileRepository>(),
      ),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: l10n.homeTitle,
                  subtitle: l10n.homeSubtitle,
                ),
                const IndexingStatusBanner(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const HealthStatusGrid(),
                      const SizedBox(height: 24),
                      const RecentInsightsSection(),
                      const SizedBox(height: 24),
                      const LocalAgentPromo(),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IndexingStatusBanner extends StatefulWidget {
  const IndexingStatusBanner({super.key});

  @override
  State<IndexingStatusBanner> createState() => _IndexingStatusBannerState();
}

class _IndexingStatusBannerState extends State<IndexingStatusBanner> {
  bool _showSuccess = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (prev, curr) => prev.isIndexing != curr.isIndexing,
      listener: (context, state) {
        if (!state.isIndexing && !state.indexingError) {
          setState(() => _showSuccess = true);
          _hideTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) setState(() => _showSuccess = false);
          });
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          if (state.isIndexing) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.blue.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.syncingStandards,
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            );
          }

          if (state.indexingError) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.red.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.syncError,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<HomeCubit>().retryIndexing(),
                    child: Text(l10n.retry, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }

          if (_showSuccess) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.green.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 12),
                  Text(
                    l10n.syncCompleted,
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class HealthStatusGrid extends StatelessWidget {
  const HealthStatusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final vitals = state.latestVitals;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            StatusCard(
              icon: Icons.favorite,
              label: l10n.heartRate,
              value: vitals[VitalSignType.heartRate]?.formattedValue ?? l10n.noData,
              color: Colors.redAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VitalsMonitorPage()),
              ),
            ),
            StatusCard(
              icon: Icons.bloodtype,
              label: l10n.bloodPressure,
              value: _formatBloodPressure(
                vitals[VitalSignType.bloodPressureSystolic],
                vitals[VitalSignType.bloodPressureDiastolic],
                l10n,
              ),
              color: Colors.blueAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VitalsMonitorPage()),
              ),
            ),
            StatusCard(
              icon: Icons.thermostat,
              label: l10n.temperature,
              value: vitals[VitalSignType.temperature]?.formattedValue ?? l10n.noData,
              color: Colors.orangeAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VitalsMonitorPage()),
              ),
            ),
            StatusCard(
              icon: Icons.water_drop,
              label: l10n.oxygenSaturation,
              value: vitals[VitalSignType.spO2]?.formattedValue ?? l10n.noData,
              color: Colors.cyanAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VitalsMonitorPage()),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatBloodPressure(VitalSign? systolic, VitalSign? diastolic, AppLocalizations l10n) {
    if (systolic == null || diastolic == null) return l10n.noData;
    return '${systolic.value.toInt()}/${diastolic.value.toInt()}';
  }
}

class StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const StatusCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (value.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(Icons.add_circle_outline, size: 14, color: color.withValues(alpha: 0.5)),
            ),
        ],
      ),
    );
  }
}

class RecentInsightsSection extends StatelessWidget {
  const RecentInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.recentInsights,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (state.recentInsights.isEmpty)
              _buildFallbackInsight(state.isLoadingVitals, l10n)
            else
              _buildInsightCard(state.recentInsights.first),
          ],
        );
      },
    );
  }

  Widget _buildInsightCard(MedicalInsight insight) {
    Color severityColor;
    IconData severityIcon;

    switch (insight.severity) {
      case InsightSeverity.critical:
        severityColor = Colors.redAccent;
        severityIcon = Icons.warning_rounded;
        break;
      case InsightSeverity.alert:
        severityColor = Colors.orangeAccent;
        severityIcon = Icons.priority_high_rounded;
        break;
      case InsightSeverity.warning:
        severityColor = Colors.yellowAccent;
        severityIcon = Icons.info_outline_rounded;
        break;
      case InsightSeverity.info:
        severityColor = Colors.greenAccent;
        severityIcon = Icons.auto_awesome;
        break;
    }

    return GlassmorphicCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(severityIcon, color: severityColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(insight.description,
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackInsight(bool isLoading, AppLocalizations l10n) {
    return GlassmorphicCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.info_outline, color: Colors.blueAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? l10n.analyzingData : l10n.noAnomaliesDetected,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading
                      ? l10n.waitProcessing
                      : l10n.recordMoreVitals,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocalAgentPromo extends StatelessWidget {
  const LocalAgentPromo({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.darkTheme.primaryColor.withValues(alpha: 0.2), Colors.transparent]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(l10n.privacy100Local, style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.consultAssistant, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.assistantDescription, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedicalAssistantPage()),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(l10n.startConsultation),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkTheme.primaryColor, foregroundColor: Colors.black),
          ),
        ],
      ),
    );
  }
}
