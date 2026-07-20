import 'package:flutter/material.dart';
import '../../domain/entities/data_source_entity.dart';
import '../../../../core/theme/app_colors.dart';

class DataSourceTile extends StatelessWidget {
  final DataSource source;
  final VoidCallback onToggle;
  final VoidCallback? onSync;

  const DataSourceTile({
    super.key,
    required this.source,
    required this.onToggle,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(source.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(source.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            if (source.lastSync != null)
              Text('Last sync: ${source.lastSync!.toLocal()}', style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (source.status == DataSourceStatus.connected && onSync != null)
              IconButton(
                icon: const Icon(Icons.sync, color: AppColors.secondary),
                onPressed: onSync,
                tooltip: 'Sincronizar',
              ),
            _buildStatusIcon(),
            Switch(
              value: source.status == DataSourceStatus.connected,
              onChanged: (_) => onToggle(),
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (source.status) {
      case DataSourceStatus.connecting:
        return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
      case DataSourceStatus.error:
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const SizedBox.shrink();
    }
  }
}
