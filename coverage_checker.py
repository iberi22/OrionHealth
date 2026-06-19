import sys

def parse_lcov(file_path, prefix="lib/features/meditation/"):
    coverage = {}
    current_file = None
    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('SF:'):
                current_file = line.split('SF:')[1]
                if current_file.startswith(prefix):
                    coverage[current_file] = {'found': 0, 'hit': 0, 'missed_lines': []}
            elif line.startswith('DA:') and current_file in coverage:
                parts = line.split('DA:')[1].split(',')
                line_num = int(parts[0])
                count = int(parts[1])
                if count == 0:
                    coverage[current_file]['missed_lines'].append(line_num)
            elif line.startswith('LF:') and current_file in coverage:
                coverage[current_file]['found'] = int(line.split('LF:')[1])
            elif line.startswith('LH:') and current_file in coverage:
                coverage[current_file]['hit'] = int(line.split('LH:')[1])
    return coverage

def main():
    coverage = parse_lcov('coverage/lcov.info')
    for file, data in coverage.items():
        found = data['found']
        hit = data['hit']
        percentage = (hit / found * 100) if found > 0 else 100
        print(f"{file}: {hit}/{found} ({percentage:.2f}%)")
        if data['missed_lines']:
            print(f"  Missed lines: {data['missed_lines']}")

if __name__ == "__main__":
    main()
