// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/core/widgets/page_header.dart';
import '../../application/incentive_cubit.dart';
import '../widgets/contribution_card.dart';
import 'rewards_page.dart';
import 'leaderboard_page.dart';

class IncentivesPage extends StatelessWidget {
  final String userId;

  const IncentivesPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<IncentiveCubit>()..loadIncentiveData(userId),
      child: const IncentivesView(),
    );
  }
}

class IncentivesView extends StatelessWidget {
  const IncentivesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'INCENTIVOS',
              subtitle: 'Contribuye a la red y gana recompensas',
              trailing: IconButton(
                icon: const Icon(Icons.leaderboard, color: CyberTheme.primary),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<IncentiveCubit, IncentiveState>(
                builder: (context, state) {
                  if (state.status == IncentiveStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == IncentiveStatus.error) {
                    return Center(child: Text('Error: ${state.errorMessage}'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<IncentiveCubit>().loadIncentiveData('user1'), // TODO: real userId
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildPointsSummary(state.totalPoints, context),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'CONTRIBUCIONES RECIENTES',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Show all contributions
                              },
                              child: const Text('VER TODO', style: TextStyle(color: CyberTheme.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (state.contributions.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Text('No hay contribuciones recientes', style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        else
                          ...state.contributions.take(5).map((c) => ContributionCard(contribution: c)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<IncentiveCubit>(),
                child: const RewardsPage(),
              ),
            ),
          );
        },
        label: const Text('RECOMPENSAS', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.card_giftcard),
        backgroundColor: CyberTheme.primary,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildPointsSummary(int totalPoints, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CyberTheme.primary.withAlpha(50), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CyberTheme.primary.withAlpha(100)),
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL DE PUNTOS',
            style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            totalPoints.toString(),
            style: const TextStyle(
              color: CyberTheme.primary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: CyberTheme.primary, blurRadius: 10),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (totalPoints % 1000) / 1000,
            backgroundColor: Colors.white.withAlpha(20),
            valueColor: const AlwaysStoppedAnimation(CyberTheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            '${1000 - (totalPoints % 1000)} puntos para el siguiente nivel',
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
