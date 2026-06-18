import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/widgets/page_header.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/entities/vote.dart';
import '../../application/governance_cubit.dart';
import '../widgets/governance_dashboard.dart';
import '../widgets/proposal_list_widget.dart';
import '../widgets/vote_widget.dart';

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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocConsumer<GovernanceCubit, GovernanceState>(
          listener: (context, state) {
            if (state.status == GovernanceStatus.error && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<GovernanceCubit>().loadProposals(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(
                      title: 'Governance',
                      subtitle: 'Vote on network proposals',
                    ),
                    const SizedBox(height: 24),
                    if (state.status == GovernanceStatus.loading && state.proposals.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      GovernanceDashboard(proposals: state.proposals),
                      const SizedBox(height: 32),
                      const Text(
                        'Recent Proposals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProposalListWidget(
                        proposals: state.proposals,
                        onProposalTap: (proposal) => _showProposalDetails(context, proposal),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProposalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProposalDetails(BuildContext context, Proposal proposal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proposal.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    proposal.description,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  VoteWidget(
                    proposal: proposal,
                    onVote: (decision) {
                      context.read<GovernanceCubit>().vote(
                            proposal.id,
                            'current-user', // In a real app, this would come from auth
                            decision,
                            1.0,
                          );
                      Navigator.pop(modalContext);
                    },
                  ),
                  if (proposal.status == ProposalStatus.active &&
                      DateTime.now().isAfter(proposal.deadline))
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<GovernanceCubit>().tally(proposal.id);
                          Navigator.pop(modalContext);
                        },
                        child: const Text('TALLY VOTES'),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateProposalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Create Proposal', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                  context.read<GovernanceCubit>().createProposal(
                        titleController.text,
                        descController.text,
                        const Duration(days: 7),
                      );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('CREATE'),
            ),
          ],
        );
      },
    );
  }
}
