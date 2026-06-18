// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/core/widgets/page_header.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import '../../application/incentive_cubit.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<IncentiveCubit>()..leaderboard(),
      child: const LeaderboardView(),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'LEADERBOARD',
              subtitle: 'Los contribuyentes más activos',
              showBackButton: true,
              onBackPress: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: BlocBuilder<IncentiveCubit, IncentiveState>(
                builder: (context, state) {
                  if (state.status == IncentiveStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final leaderboardList = state.leaderboard.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  if (leaderboardList.isEmpty) {
                    return const Center(
                      child: Text('Aún no hay datos en el leaderboard', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: leaderboardList.length,
                    itemBuilder: (context, index) {
                      final entry = leaderboardList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassmorphicCard(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _getRankColor(index).withAlpha(40),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _getRankColor(index)),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: _getRankColor(index),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value} pts',
                                style: const TextStyle(
                                  color: CyberTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white.withAlpha(100);
    }
  }
}
