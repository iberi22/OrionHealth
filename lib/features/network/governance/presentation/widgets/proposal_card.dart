import 'package:flutter/material.dart';
import '../../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/proposal.dart';

class ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final VoidCallback? onTap;

  const ProposalCard({
    super.key,
    required this.proposal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    proposal.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: proposal.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              proposal.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Votes: ${proposal.voteCount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Deadline: ${_formatDate(proposal.deadline)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final ProposalStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ProposalStatus.active:
        color = Colors.blue;
        break;
      case ProposalStatus.passed:
        color = Colors.green;
        break;
      case ProposalStatus.rejected:
        color = Colors.red;
        break;
      case ProposalStatus.expired:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
