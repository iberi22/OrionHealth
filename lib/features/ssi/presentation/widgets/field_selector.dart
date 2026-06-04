import 'package:flutter/material.dart';

/// A badge widget that shows whether a field is ZKP-protected or plaintext.
class _ZkpBadge extends StatelessWidget {
  final bool isZkpProtected;

  const _ZkpBadge({required this.isZkpProtected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isZkpProtected
            ? colorScheme.tertiaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isZkpProtected
              ? colorScheme.tertiary.withValues(alpha: 0.5)
              : colorScheme.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isZkpProtected ? Icons.shield : Icons.public,
            size: 11,
            color: isZkpProtected
                ? colorScheme.tertiary
                : colorScheme.outline,
          ),
          const SizedBox(width: 3),
          Text(
            isZkpProtected ? 'ZKP' : 'PLAIN',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isZkpProtected
                  ? colorScheme.tertiary
                  : colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for selective disclosure — allows user to choose which fields to reveal.
class FieldSelector extends StatefulWidget {
  final Map<String, dynamic> fields;
  final ValueChanged<Set<String>> onSelectionChanged;

  /// Fields that support Zero-Knowledge Proof selective disclosure.
  /// Fields not in this set are transmitted as plain text.
  final Set<String> zkpEnabledFields;

  const FieldSelector({
    super.key,
    required this.fields,
    required this.onSelectionChanged,
    this.zkpEnabledFields = const {},
  });

  @override
  State<FieldSelector> createState() => _FieldSelectorState();
}

class _FieldSelectorState extends State<FieldSelector> {
  final Set<String> _selected = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    // By default, nothing is selected — user must explicitly choose
  }

  void _toggleAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        _selected.addAll(widget.fields.keys);
      } else {
        _selected.clear();
      }
    });
    widget.onSelectionChanged(Set.from(_selected));
  }

  void _toggleField(String key, bool? value) {
    setState(() {
      if (value == true) {
        _selected.add(key);
      } else {
        _selected.remove(key);
      }
      _selectAll = _selected.length == widget.fields.length;
    });
    widget.onSelectionChanged(Set.from(_selected));
  }

  IconData _fieldIcon(String key, dynamic value) {
    if (key.toLowerCase().contains('name') || key.toLowerCase().contains('id')) {
      return Icons.person;
    }
    if (key.toLowerCase().contains('date') || key.toLowerCase().contains('birth')) {
      return Icons.calendar_today;
    }
    if (key.toLowerCase().contains('blood') || key.toLowerCase().contains('pressure')) {
      return Icons.favorite;
    }
    if (key.toLowerCase().contains('allerg')) {
      return Icons.warning_amber;
    }
    if (key.toLowerCase().contains('diagnos') || key.toLowerCase().contains('code')) {
      return Icons.health_and_safety;
    }
    if (key.toLowerCase().contains('medic') || key.toLowerCase().contains('drug')) {
      return Icons.medication;
    }
    if (value is String && value.length > 30) {
      return Icons.description;
    }
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.fields.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with ZKP summary badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Selective Disclosure',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              // ZKP protection summary badge
              if (widget.zkpEnabledFields.isNotEmpty) ...[                const SizedBox(width: 8),
                _ZkpBadge(isZkpProtected: widget.zkpEnabledFields.length == widget.fields.length),
              ],
              const SizedBox(width: 8),
              Text(
                '${_selected.length}/${entries.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Select All toggle
        CheckboxListTile(
          value: _selectAll,
          onChanged: _toggleAll,
          title: Text(
            'Select All',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Text(
            'Reveal all fields to the recipient',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          dense: true,
        ),
        const Divider(height: 1),

        // Individual fields
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isSelected = _selected.contains(entry.key);
              final valueStr = entry.value?.toString() ?? 'null';

              return CheckboxListTile(
                value: isSelected,
                onChanged: (v) => _toggleField(entry.key, v),
                secondary: Icon(
                  _fieldIcon(entry.key, entry.value),
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  _formatFieldName(entry.key),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      valueStr.length > 60
                          ? '${valueStr.substring(0, 60)}...'
                          : valueStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildZkpFieldBadge(context, entry.key),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }



  /// Build a ZKP badge for an individual field row.
  Widget _buildZkpFieldBadge(BuildContext context, String fieldKey) {
    final isZkp = widget.zkpEnabledFields.contains(fieldKey);
    return _ZkpBadge(isZkpProtected: isZkp);
  }

  String _formatFieldName(String key) {
    // Convert camelCase/snake_case to Title Case
    return key
        .replaceAllMapped(
          RegExp(r'[_-](\w)'),
          (m) => ' ${m.group(1)!.toUpperCase()}',
        )
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)} ${m.group(2)}',
        )
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
