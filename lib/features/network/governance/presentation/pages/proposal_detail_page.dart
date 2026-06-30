import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/governance_cubit.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/entities/vote.dart';

class ProposalDetailPage extends StatelessWidget {
  final Proposal proposal;

  const ProposalDetailPage({super.key, required this.proposal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              proposal.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatusChip(status: proposal.status),
                const SizedBox(width: 8),
                Text('Deadline: ${proposal.deadline.toString().split(' ')[0]}'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(proposal.description),
            const SizedBox(height: 24),
            const Text(
              'Statistics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Current Vote Count: ${proposal.voteCount}'),
            const SizedBox(height: 32),
            if (proposal.status == ProposalStatus.active) ...[
              const Text(
                'Cast Your Vote',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _castVote(context, VoteDecision.forProposal),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('For'),
                  ),
                  ElevatedButton(
                    onPressed: () => _castVote(context, VoteDecision.againstProposal),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Against'),
                  ),
                  ElevatedButton(
                    onPressed: () => _castVote(context, VoteDecision.abstain),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                    child: const Text('Abstain'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _castVote(BuildContext context, VoteDecision decision) {
    // In a real app, 'voter' would be the current user's ID/Address
    context.read<GovernanceCubit>().vote(
          proposal.id,
          'current_user',
          decision,
          1.0, // weight
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vote cast: ${decision.name}')),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ProposalStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.name.toUpperCase()),
      backgroundColor: _getStatusColor(status).withValues(alpha: 0.2),
      labelStyle: TextStyle(color: _getStatusColor(status)),
    );
  }

  Color _getStatusColor(ProposalStatus status) {
    switch (status) {
      case ProposalStatus.active:
        return Colors.blue;
      case ProposalStatus.passed:
        return Colors.green;
      case ProposalStatus.rejected:
        return Colors.red;
      case ProposalStatus.expired:
        return Colors.grey;
    }
  }
}
