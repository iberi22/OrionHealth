import re

models = ['health_record.dart', 'lab_result.dart', 'medical_document.dart',
          'medical_event.dart', 'medication_entry.dart', 'vital_sign.dart']

for model in models:
    path = f'lib/models/{model}'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove @override List<Object?> get props => [...];
    # Pattern: newline + @override + newline + List...get props => [ ... ];
    new_content = re.sub(
        r'\n  @override\n  List<\w+\?> get props => \[.*?\n\}',
        '\n}',
        content,
        flags=re.DOTALL
    )

    if new_content != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f'Removed props from: {model}')
    else:
        print(f'No props found in: {model}')
