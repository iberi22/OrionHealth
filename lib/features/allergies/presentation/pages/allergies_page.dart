import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/allergy.dart';
import '../../domain/repositories/allergy_repository.dart';

class AllergiesPage extends StatefulWidget {
  const AllergiesPage({super.key});

  @override
  State<AllergiesPage> createState() => _AllergiesPageState();
}

class _AllergiesPageState extends State<AllergiesPage> {
  final AllergyRepository _repository = getIt<AllergyRepository>();
  List<Allergy> _allergies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllergies();
  }

  Future<void> _loadAllergies() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final allergies = await _repository.getAllergies();
    if (!mounted) return;
    setState(() {
      _allergies = allergies;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.allergies,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllergies,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _allergies.isEmpty
                ? Stack(
                    children: [
                      ListView(),
                      _buildEmptyState(l10n),
                    ],
                  )
                : _buildAllergyList(l10n),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          HapticFeedback.lightImpact();
          _showAllergyForm(l10n);
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            l10n.noAllergies,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyList(AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allergies.length,
      itemBuilder: (context, index) {
        return _buildAllergyCard(_allergies[index], l10n);
      },
    );
  }

  Widget _buildAllergyCard(Allergy allergy, AppLocalizations l10n) {
    final Color severityColor = _getSeverityColor(allergy.severity);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showAllergyForm(l10n, allergy: allergy);
          },
          child: GlassmorphicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              allergy.name ?? l10n.notSpecified,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (allergy.isCritical) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.emergency, color: Colors.redAccent, size: 16),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          allergy.reaction ?? l10n.notSpecified,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        if (allergy.confirmedDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM yyyy').format(allergy.confirmedDate!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: severityColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getSeverityLabel(allergy.severity, l10n).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: severityColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(AllergySeverity severity) {
    switch (severity) {
      case AllergySeverity.mild:
        return Colors.greenAccent;
      case AllergySeverity.moderate:
        return Colors.orangeAccent;
      case AllergySeverity.severe:
        return Colors.redAccent;
      case AllergySeverity.lifeThreatening:
        return Colors.purpleAccent;
    }
  }

  String _getSeverityLabel(AllergySeverity severity, AppLocalizations l10n) {
    switch (severity) {
      case AllergySeverity.mild:
        return l10n.severityMild;
      case AllergySeverity.moderate:
        return l10n.severityModerate;
      case AllergySeverity.severe:
        return l10n.severitySevere;
      case AllergySeverity.lifeThreatening:
        return l10n.severityLifeThreatening;
    }
  }

  void _showAllergyForm(AppLocalizations l10n, {Allergy? allergy}) {
    final nameController = TextEditingController(text: allergy?.name);
    final reactionController = TextEditingController(text: allergy?.reaction);
    final notesController = TextEditingController(text: allergy?.notes);
    DateTime? selectedDate = allergy?.confirmedDate;
    AllergySeverity selectedSeverity = allergy?.severity ?? AllergySeverity.moderate;
    bool isCritical = allergy?.isCritical ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      allergy == null ? l10n.newAllergy : l10n.editAllergy,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (allergy != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          await _repository.deleteAllergy(allergy.id);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          _loadAllergies();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(nameController, l10n.allergenSubstance, Icons.warning_amber_rounded),
                const SizedBox(height: 12),
                Text(l10n.severity, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AllergySeverity.values.map((severity) {
                    final isSelected = selectedSeverity == severity;
                    return ChoiceChip(
                      label: Text(_getSeverityLabel(severity, l10n)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => selectedSeverity = severity);
                        }
                      },
                      selectedColor: _getSeverityColor(severity).withValues(alpha: 0.3),
                      labelStyle: TextStyle(
                        color: isSelected ? _getSeverityColor(severity) : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                _buildTextField(reactionController, l10n.reaction, Icons.bubble_chart),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: AppColors.secondary),
                  title: Text(l10n.confirmationDate),
                  subtitle: Text(selectedDate != null
                      ? DateFormat('dd MMM yyyy').format(selectedDate!)
                      : l10n.notSpecified),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.primary,
                              onPrimary: Colors.black,
                              surface: AppColors.surface,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setModalState(() => selectedDate = date);
                    }
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.isCritical),
                  subtitle: Text(l10n.requiresImmediateAttention),
                  secondary: Icon(
                    Icons.emergency,
                    color: isCritical ? Colors.redAccent : Colors.grey,
                  ),
                  value: isCritical,
                  activeColor: Colors.redAccent,
                  onChanged: (val) => setModalState(() => isCritical = val),
                ),
                _buildTextField(notesController, l10n.additionalNotes, Icons.notes, maxLines: 3),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.nameRequired),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final newAllergy = (allergy ?? Allergy()).copyWith(
                        name: nameController.text,
                        severity: selectedSeverity,
                        reaction: reactionController.text,
                        confirmedDate: selectedDate,
                        notes: notesController.text,
                        isCritical: isCritical,
                      );

                      await _repository.saveAllergy(newAllergy);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _loadAllergies();
                    },
                    child: Text(
                      allergy == null ? l10n.save : l10n.update,
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}
