import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart';
import '../../domain/repositories/network_repository.dart';
import '../../application/network_health_cubit.dart';
import '../widgets/network_status_card.dart';
import '../widgets/node_list_item.dart';

class NetworkHealthPage extends StatelessWidget {
  const NetworkHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NetworkHealthCubit>()..loadNetworkHealth(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Network Health'),
        ),
        body: BlocBuilder<NetworkHealthCubit, NetworkHealthState>(
          builder: (context, state) {
            if (state.status == NetworkHealthStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == NetworkHealthStatus.error) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }

            return RefreshIndicator(
              onRefresh: () => context.read<NetworkHealthCubit>().loadNetworkHealth(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.networkHealth != null)
                    NetworkStatusCard(health: state.networkHealth!),
                  const SizedBox(height: 24),
                  const Text(
                    'Network Nodes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...state.nodes.map((node) => NodeListItem(
                        node: node,
                        onConnect: () =>
                            context.read<NetworkHealthCubit>().connectToNode(node.id),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
