import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';

void main() {
  group('Proposal', () {
    final deadline = DateTime(2026, 12, 31);
    final proposal = Proposal(
      id: '1',
      title: 'Title',
      description: 'Description',
      voteCount: 10,
      deadline: deadline,
      status: ProposalStatus.active,
    );

    test('should support value equality', () {
      expect(
        proposal,
        Proposal(
          id: '1',
          title: 'Title',
          description: 'Description',
          voteCount: 10,
          deadline: deadline,
          status: ProposalStatus.active,
        ),
      );
    });

    test('copyWith should return a new object with updated fields', () {
      final updated = proposal.copyWith(
        title: 'New Title',
        voteCount: 11,
        status: ProposalStatus.passed,
      );

      expect(updated.id, '1');
      expect(updated.title, 'New Title');
      expect(updated.description, 'Description');
      expect(updated.voteCount, 11);
      expect(updated.deadline, deadline);
      expect(updated.status, ProposalStatus.passed);
    });

    test('copyWith should return the same object if no fields are provided', () {
      final updated = proposal.copyWith();
      expect(updated, proposal);
    });
  });
}
