with open(r'E:\scripts-python\orionhealth\scripts\build_all.py', 'r') as f:
    content = f.read()

# Fix the truncated line at the end
lines = content.splitlines()
last_line = lines[-1]
print(f"Last line: {repr(last_line)}")
print(f"File has {len(lines)} lines")

# The last line is truncated - replace it
if '"E58' in last_line and '"cal' in last_line:
    lines[-1] = '\n("E58","Dietary calcium deficiency","Endocrine",["calcium deficiency"]),\n'
    content = '\n'.join(lines)
    with open(r'E:\scripts-python\orionhealth\scripts\build_all.py', 'w') as f:
        f.write(content)
    print("Fixed last line")
else:
    print("Last line OK or different pattern, appending")
    content += '\n("E58","Dietary calcium deficiency","Endocrine",["calcium deficiency"]),\n'
    with open(r'E:\scripts-python\orionhealth\scripts\build_all.py', 'w') as f:
        f.write(content)

# Verify
with open(r'E:\scripts-python\orionhealth\scripts\build_all.py', 'r') as f:
    new_lines = f.readlines()
print(f"Now {len(new_lines)} lines, last line: {repr(new_lines[-1][:50])}")
