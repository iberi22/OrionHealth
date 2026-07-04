import 'package:flutter/material.dart';
import '../../domain/entities/network_node.dart';

class NodeListItem extends StatelessWidget {
  final NetworkNode node;
  final VoidCallback? onConnect;

  const NodeListItem({super.key, required this.node, this.onConnect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(node.status),
        child: const Icon(Icons.router, color: Colors.white),
      ),
      title: Text(node.name),
      subtitle: Text(node.address),
      trailing: node.status == NodeStatus.offline
          ? IconButton(
              icon: const Icon(Icons.link),
              onPressed: onConnect,
            )
          : Text(
              _getStatusLabel(node.status),
              style: TextStyle(color: _getStatusColor(node.status)),
            ),
    );
  }

  Color _getStatusColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.online:
        return Colors.green;
      case NodeStatus.offline:
        return Colors.grey;
      case NodeStatus.syncing:
        return Colors.blue;
      case NodeStatus.error:
        return Colors.red;
    }
  }

  String _getStatusLabel(NodeStatus status) {
    switch (status) {
      case NodeStatus.online:
        return 'Online';
      case NodeStatus.offline:
        return 'Offline';
      case NodeStatus.syncing:
        return 'Syncing';
      case NodeStatus.error:
        return 'Error';
    }
  }
}
