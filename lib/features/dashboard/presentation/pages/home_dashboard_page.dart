import 'package:flutter/material.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/cyber_theme.dart';
import '../../../../../core/widgets/glassmorphic_card.dart';
import '../../../local_agent/infrastructure/llm_service.dart';
import '../../../local_agent/presentation/chat_page.dart';
import '../../../vitals/presentation/pages/vitals_page.dart';
import '../../../medications/presentation/pages/medications_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../health_record/presentation/pages/timeline_page.dart';
import '../../../medical_research/presentation/pages/medical_research_page.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                _buildQuickActionsHeader(context),
                const SizedBox(height: 16),
                _buildQuickActionsGrid(context),
                const SizedBox(height: 32),
                _buildRecentActivityHeader(context),
                const SizedBox(height: 16),
                _buildRecentActivityList(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsHeader(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.flash_on, color: CyberTheme.secondary, size: 20),
        SizedBox(width: 8),
        Text(
          'ACCIONES RÁPIDAS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _QuickActionCard(
          title: 'AI Assistant',
          icon: Icons.psychology,
          color: CyberTheme.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(llmService: getIt<LlmService>()),
            ),
          ),
        ),
        _QuickActionCard(
          title: 'Salud',
          icon: Icons.favorite,
          color: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VitalsPage(),
            ),
          ),
        ),
        _QuickActionCard(
          title: 'Estadísticas',
          icon: Icons.bar_chart,
          color: CyberTheme.secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReportsPage(),
            ),
          ),
        ),
        _QuickActionCard(
          title: 'Medicamentos',
          icon: Icons.medication,
          color: Colors.orangeAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MedicationsPage(),
            ),
          ),
        ),
        _QuickActionCard(
          title: 'Timeline',
          icon: Icons.timeline,
          color: Colors.tealAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TimelinePage(),
            ),
          ),
        ),
        _QuickActionCard(
          title: 'Investigación',
          icon: Icons.science,
          color: Colors.purpleAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MedicalResearchPage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityHeader(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.history, color: CyberTheme.secondary, size: 20),
        SizedBox(width: 8),
        Text(
          'ACTIVIDAD RECIENTE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList(BuildContext context) {
    return const Column(
      children: [
        _ActivityTile(
          title: 'Chequeo de presión',
          time: 'Hace 2 horas',
          icon: Icons.monitor_heart,
        ),
        SizedBox(height: 12),
        _ActivityTile(
          title: 'Medicamento: Vitamina C',
          time: 'Hace 5 horas',
          icon: Icons.done,
        ),
        SizedBox(height: 12),
        _ActivityTile(
          title: 'Informe semanal generado',
          time: 'Ayer',
          icon: Icons.description,
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const _ActivityTile({
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CyberTheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: CyberTheme.secondary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time, style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}
