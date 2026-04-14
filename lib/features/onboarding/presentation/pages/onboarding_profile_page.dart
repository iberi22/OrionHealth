import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class OnboardingProfilePage extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final Map<String, dynamic> initialData;

  const OnboardingProfilePage({
    super.key,
    required this.onNext,
    required this.initialData,
  });

  @override
  State<OnboardingProfilePage> createState() => _OnboardingProfilePageState();
}

class _OnboardingProfilePageState extends State<OnboardingProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  DateTime? _selectedDate;
  String? _selectedSex;
  String? _selectedBloodType;

  final List<String> _sexOptions = ['M', 'F', 'O'];
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name'] ?? '');
    _selectedDate = widget.initialData['birthDate'];
    _selectedSex = widget.initialData['sex'];
    _selectedBloodType = widget.initialData['bloodType'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: CyberTheme.primary,
              onPrimary: CyberTheme.backgroundDark,
              surface: CyberTheme.surfaceDark,
              onSurface: CyberTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
              'Profile Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: CyberTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Let\'s start with some basic details about you.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            GlassmorphicCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person, color: CyberTheme.secondary),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Birth Date',
                          prefixIcon: Icon(Icons.cake, color: CyberTheme.secondary),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedSex,
                      decoration: const InputDecoration(
                        labelText: 'Sex',
                        prefixIcon: Icon(Icons.wc, color: CyberTheme.secondary),
                      ),
                      items: _sexOptions.map((sex) {
                        return DropdownMenuItem(value: sex, child: Text(sex));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedSex = value),
                      validator: (value) => value == null ? 'Please select' : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedBloodType,
                      decoration: const InputDecoration(
                        labelText: 'Blood Type',
                        prefixIcon: Icon(Icons.bloodtype, color: CyberTheme.secondary),
                      ),
                      items: _bloodTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedBloodType = value),
                      validator: (value) => value == null ? 'Please select' : null,
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
                    'name': _nameController.text,
                    'birthDate': _selectedDate,
                    'sex': _selectedSex,
                    'bloodType': _selectedBloodType,
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
