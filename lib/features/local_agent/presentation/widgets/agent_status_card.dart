import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/agent_status.dart';

class AgentStatusCard extends StatefulWidget {
  final String agentName;
  final AgentStatus status;

  const AgentStatusCard({
    super.key,
    required this.agentName,
    required this.status,
  });

  @override
  State<AgentStatusCard> createState() => _AgentStatusCardState();
}

class _AgentStatusCardState extends State<AgentStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.status != AgentStatus.offline) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AgentStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      if (widget.status == AgentStatus.offline) {
        _controller.stop();
      } else if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.status);
    final statusLabel = _getStatusLabel(widget.status);

    return GlassmorphicCard(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (widget.status != AgentStatus.offline)
                ScaleTransition(
                  key: const Key('agent_status_pulse'),
                  scale: _animation,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.agentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            _getStatusIcon(widget.status),
            color: Colors.white70,
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AgentStatus status) {
    switch (status) {
      case AgentStatus.online:
        return AppColors.primary;
      case AgentStatus.offline:
        return Colors.grey;
      case AgentStatus.busy:
        return Colors.orangeAccent;
    }
  }

  String _getStatusLabel(AgentStatus status) {
    switch (status) {
      case AgentStatus.online:
        return 'En línea';
      case AgentStatus.offline:
        return 'Desconectado';
      case AgentStatus.busy:
        return 'En uso';
    }
  }

  IconData _getStatusIcon(AgentStatus status) {
    switch (status) {
      case AgentStatus.online:
        return Icons.check_circle_outline;
      case AgentStatus.offline:
        return Icons.cloud_off;
      case AgentStatus.busy:
        return Icons.hourglass_empty;
    }
  }
}
