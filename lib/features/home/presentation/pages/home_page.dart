// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../local_agent/infrastructure/llm_service.dart';
import '../../../local_agent/presentation/chat_page.dart';
import '../../../vitals/presentation/pages/vitals_page.dart';
import '../../../medications/presentation/pages/medications_page.dart';
import '../../../health_record/presentation/pages/timeline_page.dart';
import '../../../meditation/presentation/meditation_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../medical_research/presentation/pages/medical_research_page.dart';
import '../../../user_profile/domain/entities/user_profile.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../eps_connection/presentation/pages/eps_connection_page.dart';
import '../../application/home_cubit.dart';
import '../../application/home_state.dart';
import '../widgets/health_status_grid.dart';
import '../widgets/module_cards.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeCubit>()..loadDashboard(),
      child: const HomePageView(),
    );
  }
}

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeCubit>().refresh(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'ORION HEALTH',
                  style: TextStyle(
                    color: CyberTheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // EPS Connection Status Banner
                  const _EpsStatusBanner(),
                  const SizedBox(height: 16),
                  _buildSectionHeader('RESUMEN DE SALUD', Icons.analytics),
                  const SizedBox(height: 16),
                  const HealthStatusGrid(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('MÓDULOS', Icons.grid_view),
                  const SizedBox(height: 16),
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state.status == HomeStatus.loading && state.modules.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ModuleCards(
                        modules: state.modules,
                        onModuleTap: (module) {
                          _handleNavigation(context, module.route);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildUpcomingAppointments(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    Widget? page;
    switch (route) {
      case '/chat':
        page = ChatPage(llmService: getIt<LlmService>());
        break;
      case '/vitals':
        page = const VitalsPage();
        break;
      case '/medications':
        page = const MedicationsPage();
        break;
      case '/timeline':
        page = const TimelinePage();
        break;
      case '/meditation':
        page = const MeditationPage();
        break;
      case '/reports':
        page = const ReportsPage();
        break;
      case '/research':
        page = const MedicalResearchPage();
        break;
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: CyberTheme.secondary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointments(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final appointments = state.healthSummary?.upcomingAppointments ?? [];
        if (appointments.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('PRÓXIMAS CITAS', Icons.calendar_today),
            const SizedBox(height: 16),
            ...appointments.map((appointment) => ListTile(
              title: Text(appointment.doctorName),
              subtitle: Text(appointment.specialty),
              trailing: Text(appointment.dateTime.toString()),
            )),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

/// Displays the EPS connection status on the home page.
///
/// - If EPS connected: shows a green card with EPS name and options
/// - If not connected: shows a subtle card with "Conectar EPS" CTA
class _EpsStatusBanner extends StatelessWidget {
  const _EpsStatusBanner();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: getIt<UserProfileRepository>().getUserProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;

        if (profile == null || !profile.onboardingCompleted) {
          return const SizedBox.shrink();
        }

        if (profile.isEpsConnected) {
          return _buildConnectedCard(context, profile);
        }

        return _buildDisconnectedCard(context);
      },
    );
  }

  Widget _buildConnectedCard(BuildContext context, UserProfile profile) {
    final epsName = profile.epsPatientId ?? 'EPS';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EpsConnectionPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (CyberTheme.success).withValues(alpha: 0.12),
              (CyberTheme.success).withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (CyberTheme.success).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (CyberTheme.success).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.health_and_safety,
                color: CyberTheme.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'EPS Conectada',
                        style: TextStyle(
                          color: CyberTheme.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: CyberTheme.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (CyberTheme.success)
                                  .withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    epsName.replaceAll('EPS', 'EPS ').trim(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  if (profile.epsPatientId != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Paciente: ${profile.epsPatientId}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildDisconnectedCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EpsConnectionPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CyberTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance,
                color: CyberTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Conectar mi EPS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Importá tus datos de salud automáticamente',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CyberTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Conectar',
                style: TextStyle(
                  color: CyberTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
