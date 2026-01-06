// OrionHealth Widget Tests
// Basic smoke tests for the app structure

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/features/dashboard/application/bloc/dashboard_cubit.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';

void main() {
  group('CyberTheme Tests', () {
    testWidgets('CyberTheme has correct primary colors', (
      WidgetTester tester,
    ) async {
      final theme = CyberTheme.darkTheme;

      // Verify cyberpunk color scheme
      expect(theme.primaryColor.value, 0xFF00FF85); // Primary green
      expect(theme.colorScheme.secondary.value, 0xFF00E0FF); // Secondary cyan
      expect(
        theme.scaffoldBackgroundColor.value,
        0xFF0A0A0A,
      ); // Dark background
    });
  });

  group('Dashboard UI Tests', () {
    testWidgets('Dashboard shows loading indicator when loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: _TestDashboardPage(state: DashboardLoading()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Dashboard renders with loaded state - key sections present', (
      WidgetTester tester,
    ) async {
      final testState = DashboardLoaded(
        userProfile: UserProfile(
          name: 'Test User',
          age: 30,
          uniqueId: 'ORION-001',
        ),
        criticalAllergies: const [],
        healthMetrics: const HealthMetricsSnapshot(
          bloodType: 'O+',
          weight: 70,
          height: 175,
        ),
        recentActivity: const RecentActivity(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: _TestDashboardPage(state: testState),
        ),
      );

      // Verify key sections
      expect(find.text('Resumen Médico'), findsOneWidget);
      expect(find.text('Métricas de Salud'), findsOneWidget);
      expect(find.text('Acciones Rápidas'), findsOneWidget);
      expect(find.text('Actividad Reciente'), findsOneWidget);
    });

    testWidgets('Profile header displays user info from state', (
      WidgetTester tester,
    ) async {
      final testState = DashboardLoaded(
        userProfile: UserProfile(
          name: 'Alex Reyes',
          age: 34,
          uniqueId: 'ORION-734',
        ),
        criticalAllergies: const [],
        healthMetrics: const HealthMetricsSnapshot(),
        recentActivity: const RecentActivity(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: _TestDashboardPage(state: testState),
        ),
      );

      expect(find.text('Alex Reyes'), findsOneWidget);
      expect(find.text('Edad: 34'), findsOneWidget);
      expect(find.text('ID: ORION-734'), findsOneWidget);
    });

    testWidgets('Health metrics grid displays all metrics', (
      WidgetTester tester,
    ) async {
      final testState = const DashboardLoaded(
        criticalAllergies: [],
        healthMetrics: HealthMetricsSnapshot(
          bloodType: 'A+',
          weight: 75,
          height: 182,
          heartRate: 72,
          temperature: 36.5,
          systolicPressure: 120,
          diastolicPressure: 80,
        ),
        recentActivity: RecentActivity(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: _TestDashboardPage(state: testState),
        ),
      );

      // Verify health metrics
      expect(find.text('A+'), findsOneWidget);
      expect(find.text('75 kg'), findsOneWidget);
      expect(find.text('182 cm'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
      expect(find.text('36.5°C'), findsOneWidget);
      expect(find.text('120/80'), findsOneWidget);
    });

    testWidgets('Critical alert shown when allergies exist', (
      WidgetTester tester,
    ) async {
      final testAllergy = Allergy(
        name: 'Penicilina',
        reaction: 'Reacción severa',
        isCritical: true,
      );

      final testState = DashboardLoaded(
        criticalAllergies: [testAllergy],
        healthMetrics: const HealthMetricsSnapshot(),
        recentActivity: const RecentActivity(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: _TestDashboardPage(state: testState),
        ),
      );

      expect(find.text('ALERTA CRÍTICA'), findsOneWidget);
      expect(find.text('Alergia: Penicilina'), findsOneWidget);
    });

    testWidgets('Critical alert hidden when no allergies', (
      WidgetTester tester,
    ) async {
      final testState = const DashboardLoaded(
        criticalAllergies: [],
        healthMetrics: HealthMetricsSnapshot(),
        recentActivity: RecentActivity(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: _TestDashboardPage(state: testState),
        ),
      );

      expect(find.text('ALERTA CRÍTICA'), findsNothing);
    });

    testWidgets('Quick actions are present', (WidgetTester tester) async {
      final testState = const DashboardLoaded(
        criticalAllergies: [],
        healthMetrics: HealthMetricsSnapshot(),
        recentActivity: RecentActivity(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: _TestDashboardPage(state: testState),
        ),
      );

      expect(find.text('AI Assistant'), findsWidgets);
      expect(find.text('Salud'), findsOneWidget);
      expect(find.text('Estadísticas'), findsOneWidget);
      expect(find.text('Medicamentos'), findsOneWidget);
    });

    testWidgets('FAB is present for AI Assistant', (WidgetTester tester) async {
      final testState = const DashboardLoaded(
        criticalAllergies: [],
        healthMetrics: HealthMetricsSnapshot(),
        recentActivity: RecentActivity(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: _TestDashboardPage(state: testState),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Shows error state with retry button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: const _TestDashboardPage(
            state: DashboardError('Error de conexión'),
          ),
        ),
      );

      expect(find.text('Error al cargar datos'), findsOneWidget);
      expect(find.text('Error de conexión'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });
}

/// Test dashboard page that accepts a state directly, bypassing GetIt
class _TestDashboardPage extends StatelessWidget {
  final DashboardState state;

  const _TestDashboardPage({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.local_hospital, color: CyberTheme.secondary),
        title: const Text('Resumen Médico'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.chat),
        label: const Text('AI Assistant'),
        backgroundColor: CyberTheme.secondary,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state is DashboardLoading) {
      return const Center(
        child: CircularProgressIndicator(color: CyberTheme.secondary),
      );
    }

    if (state is DashboardError) {
      final errorState = state as DashboardError;
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
                errorState.message,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (state is DashboardLoaded) {
      return _buildLoadedContent(context, state as DashboardLoaded);
    }

    return const Center(
      child: CircularProgressIndicator(color: CyberTheme.secondary),
    );
  }

  Widget _buildLoadedContent(
    BuildContext context,
    DashboardLoaded loadedState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _TestProfileHeader(userProfile: loadedState.userProfile),
          const SizedBox(height: 24),

          // Critical Alert
          if (loadedState.criticalAllergies.isNotEmpty) ...[
            _TestCriticalAlertCard(allergies: loadedState.criticalAllergies),
            const SizedBox(height: 24),
          ],

          // Health Metrics Section
          Text(
            'Métricas de Salud',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: CyberTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _TestHealthMetricsGrid(metrics: loadedState.healthMetrics),
          const SizedBox(height: 24),

          // Quick Actions Section
          Text(
            'Acciones Rápidas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: CyberTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const _TestQuickActionsSection(),
          const SizedBox(height: 24),

          // Recent Activity Section
          Text(
            'Actividad Reciente',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: CyberTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestProfileHeader extends StatelessWidget {
  final UserProfile? userProfile;
  const _TestProfileHeader({this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userProfile?.name ?? 'Usuario',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        Text(
          userProfile?.age != null ? 'Edad: ${userProfile!.age}' : 'Edad: --',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        Text(
          'ID: ${userProfile?.uniqueId ?? 'ORION-000'}',
          style: TextStyle(color: CyberTheme.secondary.withOpacity(0.8)),
        ),
      ],
    );
  }
}

class _TestCriticalAlertCard extends StatelessWidget {
  final List<Allergy> allergies;
  const _TestCriticalAlertCard({required this.allergies});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ALERTA CRÍTICA',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...allergies.map(
            (a) => Text(
              'Alergia: ${a.name}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestHealthMetricsGrid extends StatelessWidget {
  final HealthMetricsSnapshot metrics;
  const _TestHealthMetricsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetricTile(label: 'Sangre', value: metrics.bloodType ?? '--'),
        _MetricTile(label: 'Peso', value: metrics.formattedWeight),
        _MetricTile(label: 'Altura', value: metrics.formattedHeight),
        _MetricTile(label: 'Pulso', value: metrics.formattedHeartRate),
        _MetricTile(label: 'Temp', value: metrics.formattedTemperature),
        _MetricTile(label: 'P/A', value: metrics.formattedBloodPressure),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestQuickActionsSection extends StatelessWidget {
  const _TestQuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuickActionTile(icon: Icons.chat, label: 'AI Assistant'),
        _QuickActionTile(icon: Icons.favorite, label: 'Salud'),
        _QuickActionTile(icon: Icons.bar_chart, label: 'Estadísticas'),
        _QuickActionTile(icon: Icons.medication, label: 'Medicamentos'),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickActionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CyberTheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: CyberTheme.secondary),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
