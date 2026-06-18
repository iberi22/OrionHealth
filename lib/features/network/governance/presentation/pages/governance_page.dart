import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/governance_cubit.dart';
import '../widgets/proposal_card.dart';
import 'create_proposal_page.dart';
import 'proposal_detail_page.dart';

class GovernancePage extends StatefulWidget {
  const GovernancePage({super.key});

  @override
  State<GovernancePage> createState() => _GovernancePageState();
}

class _GovernancePageState extends State<GovernancePage> {
  @override
  void initState() {
    super.initState();
    context.read<GovernanceCubit>().loadProposals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Governance'),
      ),
      body: BlocBuilder<GovernanceCubit, GovernanceState>(
        builder: (context, state) {
          if (state.status == GovernanceStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == GovernanceStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          if (state.proposals.isEmpty) {
            return const Center(child: Text('No proposals found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.proposals.length,
            itemBuilder: (context, index) {
              final proposal = state.proposals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProposalCard(
                  proposal: proposal,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<GovernanceCubit>(),
                          child: ProposalDetailPage(proposal: proposal),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<GovernanceCubit>(),
                child: const CreateProposalPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
