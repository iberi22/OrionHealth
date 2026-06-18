import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/vote.dart';

void main() {
  group('Vote', () {
    const vote = Vote(
      proposalId: '1',
      voter: 'voter1',
      decision: VoteDecision.forProposal,
      weight: 1.0,
    );

    test('should support value equality', () {
      expect(
        vote,
        const Vote(
          proposalId: '1',
          voter: 'voter1',
          decision: VoteDecision.forProposal,
          weight: 1.0,
        ),
      );
    });
  });
}
