import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class OnboardingAllergiesPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final Map<String, dynamic> initialData;

  const OnboardingAllergiesPage({
    super.key,
    required this.onNext,
    required this.initialData,
  });

  @override
  State<OnboardingAllergiesPage> createState() => _OnboardingAllergiesPageState();
}

class _OnboardingAllergiesPageState extends State<OnboardingAllergiesPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _allergyNameController;
  late TextEditingController _notesController;
  String? _selectedSeverity;

  final List<String> _severityOptions = ['Mild', 'Moderate', 'Severe'];

  @override
  void initState() {
    super.initState();
    _allergyNameController = TextEditingController(text: widget.initialData['allergyName'] ?? '');
    _notesController = TextEditingController(text: widget.initialData['allergyNotes'] ?? '');
    _selectedSeverity = widget.initialData['allergySeverity'];
  }

  @override
  void dispose() {
    _allergyNameController.dispose();
    _notesController.dispose();
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
              'Allergies',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: CyberTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Do you have any known allergies? (Optional)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            GlassmorphicCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _allergyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Allergy Name',
                        prefixIcon: Icon(Icons.warning_amber_outlined, color: CyberTheme.secondary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedSeverity,
                      decoration: const InputDecoration(
                        labelText: 'Severity',
                        prefixIcon: Icon(Icons.error_outline, color: CyberTheme.secondary),
                      ),
                      items: _severityOptions.map((severity) {
                        return DropdownMenuItem(value: severity, child: Text(severity));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedSeverity = value),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.note_alt_outlined, color: CyberTheme.secondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                widget.onNext({
                  'allergyName': _allergyNameController.text,
                  'allergySeverity': _selectedSeverity,
                  'allergyNotes': _notesController.text,
                });
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
