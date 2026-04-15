import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/medical_assistant_cubit.dart';
import '../../domain/entities/medical_insight.dart';
import '../../domain/entities/ai_response.dart';
import '../widgets/query_input.dart';
import '../widgets/insight_card.dart';
import '../widgets/lab_result_card.dart';

/// Main page for the AI Medical Assistant
class MedicalAssistantPage extends StatelessWidget {
  const MedicalAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicalAssistantCubit(),
      child: const _MedicalAssistantView(),
    );
  }
}

class _MedicalAssistantView extends StatelessWidget {
  const _MedicalAssistantView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Medical Assistant'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MedicalAssistantCubit>().reset(),
            tooltip: 'New query',
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
            'How can I help with your health today?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'I can analyze your lab results, vital signs, and provide '
            'health insights based on clinical guidelines.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Try asking about:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickQueryChip('Glucose levels'),
              _QuickQueryChip('Blood pressure'),
              _QuickQueryChip('Cholesterol analysis'),
              _QuickQueryChip('Medication interactions'),
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
                          '${(response.confidence! * 100).toInt()}% confidence',
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

          // Insights section
          if (response.insights.isNotEmpty) ...[
            const Text(
              'Medical Insights',
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
              'Lab Results',
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
