import re
content = open(r'E:\scripts-python\orionhealth\scripts\append_all.py', 'r').read()
matches = list(re.finditer("'''", content))
print(f'Found {len(matches)} triple quotes')
for m in matches:
    pos = m.start()
    line = content[:pos].count('\n') + 1
    print(f'  pos {pos}, line {line}')
