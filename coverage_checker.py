import sys
import os

def parse_lcov(file_path, prefix=""):
    coverage = {}
    current_file = None
    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found.")
        sys.exit(1)

    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('SF:'):
                current_file = line.split('SF:')[1]
                if current_file.startswith(prefix):
                    coverage[current_file] = {'found': 0, 'hit': 0, 'missed_lines': []}
            elif line.startswith('DA:') and current_file in coverage:
                parts = line.split('DA:')[1].split(',')
                if len(parts) >= 2:
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
    lcov_file = 'coverage/lcov.info'
    coverage = parse_lcov(lcov_file)

    total_found = 0
    total_hit = 0

    for file, data in coverage.items():
        total_found += data['found']
        total_hit += data['hit']

    if total_found == 0:
        print("No coverage data found or all files have 0 lines.")
        overall_percentage = 0.0
    else:
        overall_percentage = (total_hit / total_found) * 100

    print(f"Overall Coverage: {overall_percentage:.2f}% ({total_hit}/{total_found})")

    threshold = 80.0
    if overall_percentage < threshold:
        print(f"FAILED: Coverage {overall_percentage:.2f}% is below threshold {threshold}%")
        sys.exit(1)
    else:
        print(f"PASSED: Coverage {overall_percentage:.2f}% is above threshold {threshold}%")
        sys.exit(0)

if __name__ == "__main__":
    main()
