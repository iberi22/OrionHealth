import 'package:flutter/material.dart';
import '../../domain/entities/network_peer.dart';

class PeerListItem extends StatelessWidget {
  final NetworkPeer peer;
  final VoidCallback? onTap;

  const PeerListItem({
    super.key,
    required this.peer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: peer.status == PeerStatus.online ? Colors.green : Colors.grey,
        child: const Icon(Icons.person, color: Colors.white),
      ),
      title: Text(peer.name),
      subtitle: Text('${peer.address}:${peer.port}'),
      trailing: Text(peer.status.name),
      onTap: onTap,
    );
  }
}
