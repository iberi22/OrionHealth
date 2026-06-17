import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/vote.dart';
import 'package:orionhealth_health/features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart';
import 'package:orionhealth_health/features/sync/infrastructure/datasources/ipfs_datasource.dart';

class MockIpfsDatasource extends Mock implements IpfsDatasource {}

void main() {
  late GovernanceIpfsDatasource datasource;
  late MockIpfsDatasource mockIpfs;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(Proposal(
      id: 'fake',
      title: '',
      description: '',
      voteCount: 0,
      deadline: DateTime.now(),
      status: ProposalStatus.active,
    ));
    registerFallbackValue(const Vote(
      proposalId: 'fake',
      voter: '',
      decision: VoteDecision.abstain,
      weight: 0,
    ));
  });

  setUp(() {
    mockIpfs = MockIpfsDatasource();
    datasource = GovernanceIpfsDatasource(mockIpfs);
  });

  group('GovernanceIpfsDatasource', () {
    final proposal = Proposal(
      id: '1',
      title: 'Test',
      description: 'Desc',
      voteCount: 0,
      deadline: DateTime(2026, 1, 1),
      status: ProposalStatus.active,
    );

    final vote = const Vote(
      proposalId: '1',
      voter: 'voter1',
      decision: VoteDecision.forProposal,
      weight: 1.0,
    );

    test('uploadProposal adds data to IPFS and returns CID', () async {
      when(() => mockIpfs.add(any())).thenAnswer((_) async => 'Qm123');

      final result = await datasource.uploadProposal(proposal);

      expect(result, 'Qm123');
      verify(() => mockIpfs.add(any())).called(1);
    });

    test('fetchProposal gets data from IPFS and parses it', () async {
      const jsonStr = '{"id":"1","title":"Test","description":"Desc","voteCount":0,"deadline":"2026-01-01T00:00:00.000","status":"active"}';
      final data = Uint8List.fromList(jsonStr.codeUnits);
      when(() => mockIpfs.get('Qm123')).thenAnswer((_) async => data);

      final result = await datasource.fetchProposal('Qm123');

      expect(result.id, '1');
      expect(result.title, 'Test');
      expect(result.status, ProposalStatus.active);
    });

    test('uploadVote adds data to IPFS and returns CID', () async {
      when(() => mockIpfs.add(any())).thenAnswer((_) async => 'QmVote');

      final result = await datasource.uploadVote(vote);

      expect(result, 'QmVote');
      verify(() => mockIpfs.add(any())).called(1);
    });

    test('fetchVote gets data from IPFS and parses it', () async {
      const jsonStr = '{"proposalId":"1","voter":"voter1","decision":"forProposal","weight":1.0}';
      final data = Uint8List.fromList(jsonStr.codeUnits);
      when(() => mockIpfs.get('QmVote')).thenAnswer((_) async => data);

      final result = await datasource.fetchVote('QmVote');

      expect(result.proposalId, '1');
      expect(result.voter, 'voter1');
      expect(result.decision, VoteDecision.forProposal);
    });
  });
}
