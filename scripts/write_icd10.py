import os

src = r'E:\scripts-python\orionhealth\scripts\build_all.py'
dst = r'E:\scripts-python\orionhealth\scripts\final_generator.py'

lines = open(src, 'r').read().splitlines()

# Find ICD10 data lines
start = None
for i, line in enumerate(lines):
    if 'ICD10 = [' in line:
        start = i + 1
        break

if start is None:
    print('ERROR: ICD10 not found in build_all.py')
    exit(1)

data_lines = []
for i in range(start, len(lines)):
    s = lines[i].strip()
    if s == ']':
        break
    if s and not s.startswith('#'):
        data_lines.append(s)

print(f'Found {len(data_lines)} ICD-10 lines')

# Append to final_generator.py
with open(dst, 'a', encoding='utf-8') as f:
    f.write('\n# ===== ICD-10 DATA (Chapters 1-4) =====\n')
    f.write('ICD10 = [\n')
    for line in data_lines:
        f.write('    ' + line + '\n')
    f.write(']\n')
    f.write('print(f"ICD-10 base entries: " + str(len(ICD10)))" + "\n")

print(f'Appended to {dst}')
print('Done')
