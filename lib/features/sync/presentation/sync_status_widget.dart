import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/di/injection.dart';
import '../domain/sync_cubit.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FhirSyncCubit>(),
      child: const _SyncStatusView(),
    );
  }
}

class _SyncStatusView extends StatelessWidget {
  const _SyncStatusView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FhirSyncCubit, SyncState>(
      listener: (context, state) {
        if (state.status == SyncStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sincronización exitosa')),
          );
        } else if (state.status == SyncStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.errorMessage}')),
          );
        }
      },
      builder: (context, state) {
        final lastSyncStr = state.lastSyncTime != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(state.lastSyncTime!)
            : 'Nunca';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sincronización IHCE',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (state.status == SyncStatus.loading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: () => context.read<FhirSyncCubit>().performSync(),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Última sincronización: $lastSyncStr'),
              ],
            ),
          ),
        );
      },
    );
  }
}
