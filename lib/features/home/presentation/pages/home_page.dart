// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
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
                          // Handle navigation
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
