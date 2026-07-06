import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/network_cubit.dart';
import '../../application/network_state.dart';
import '../widgets/peer_list_item.dart';

class NetworkOverviewPage extends StatefulWidget {
  const NetworkOverviewPage({super.key});

  @override
  State<NetworkOverviewPage> createState() => _NetworkOverviewPageState();
}

class _NetworkOverviewPageState extends State<NetworkOverviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<NetworkCubit>().loadNetworkData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Red de Pares'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<NetworkCubit>().discoverPeers(),
          ),
        ],
      ),
      body: BlocBuilder<NetworkCubit, NetworkState>(
        builder: (context, state) {
          if (state is NetworkInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NetworkLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NetworkLoaded) {
            if (state.peers.isEmpty) {
              return const Center(
                child: Text('No se encontraron pares en la red.'),
              );
            }
            return ListView.builder(
              itemCount: state.peers.length,
              itemBuilder: (context, index) {
                final peer = state.peers[index];
                return PeerListItem(peer: peer);
              },
            );
          }
          if (state is NetworkError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
