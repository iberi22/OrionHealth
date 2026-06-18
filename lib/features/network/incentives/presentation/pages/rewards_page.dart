// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/widgets/page_header.dart';
import '../../application/incentive_cubit.dart';
import '../widgets/reward_tile.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'RECOMPENSAS',
              subtitle: 'Canjea tus puntos por beneficios',
              showBackButton: true,
              onBackPress: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: BlocBuilder<IncentiveCubit, IncentiveState>(
                builder: (context, state) {
                  if (state.rewards.isEmpty) {
                    return const Center(
                      child: Text('No hay recompensas disponibles', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.rewards.length,
                    itemBuilder: (context, index) {
                      final reward = state.rewards[index];
                      return RewardTile(
                        reward: reward,
                        onClaim: reward.isClaimed
                            ? null
                            : () => context.read<IncentiveCubit>().claimReward(reward.userId, reward.id),
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
}
