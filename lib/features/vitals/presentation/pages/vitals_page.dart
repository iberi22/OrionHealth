import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';

class VitalsPage extends StatefulWidget {
  const VitalsPage({super.key});

  @override
  State<VitalsPage> createState() => _VitalsPageState();
}

class _VitalsPageState extends State<VitalsPage> {
  final VitalSignRepository _repository = getIt<VitalSignRepository>();
  bool _isLoading = true;
  Map<VitalSignType, VitalSign?> _latestVitals = {};
  List<VitalSign> _allVitals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final latest = await _repository.getLatestVitals();
      final all = await _repository.getAllVitalSigns();
      setState(() {
        _latestVitals = latest;
        _allVitals = all;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vitals: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signos Vitales'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildLatestVitalsGrid(),
                    ),
                  ),
                  ...VitalSignType.values.map((type) {
                    final vitalsOfType = _allVitals.where((v) => v.type == type).toList();
                    if (vitalsOfType.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                    return SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                            child: Text(
                              _getVitalLabel(type).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: CyberTheme.secondary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final vital = vitalsOfType[index];
                                return _buildVitalListTile(vital);
                              },
                              childCount: vitalsOfType.length,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVitalBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLatestVitalsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildVitalCard(VitalSignType.heartRate, 'BPM', Icons.favorite),
        _buildVitalCard(VitalSignType.temperature, '°C', Icons.thermostat),
        _buildVitalCard(VitalSignType.spO2, '%', Icons.bloodtype),
        _buildBloodPressureCard(),
      ],
    );
  }

  Widget _buildVitalCard(VitalSignType type, String unit, IconData icon) {
    final vital = _latestVitals[type];
    final label = _getVitalLabel(type);

    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: CyberTheme.secondary),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              vital != null ? vital.value.toStringAsFixed(1) : '--',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CyberTheme.primary,
              ),
            ),
            Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodPressureCard() {
    final systolic = _latestVitals[VitalSignType.bloodPressureSystolic];
    final diastolic = _latestVitals[VitalSignType.bloodPressureDiastolic];

    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              children: [
                Icon(Icons.speed, size: 16, color: CyberTheme.secondary),
                SizedBox(width: 4),
                Text('Presión',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              systolic != null && diastolic != null
                  ? '${systolic.value.toInt()}/${diastolic.value.toInt()}'
                  : '--/--',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CyberTheme.primary,
              ),
            ),
            const Text('mmHg',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalListTile(VitalSign vital) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(_getVitalIcon(vital.type), color: CyberTheme.secondary),
        title: Text('${_getVitalLabel(vital.type)}: ${vital.value}'),
        subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(vital.dateTime)),
        trailing: vital.notes != null && vital.notes!.isNotEmpty
            ? const Icon(Icons.note_alt_outlined, size: 16)
            : null,
      ),
    );
  }

  String _getVitalLabel(VitalSignType type) {
    switch (type) {
      case VitalSignType.heartRate:
        return 'Ritmo Cardíaco';
      case VitalSignType.temperature:
        return 'Temperatura';
      case VitalSignType.bloodPressureSystolic:
        return 'Presión (Sist.)';
      case VitalSignType.bloodPressureDiastolic:
        return 'Presión (Diast.)';
      case VitalSignType.spO2:
        return 'SpO2';
      case VitalSignType.steps:
        return 'Pasos';
      case VitalSignType.sleep:
        return 'Sueño';
      case VitalSignType.bloodGlucose:
        return 'Glucosa';
      case VitalSignType.oxygenSaturation:
        return 'Saturación Oxígeno';
    }
  }

  IconData _getVitalIcon(VitalSignType type) {
    switch (type) {
      case VitalSignType.heartRate:
        return Icons.favorite;
      case VitalSignType.temperature:
        return Icons.thermostat;
      case VitalSignType.bloodPressureSystolic:
      case VitalSignType.bloodPressureDiastolic:
        return Icons.speed;
      case VitalSignType.spO2:
      case VitalSignType.oxygenSaturation:
        return Icons.bloodtype;
      case VitalSignType.steps:
        return Icons.directions_walk;
      case VitalSignType.sleep:
        return Icons.bedtime;
      case VitalSignType.bloodGlucose:
        return Icons.opacity;
    }
  }

  void _showAddVitalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CyberTheme.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddVitalBottomSheet(
        onSave: (vital) async {
          await _repository.saveVitalSign(vital);
          if (context.mounted) {
            _loadData();
          }
        },
      ),
    );
  }
}

class _AddVitalBottomSheet extends StatefulWidget {
  final Function(VitalSign) onSave;

  const _AddVitalBottomSheet({required this.onSave});

  @override
  State<_AddVitalBottomSheet> createState() => _AddVitalBottomSheetState();
}

class _AddVitalBottomSheetState extends State<_AddVitalBottomSheet> {
  VitalSignType _selectedType = VitalSignType.heartRate;
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Agregar Signo Vital',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<VitalSignType>(
            initialValue: _selectedType,
            items: VitalSignType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getVitalLabel(type)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedType = value);
            },
            decoration: const InputDecoration(labelText: 'Tipo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Valor',
              suffixText: _getVitalUnit(_selectedType),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Fecha y Hora: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDateTime,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (date != null && mounted) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                );
                if (time != null) {
                  setState(() {
                    _selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notas (Opcional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberTheme.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              final value = double.tryParse(_valueController.text);
              if (value == null) return;

              final vital = VitalSign(
                type: _selectedType,
                value: value,
                dateTime: _selectedDateTime,
                notes: _notesController.text,
              );
              widget.onSave(vital);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getVitalLabel(VitalSignType type) {
    switch (type) {
      case VitalSignType.heartRate:
        return 'Ritmo Cardíaco';
      case VitalSignType.temperature:
        return 'Temperatura';
      case VitalSignType.bloodPressureSystolic:
        return 'Presión (Sist.)';
      case VitalSignType.bloodPressureDiastolic:
        return 'Presión (Diast.)';
      case VitalSignType.spO2:
        return 'SpO2';
      case VitalSignType.steps:
        return 'Pasos';
      case VitalSignType.sleep:
        return 'Sueño';
      case VitalSignType.bloodGlucose:
        return 'Glucosa';
      case VitalSignType.oxygenSaturation:
        return 'Saturación Oxígeno';
    }
  }

  String _getVitalUnit(VitalSignType type) {
    switch (type) {
      case VitalSignType.heartRate:
        return 'BPM';
      case VitalSignType.temperature:
        return '°C';
      case VitalSignType.bloodPressureSystolic:
      case VitalSignType.bloodPressureDiastolic:
        return 'mmHg';
      case VitalSignType.spO2:
      case VitalSignType.oxygenSaturation:
        return '%';
      case VitalSignType.steps:
        return 'pasos';
      case VitalSignType.sleep:
        return 'min';
      case VitalSignType.bloodGlucose:
        return 'mg/dL';
    }
  }
}
