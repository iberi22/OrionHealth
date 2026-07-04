import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/network_health_cubit.dart';
import '../../application/network_health_state.dart';
import '../widgets/network_stats_card.dart';
import '../widgets/node_list_item.dart';

class NetworkHealthPage extends StatefulWidget {
  const NetworkHealthPage({super.key});

  @override
  State<NetworkHealthPage> createState() => _NetworkHealthPageState();
}

class _NetworkHealthPageState extends State<NetworkHealthPage> {
  @override
  void initState() {
    super.initState();
    context.read<NetworkHealthCubit>().loadNetworkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Health'),
      ),
      body: BlocBuilder<NetworkHealthCubit, NetworkHealthState>(
        builder: (context, state) {
          if (state.status == NetworkHealthStatus.loading && state.health == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NetworkHealthStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<NetworkHealthCubit>().loadNetworkStatus(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<NetworkHealthCubit>().loadNetworkStatus(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.health != null) ...[
                  NetworkStatsCard(health: state.health!),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Network Nodes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (state.nodes.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('No nodes discovered yet.'),
                  ))
                else
                  ...state.nodes.map((node) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: NodeListItem(
                          node: node,
                          onConnect: () => context
                              .read<NetworkHealthCubit>()
                              .connectToNode(node.id),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}
