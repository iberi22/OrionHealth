import 'package:flutter/material.dart';
import '../../domain/entities/network_node.dart';

class NodeListItem extends StatelessWidget {
  final NetworkNode node;
  final VoidCallback? onConnect;

  const NodeListItem({
    super.key,
    required this.node,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(node.status),
          radius: 8,
        ),
        title: Text(node.name),
        subtitle: Text(node.address),
        trailing: node.status == NodeStatus.offline
            ? ElevatedButton(
                onPressed: onConnect,
                child: const Text('Connect'),
              )
            : Text(
                _getStatusText(node.status),
                style: TextStyle(color: _getStatusColor(node.status)),
              ),
      ),
    );
  }

  Color _getStatusColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.online:
        return Colors.green;
      case NodeStatus.offline:
        return Colors.red;
      case NodeStatus.syncing:
        return Colors.blue;
      case NodeStatus.error:
        return Colors.orange;
    }
  }

  String _getStatusText(NodeStatus status) {
    return status.name.toUpperCase();
  }
}
