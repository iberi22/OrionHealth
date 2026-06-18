import 'package:flutter/material.dart';
import '../../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/proposal.dart';

class GovernanceDashboard extends StatelessWidget {
  final List<Proposal> proposals;

  const GovernanceDashboard({super.key, required this.proposals});

  @override
  Widget build(BuildContext context) {
    final activeCount = proposals.where((p) => p.status == ProposalStatus.active).length;
    final passedCount = proposals.where((p) => p.status == ProposalStatus.passed).length;
    final totalVotes = proposals.fold<int>(0, (sum, p) => sum + p.voteCount);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Active', activeCount.toString(), Colors.blue),
        _buildStatCard('Passed', passedCount.toString(), Colors.green),
        _buildStatCard('Total Proposals', proposals.length.toString(), Colors.purple),
        _buildStatCard('Total Votes', totalVotes.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return GlassmorphicCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
