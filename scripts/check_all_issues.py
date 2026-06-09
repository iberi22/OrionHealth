import json, subprocess, sys

r = subprocess.run(
    ['gh', 'issue', 'list', '--state', 'all',
     '--json', 'number,title,state,milestone',
     '--limit', '50'],
    capture_output=True, text=True
)

if r.returncode != 0:
    print(f"Error: {r.stderr}")
    sys.exit(1)

data = json.loads(r.stdout)
total = len(data)
closed = sum(1 for i in data if i['state'] == 'CLOSED')
open_n = sum(1 for i in data if i['state'] == 'OPEN')

print(f"Total issues: {total}")
print(f"Closed: {closed} ({closed*100//total}%)")
print(f"Open: {open_n} ({open_n*100//total}%)")
print()
print("Recent issues:")

for i in data[:25]:
    m = i.get('milestone')
    m_title = m['title'] if m else '(no milestone)'
    print(f"  #{i['number']} {i['state']:6s} [{m_title}] - {i['title'][:60]}")

if total > 25:
    print(f"  ... and {total-25} more")
