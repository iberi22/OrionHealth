import 'package:flutter/material.dart';
import '../../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/proposal.dart';

class ProposalListWidget extends StatelessWidget {
  final List<Proposal> proposals;
  final Function(Proposal) onProposalTap;

  const ProposalListWidget({
    super.key,
    required this.proposals,
    required this.onProposalTap,
  });

  @override
  Widget build(BuildContext context) {
    if (proposals.isEmpty) {
      return const Center(
        child: Text(
          'No proposals found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: proposals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final proposal = proposals[index];
        return GlassmorphicCard(
          onTap: () => onProposalTap(proposal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      proposal.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(proposal.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                proposal.description,
                style: const TextStyle(color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Votes: ${proposal.voteCount}',
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Deadline: ${proposal.deadline.day}/${proposal.deadline.month}/${proposal.deadline.year}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(ProposalStatus status) {
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
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
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
