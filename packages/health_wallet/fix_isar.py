import re

# Fix all 6 models: remove duplicate id field, fix Isar autoIncrement pattern
models = ['health_record.dart', 'lab_result.dart', 'medical_document.dart',
          'medical_event.dart', 'medication_entry.dart', 'vital_sign.dart']

for model in models:
    path = f'lib/models/{model}'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove duplicate "Id isarId = Isar.autoIncrement;" field
    content = re.sub(r'\s*Id\s+isarId\s*=\s*Isar\.autoIncrement;\s*\n', '\n', content)

    # Remove @Id() on final int id and change to "Id id = Isar.autoIncrement;"
    content = re.sub(r'\s*@Id\(\)\s*\n\s*final int id;',
                     '\n  Id id = Isar.autoIncrement;', content)

    # Also handle @PrimaryKey() case  
    content = re.sub(r'\s*@PrimaryKey\(\)\s*\n\s*@Index\(unique: true\)\s*\n\s*final (String|int) id;',
                     '\n  Id id = Isar.autoIncrement;', content)
    content = re.sub(r'\s*@PrimaryKey\(\)\s*\n\s*final (String|int) id;',
                     '\n  Id id = Isar.autoIncrement;', content)
    content = re.sub(r'\s*@Index\(unique: true\)\s*\n\s*final (String|int) id;',
                     '\n  Id id = Isar.autoIncrement;', content)

    # Remove @ignore static const commonLoincCodes (not needed for Isar)
    # Actually keep it, it's fine

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: {model}')
