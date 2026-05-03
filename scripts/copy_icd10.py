import os

src_path = r'E:\scripts-python\orionhealth\scripts\build_all.py'
dst_path = r'E:\scripts-python\orionhealth\scripts\generator_v2.py'

src_lines = open(src_path, 'r').read().splitlines()

# Find ICD10 = [ and the start of actual data
start_idx = None
for i, line in enumerate(src_lines):
    if 'ICD10 = [' in line:
        start_idx = i + 1
        break

if start_idx is None:
    print('ERROR: Could not find ICD10 = [')
    exit(1)

# Read until we find the closing ] of ICD10 list
data_lines = []
for i in range(start_idx, len(src_lines)):
    line = src_lines[i]
    stripped = line.strip()
    if stripped == ']':
        break
    if stripped:
        data_lines.append(line)

print(f'Found {len(data_lines)} ICD-10 data lines')

# Append these to generator_v2.py
with open(dst_path, 'a', encoding='utf-8') as f:
    f.write('# ICD-10 entries from WHO\n')
    f.write('ICD10 = [\n')
    for line in data_lines:
        s = line.strip()
        if s and not s.startswith('#'):
            f.write('    ' + s + '\n')
    f.write(']\n')

print('ICD-10 data appended to generator_v2.py')
print('Total ICD-10 entries:', len(data_lines))
