@echo off
cd /d E:\scripts-python\orionhealth
python -c "
import json, subprocess
r = subprocess.run(['gh','issue','list','--state','all','--json','number,title,state,milestone','--limit','50'], capture_output=True, text=True)
data = json.loads(r.stdout)
closed = sum(1 for i in data if i['state']=='CLOSED')
open_issues = sum(1 for i in data if i['state']=='OPEN')
print(f'Total issues: {len(data)}')
print(f'Closed: {closed} ({closed*100//len(data)}%)')
print(f'Open: {open_issues} ({open_issues*100//len(data)}%)')
print()
for i in data[:25]:
    m = i.get('milestone', {})
    m_title = m['title'] if m else '(no milestone)'
    print(f'#{i[\"number\"]} {i[\"state\"]:6s} [{m_title}] - {i[\"title\"][:60]}')
if len(data) > 25:
    print(f'... and {len(data)-25} more')
"
