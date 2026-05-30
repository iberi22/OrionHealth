import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/medical_assistant_cubit.dart';
import '../../domain/entities/medical_insight.dart';
import '../../domain/entities/ai_response.dart';
import '../widgets/query_input.dart';
import '../widgets/insight_card.dart';
import '../widgets/lab_result_card.dart';
import '../../../onboarding/application/sync_cubit.dart';
import '../../../../core/di/injection.dart';

/// Main page for the AI Medical Assistant
class MedicalAssistantPage extends StatelessWidget {
  const MedicalAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MedicalAssistantCubit()),
        BlocProvider(create: (_) => getIt<SyncCubit>()),
      ],
      child: const _MedicalAssistantView(),
    );
  }
}

class _MedicalAssistantView extends StatefulWidget {
  const _MedicalAssistantView();

  @override
  State<_MedicalAssistantView> createState() => _MedicalAssistantViewState();
}

class _MedicalAssistantViewState extends State<_MedicalAssistantView> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente Médico Orion'),
        centerTitle: true,
        actions: [
          BlocConsumer<SyncCubit, SyncState>(
            listener: (context, state) {
              if (state is SyncSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sincronización exitosa')),
                );
              } else if (state is SyncFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.error}')),
                );
              }
            },
            builder: (context, state) {
              if (state is SyncInProgress) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.sync),
                onPressed: () => context.read<SyncCubit>().syncMedicalStandards(),
                tooltip: 'Sincronizar estándares',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MedicalAssistantCubit>().reset(),
            tooltip: 'Nueva consulta',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<MedicalAssistantCubit, MedicalAssistantState>(
                builder: (context, state) {
                  if (state is MedicalAssistantIdle) {
                    return const _IdleContent();
                  } else if (state is MedicalAssistantLoading) {
                    return _LoadingContent(message: state.message);
                  } else if (state is MedicalAssistantResponse) {
                    return _ResponseContent(
                      response: state.response,
                      query: state.query,
                    );
                  } else if (state is MedicalAssistantNeedsMoreInfo) {
                    return _NeedsMoreInfoContent(
                      state: state,
                      controller: _queryController,
                    );
                  } else if (state is MedicalAssistantError) {
                    return _ErrorContent(message: state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            BlocBuilder<MedicalAssistantCubit, MedicalAssistantState>(
              builder: (context, state) {
                final isLoading = state is MedicalAssistantLoading;
                return QueryInput(
                  controller: _queryController,
                  enabled: !isLoading,
                  onSubmit: (question) {
                    context.read<MedicalAssistantCubit>().submitQuery(question);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleContent extends StatelessWidget {
  const _IdleContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.medical_services_outlined,
            size: 64,
            color: Colors.teal,
          ),
          const SizedBox(height: 16),
          Text(
            '¿Cómo puedo ayudarte con tu salud hoy?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Puedo analizar tus resultados de laboratorio, signos vitales y proporcionarte '
            'información de salud basada en guías clínicas.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Prueba preguntando sobre:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickQueryChip('Niveles de glucosa'),
              _QuickQueryChip('Presión arterial'),
              _QuickQueryChip('Análisis de colesterol'),
              _QuickQueryChip('Interacciones de medicamentos'),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickQueryChip extends StatelessWidget {
  final String label;
  const _QuickQueryChip(this.label);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        // Find the controller from the view state if needed, or pass it down
        // For simplicity in _IdleContent, we'll keep direct submit or update if required
        context.read<MedicalAssistantCubit>().submitQuery(label);
      },
    );
  }
}

class _LoadingContent extends StatelessWidget {
  final String? message;
  const _LoadingContent({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.teal),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _ResponseContent extends StatelessWidget {
  final AiMedicalResponse response;
  final dynamic query;

  const _ResponseContent({
    required this.response,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final labInsights = response.insights
        .where((i) => i.category == InsightCategory.labInterpretation)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Answer
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy, color: Colors.teal),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Analysis',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (response.confidence != null)
                        Text(
                          '${(response.confidence! * 100).toInt()}% de confianza',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const Divider(),
                  SelectableText(
                    response.answer,
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Citations section
          if (response.metadata != null && response.metadata!.containsKey('citations')) ...[
            const Text(
              'Referencias y Estándares',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (response.metadata!['citations'] as List<dynamic>).map((citation) {
                return Chip(
                  avatar: const Icon(Icons.bookmark_outline, size: 16, color: Colors.teal),
                  label: Text(
                    citation.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.teal.withValues(alpha: 0.05),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Insights section
          if (response.insights.isNotEmpty) ...[
            const Text(
              'Hallazgos Médicos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            ...response.insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InsightCard(insight: insight),
            )),
          ],

          // Lab results cards if applicable
          if (labInsights.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Resultados de Laboratorio',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: labInsights.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: LabResultCard(insight: labInsights[index]),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NeedsMoreInfoContent extends StatelessWidget {
  final MedicalAssistantNeedsMoreInfo state;
  final TextEditingController controller;

  const _NeedsMoreInfoContent({
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Robot icon + message
          const Icon(Icons.help_outline, size: 48, color: Colors.amber),
          const SizedBox(height: 16),
          Text(state.message, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          // Questions as chips
          const Text('Para ayudarte mejor, cuéntame:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.questions
                .map((q) => ActionChip(
                      label: Text(q),
                      onPressed: () {
                        controller.text = q;
                      },
                    ))
                .toList(),
          ),

          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Submit the last question but with force=true
                final lastQuery = state.partialAnswer != null
                    ? 'Continuar con el análisis disponible'
                    : 'Continuar sin más datos';
                context
                    .read<MedicalAssistantCubit>()
                    .submitQuery(lastQuery, force: true);
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continuar sin más datos'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
            ),
          ),

          // Optional partial answer
          if (state.partialAnswer != null) ...[
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text('Ver análisis parcial disponible'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(state.partialAnswer!),
                )
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  const _ErrorContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<MedicalAssistantCubit>().reset(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
