import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../application/onboarding_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

class BasicInfoStep extends StatefulWidget {
  const BasicInfoStep({super.key});

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  DateTime? _birthDate;
  String? _sex;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Personal',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text('Ingresa tus datos básicos para personalizar tu experiencia.',
              style: TextStyle(color: Colors.white.withAlpha(179))),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _nameController,
            label: 'Nombre completo',
            icon: Icons.person_outline,
            onChanged: (v) => context.read<OnboardingCubit>().updateName(v),
          ),
          const SizedBox(height: 20),
          _buildDatePicker(context),
          const SizedBox(height: 20),
          _buildSexSelector(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _weightController,
                  label: 'Peso (kg)',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => context.read<OnboardingCubit>().updateWeight(double.tryParse(v) ?? 0.0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _heightController,
                  label: 'Altura (cm)',
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => context.read<OnboardingCubit>().updateHeight(double.tryParse(v) ?? 0.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return GlassmorphicCard(
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
          floatingLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.black.withAlpha(40),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GlassmorphicCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
        title: Text(
          _birthDate == null
              ? 'Fecha de nacimiento'
              : DateFormat('dd MMM yyyy').format(_birthDate!),
          style: TextStyle(
            color: _birthDate == null ? Colors.white.withAlpha(179) : Colors.white,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _birthDate ?? DateTime(1990),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.surface,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (date != null) {
            setState(() => _birthDate = date);
            if (!context.mounted) return;
            context.read<OnboardingCubit>().updateBirthDate(date);
          }
        },
      ),
    );
  }

  Widget _buildSexSelector() {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wc, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('Sexo', style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _SexOption(label: 'Masculino', icon: Icons.male, isSelected: _sex == 'M', onTap: () { setState(() => _sex = 'M'); context.read<OnboardingCubit>().updateSex('M'); })),
                const SizedBox(width: 16),
                Expanded(child: _SexOption(label: 'Femenino', icon: Icons.female, isSelected: _sex == 'F', onTap: () { setState(() => _sex = 'F'); context.read<OnboardingCubit>().updateSex('F'); })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.read<OnboardingCubit>().previousStep(),
            child: const Text('Atrás'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.read<OnboardingCubit>().nextStep(),
            child: const Text('Siguiente', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _SexOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SexOption({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(51) : Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white12, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.white54),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? AppColors.primary : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
