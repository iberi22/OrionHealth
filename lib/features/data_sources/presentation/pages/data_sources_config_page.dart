import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/data_source_cubit.dart';
import '../../application/data_source_state.dart';
import '../widgets/data_source_tile.dart';

class DataSourcesConfigPage extends StatelessWidget {
  const DataSourcesConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DataSourceCubit>()..loadDataSources(),
      child: const _DataSourcesConfigView(),
    );
  }
}

class _DataSourcesConfigView extends StatelessWidget {
  const _DataSourcesConfigView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Sources Configuration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<DataSourceCubit, DataSourceState>(
        builder: (context, state) {
          if (state is DataSourceLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is DataSourceError) {
            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
          } else if (state is DataSourceLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.dataSources.length,
              itemBuilder: (context, index) {
                final source = state.dataSources[index];
                return DataSourceTile(
                  source: source,
                  onToggle: () => context.read<DataSourceCubit>().toggleConnection(source.id),
                  onSync: () => context.read<DataSourceCubit>().syncSource(source.id),
                );
              },
            );
          }
          return const Center(child: Text('Initial state', style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }
}
