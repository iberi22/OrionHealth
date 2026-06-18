import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/vote.dart';

void main() {
  group('Vote', () {
    test('creates Vote with all required fields', () {
      final vote = Vote(
        proposalId: 'prop-1',
        voter: 'user-123',
        decision: VoteDecision.forProposal,
        weight: 1.0,
      );

      expect(vote.proposalId, equals('prop-1'));
      expect(vote.voter, equals('user-123'));
      expect(vote.decision, equals(VoteDecision.forProposal));
      expect(vote.weight, equals(1.0));
    });

    test('Vote equality works correctly', () {
      final a = Vote(
        proposalId: 'prop-1',
        voter: 'user-123',
        decision: VoteDecision.forProposal,
        weight: 1.0,
      );
      final b = Vote(
        proposalId: 'prop-1',
        voter: 'user-123',
        decision: VoteDecision.forProposal,
        weight: 1.0,
      );
      final c = Vote(
        proposalId: 'prop-1',
        voter: 'user-456',
        decision: VoteDecision.forProposal,
        weight: 1.0,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('Vote with different decision is not equal', () {
      final a = Vote(
        proposalId: 'prop-1',
        voter: 'user-123',
        decision: VoteDecision.forProposal,
        weight: 1.0,
      );
      final b = Vote(
        proposalId: 'prop-1',
        voter: 'user-123',
        decision: VoteDecision.againstProposal,
        weight: 1.0,
      );

      expect(a, isNot(equals(b)));
    });

    test('Vote with different weight is not equal', () {
      final a = Vote(
        proposalId: 'prop-1',
        voter: 'user-123',
        decision: VoteDecision.forProposal,
        weight: 0.5,
      );
      final b = Vote(
        proposalId: 'prop-1',
        voter: 'user-123',
        decision: VoteDecision.forProposal,
        weight: 1.0,
      );

      expect(a, isNot(equals(b)));
    });

    test('VoteDecision enum has all expected values', () {
      expect(VoteDecision.values, hasLength(3));
      expect(VoteDecision.values, contains(VoteDecision.forProposal));
      expect(VoteDecision.values, contains(VoteDecision.againstProposal));
      expect(VoteDecision.values, contains(VoteDecision.abstain));
    });

    test('abstain vote records correctly', () {
      final vote = Vote(
        proposalId: 'prop-1',
        voter: 'user-789',
        decision: VoteDecision.abstain,
        weight: 0.0,
      );

      expect(vote.decision, equals(VoteDecision.abstain));
      expect(vote.weight, equals(0.0));
    });

    test('Vote toString includes relevant fields', () {
      final vote = Vote(
        proposalId: 'prop-1',
        voter: 'user-123',
        decision: VoteDecision.forProposal,
        weight: 1.0,
      );

      final str = vote.toString();
      expect(str, contains('prop-1'));
      expect(str, contains('user-123'));
      expect(str, contains('VoteDecision.forProposal'));
    });

    test('multiple votes with different voters for same proposal are distinct', () {
      final vote1 = Vote(
        proposalId: 'prop-1',
        voter: 'user-a',
        decision: VoteDecision.forProposal,
        weight: 1.0,
      );
      final vote2 = Vote(
        proposalId: 'prop-1',
        voter: 'user-b',
        decision: VoteDecision.againstProposal,
        weight: 2.0,
      );
      final vote3 = Vote(
        proposalId: 'prop-1',
        voter: 'user-c',
        decision: VoteDecision.abstain,
        weight: 0.5,
      );

      expect(vote1, isNot(equals(vote2)));
      expect(vote1, isNot(equals(vote3)));
      expect(vote2, isNot(equals(vote3)));
    });
  });
}
