import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';

void main() {
  final baseDateTime = DateTime(2026, 7, 1);

  group('Proposal', () {
    test('creates Proposal with all required fields', () {
      final proposal = Proposal(
        id: 'prop-1',
        title: 'Upgrade Storage Nodes',
        description: 'Increase storage allocation for patient data',
        voteCount: 0,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );

      expect(proposal.id, equals('prop-1'));
      expect(proposal.title, equals('Upgrade Storage Nodes'));
      expect(proposal.description, equals('Increase storage allocation for patient data'));
      expect(proposal.voteCount, equals(0));
      expect(proposal.deadline, equals(baseDateTime));
      expect(proposal.status, equals(ProposalStatus.active));
    });

    test('Proposal equality works correctly', () {
      final a = Proposal(
        id: 'prop-1',
        title: 'Test',
        description: 'Desc',
        voteCount: 5,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );
      final b = Proposal(
        id: 'prop-1',
        title: 'Test',
        description: 'Desc',
        voteCount: 5,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );
      final c = Proposal(
        id: 'prop-2',
        title: 'Test',
        description: 'Desc',
        voteCount: 5,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('Proposal copyWith preserves unchanged fields', () {
      final proposal = Proposal(
        id: 'prop-1',
        title: 'Original Title',
        description: 'Original desc',
        voteCount: 10,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );

      final updated = proposal.copyWith(title: 'Updated Title');

      expect(updated.id, equals('prop-1'));
      expect(updated.title, equals('Updated Title'));
      expect(updated.description, equals('Original desc'));
      expect(updated.voteCount, equals(10));
    });

    test('Proposal copyWith changes all fields', () {
      final proposal = Proposal(
        id: 'prop-1',
        title: 'Original',
        description: 'Desc',
        voteCount: 0,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );

      final newDeadline = DateTime(2026, 8, 1);
      final updated = proposal.copyWith(
        id: 'prop-2',
        title: 'New Title',
        description: 'New desc',
        voteCount: 100,
        deadline: newDeadline,
        status: ProposalStatus.passed,
      );

      expect(updated.id, equals('prop-2'));
      expect(updated.title, equals('New Title'));
      expect(updated.description, equals('New desc'));
      expect(updated.voteCount, equals(100));
      expect(updated.deadline, equals(newDeadline));
      expect(updated.status, equals(ProposalStatus.passed));
    });

    test('ProposalStatus enum has all expected values', () {
      expect(ProposalStatus.values, hasLength(4));
      expect(ProposalStatus.values, contains(ProposalStatus.active));
      expect(ProposalStatus.values, contains(ProposalStatus.passed));
      expect(ProposalStatus.values, contains(ProposalStatus.rejected));
      expect(ProposalStatus.values, contains(ProposalStatus.expired));
    });

    test('Proposal with different voteCount is not equal', () {
      final a = Proposal(
        id: 'prop-1',
        title: 'Same',
        description: 'Same',
        voteCount: 0,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );
      final b = Proposal(
        id: 'prop-1',
        title: 'Same',
        description: 'Same',
        voteCount: 1,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );

      expect(a, isNot(equals(b)));
    });

    test('Proposal with different status is not equal', () {
      final a = Proposal(
        id: 'prop-1',
        title: 'Same',
        description: 'Same',
        voteCount: 0,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );
      final b = Proposal(
        id: 'prop-1',
        title: 'Same',
        description: 'Same',
        voteCount: 0,
        deadline: baseDateTime,
        status: ProposalStatus.expired,
      );

      expect(a, isNot(equals(b)));
    });

    test('Proposal toString includes relevant fields', () {
      final proposal = Proposal(
        id: 'prop-1',
        title: 'Test Proposal',
        description: 'Testing',
        voteCount: 0,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );

      final str = proposal.toString();
      expect(str, contains('prop-1'));
      expect(str, contains('Test Proposal'));
      expect(str, contains('ProposalStatus.active'));
    });
  });
}
