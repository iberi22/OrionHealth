import 'package:flutter/material.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/entities/vote.dart';

class VoteWidget extends StatefulWidget {
  final Proposal proposal;
  final Function(VoteDecision) onVote;

  const VoteWidget({
    super.key,
    required this.proposal,
    required this.onVote,
  });

  @override
  State<VoteWidget> createState() => _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  VoteDecision? _selectedDecision;

  @override
  Widget build(BuildContext context) {
    if (widget.proposal.status != ProposalStatus.active) {
      return const Center(
        child: Text(
          'Voting is closed for this proposal',
          style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Cast your vote',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildVoteButton(
                'FOR',
                VoteDecision.forProposal,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVoteButton(
                'AGAINST',
                VoteDecision.againstProposal,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildVoteButton(
          'ABSTAIN',
          VoteDecision.abstain,
          Colors.grey,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selectedDecision == null
              ? null
              : () => widget.onVote(_selectedDecision!),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.white10,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('SUBMIT VOTE'),
        ),
      ],
    );
  }

  Widget _buildVoteButton(String label, VoteDecision decision, Color color) {
    final isSelected = _selectedDecision == decision;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDecision = decision;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(80) : Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
