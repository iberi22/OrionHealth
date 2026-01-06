import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/dashboard/application/bloc/dashboard_cubit.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DashboardCubit>()..loadDashboard(),
      child: const _HomeDashboardView(),
    );
  }
}

class _HomeDashboardView extends StatelessWidget {
  const _HomeDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.local_hospital, color: CyberTheme.secondary),
        title: const Text('Resumen Médico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardCubit>().loadDashboard();
            },
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: CyberTheme.secondary),
            );
          }

          if (state is DashboardError) {
            return _buildErrorContent(context, state);
          }

          if (state is DashboardLoaded) {
            return _buildLoadedContent(context, state);
          }

          // Initial state - show loading
          return const Center(
            child: CircularProgressIndicator(color: CyberTheme.secondary),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(llmService: getIt<LlmService>()),
            ),
          );
        },
        icon: const Icon(Icons.chat),
        label: const Text('AI Assistant'),
        backgroundColor: CyberTheme.secondary,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, DashboardError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error al cargar datos',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.message,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardCubit>().loadDashboard();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, DashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
      color: CyberTheme.secondary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _ProfileHeader(userProfile: state.userProfile),
            const SizedBox(height: 24),
            // Critical Alert Card
            if (state.criticalAllergies.isNotEmpty)
              _CriticalAlertCard(allergies: state.criticalAllergies),
            if (state.criticalAllergies.isNotEmpty) const SizedBox(height: 24),
            // Health Metrics Grid
            Text(
              'Métricas de Salud',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: CyberTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _HealthMetricsGrid(metrics: state.healthMetrics),
            const SizedBox(height: 24),
            // Quick Actions
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: CyberTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _QuickActionsSection(parentContext: context),
            const SizedBox(height: 24),
            // Recent Activity
            _RecentActivitySection(recentActivity: state.recentActivity),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile? userProfile;

  const _ProfileHeader({this.userProfile});

  @override
  Widget build(BuildContext context) {
    final name = userProfile?.name ?? 'Usuario';
    final age = userProfile?.age;
    final uniqueId = userProfile?.uniqueId ?? 'ORION-000';
    final avatarUrl = userProfile?.avatarUrl;

    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CyberTheme.secondary, width: 2),
                color: Colors.grey[800],
              ),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildAvatarPlaceholder(name),
                      )
                    : _buildAvatarPlaceholder(name),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    age != null ? 'Edad: $age' : 'Edad: --',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'ID: $uniqueId',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : '?';
    return Container(
      color: CyberTheme.primary.withOpacity(0.3),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CriticalAlertCard extends StatelessWidget {
  final List<Allergy> allergies;

  const _CriticalAlertCard({required this.allergies});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CyberTheme.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CyberTheme.primary.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: CyberTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'ALERTA CRÍTICA',
                style: TextStyle(
                  color: CyberTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...allergies.map(
            (allergy) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alergia: ${allergy.name ?? "Desconocida"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (allergy.reaction != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      allergy.reaction!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthMetricsGrid extends StatelessWidget {
  final HealthMetricsSnapshot metrics;

  const _HealthMetricsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _MetricCard(
          icon: Icons.bloodtype,
          value: metrics.bloodType ?? '--',
          label: 'Tipo de Sangre',
        ),
        _MetricCard(
          icon: Icons.monitor_weight_outlined,
          value: metrics.formattedWeight,
          label: 'Peso',
        ),
        _MetricCard(
          icon: Icons.height,
          value: metrics.formattedHeight,
          label: 'Altura',
        ),
        _MetricCard(
          icon: Icons.favorite,
          value: metrics.formattedHeartRate,
          label: 'Pulso',
        ),
        _MetricCard(
          icon: Icons.thermostat,
          value: metrics.formattedTemperature,
          label: 'Temperatura',
        ),
        _MetricCard(
          icon: Icons.water_drop,
          value: metrics.formattedBloodPressure,
          label: 'Presión',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: CyberTheme.secondary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  final RecentActivity recentActivity;

  const _RecentActivitySection({required this.recentActivity});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: CyberTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _ActivityItem(
          icon: Icons.event_available,
          title: 'Última Consulta',
          subtitle: recentActivity.lastConsultation?.doctorName ?? '--',
          date: recentActivity.lastConsultation?.dateTime != null
              ? dateFormat.format(recentActivity.lastConsultation!.dateTime!)
              : '--',
        ),
        _ActivityItem(
          icon: Icons.calendar_month,
          title: 'Próxima Cita',
          subtitle: recentActivity.nextAppointment?.specialty ?? '--',
          date: recentActivity.nextAppointment?.dateTime != null
              ? dateFormat.format(recentActivity.nextAppointment!.dateTime!)
              : '--',
        ),
        _ActivityItem(
          icon: Icons.medication,
          title: 'Medicación Actual',
          subtitle: recentActivity.currentMedication?.displayName ?? '--',
          date: recentActivity.currentMedication?.frequencyLabel ?? '--',
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String date;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CyberTheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: CyberTheme.secondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final BuildContext parentContext;

  const _QuickActionsSection({required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _QuickActionCard(
          icon: Icons.chat_bubble_outline,
          label: 'AI Assistant',
          color: CyberTheme.secondary,
          onTap: () {
            Navigator.push(
              parentContext,
              MaterialPageRoute(
                builder: (context) => ChatPage(llmService: getIt<LlmService>()),
              ),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.favorite_border,
          label: 'Salud',
          color: Colors.red[400]!,
          onTap: () {
            // TODO: Navigate to health details
          },
        ),
        _QuickActionCard(
          icon: Icons.insights,
          label: 'Estadísticas',
          color: CyberTheme.primary,
          onTap: () {
            // TODO: Navigate to statistics
          },
        ),
        _QuickActionCard(
          icon: Icons.medical_services_outlined,
          label: 'Medicamentos',
          color: Colors.purple[400]!,
          onTap: () {
            // TODO: Navigate to medications list
          },
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900]?.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
