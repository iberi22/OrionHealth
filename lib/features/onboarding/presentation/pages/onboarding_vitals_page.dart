import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class OnboardingVitalsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final Map<String, dynamic> initialData;

  const OnboardingVitalsPage({
    super.key,
    required this.onNext,
    required this.initialData,
  });

  @override
  State<OnboardingVitalsPage> createState() => _OnboardingVitalsPageState();
}

class _OnboardingVitalsPageState extends State<OnboardingVitalsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _systolicController;
  late TextEditingController _diastolicController;
  late TextEditingController _heartRateController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.initialData['weight']?.toString() ?? '');
    _heightController = TextEditingController(text: widget.initialData['height']?.toString() ?? '');
    _systolicController = TextEditingController(text: widget.initialData['systolicBP']?.toString() ?? '');
    _diastolicController = TextEditingController(text: widget.initialData['diastolicBP']?.toString() ?? '');
    _heartRateController = TextEditingController(text: widget.initialData['heartRate']?.toString() ?? '');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Baseline Vitals',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: CyberTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your current vitals to establish a baseline.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            GlassmorphicCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              prefixIcon: Icon(Icons.monitor_weight_outlined, color: CyberTheme.secondary),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Height (cm)',
                              prefixIcon: Icon(Icons.height, color: CyberTheme.secondary),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _systolicController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Systolic BP',
                              helperText: 'Top number',
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _diastolicController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Diastolic BP',
                              helperText: 'Bottom number',
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _heartRateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Heart Rate (bpm)',
                        prefixIcon: Icon(Icons.favorite_outline, color: CyberTheme.secondary),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onNext({
                    'weight': double.tryParse(_weightController.text),
                    'height': double.tryParse(_heightController.text),
                    'systolicBP': int.tryParse(_systolicController.text),
                    'diastolicBP': int.tryParse(_diastolicController.text),
                    'heartRate': int.tryParse(_heartRateController.text),
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberTheme.primary,
                foregroundColor: CyberTheme.backgroundDark,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
