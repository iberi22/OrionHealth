import os

dst_path = r'E:\scripts-python\orionhealth\scripts\generator_v2.py'

# Read current content to find the end of ICD10 list
content = open(dst_path, 'r').read()
lines = content.splitlines()

# Find line with ']' after ICD10
icd10_end = None
for i in range(len(lines)-1, -1, -1):
    if lines[i].strip() == ']':
        for j in range(i-1, -1, -1):
            if 'ICD10 = [' in lines[j]:
                icd10_end = i
                break
        if icd10_end:
            break

if icd10_end is None:
    print('ERROR: Could not find ICD10 closing bracket')
    exit(1)

print(f'Found ICD10 close at line {icd10_end+1}')

# Build the remaining data
new_data = []
