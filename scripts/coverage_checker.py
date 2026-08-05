#!/usr/bin/env python3
"""Check Flutter coverage threshold from coverage/lcov.info.

Reads the lcov file produced by `flutter test --coverage` and fails
if line coverage is below the configured threshold (default: 40%).
Set COVERAGE_THRESHOLD env var to override.
"""
import os
import sys

LCOV_PATH = "coverage/lcov.info"
DEFAULT_THRESHOLD = 40.0


def parse_lcov(path: str) -> tuple[int, int]:
    """Return (lines_found, lines_hit) from an lcov file."""
    lines_found = 0
    lines_hit = 0
    with open(path, encoding="utf-8") as f:
        for line in f:
            if line.startswith("LF:"):
                lines_found += int(line.strip().split(":")[1])
            elif line.startswith("LH:"):
                lines_hit += int(line.strip().split(":")[1])
    return lines_found, lines_hit


def main() -> int:
    threshold = float(os.environ.get("COVERAGE_THRESHOLD", DEFAULT_THRESHOLD))

    if not os.path.exists(LCOV_PATH):
        print(f"ERROR: {LCOV_PATH} not found. Run `flutter test --coverage` first.")
        return 2

    lines_found, lines_hit = parse_lcov(LCOV_PATH)
    if lines_found == 0:
        print(f"ERROR: no line data in {LCOV_PATH} (lines_found=0).")
        return 2

    coverage = (lines_hit / lines_found) * 100.0
    print(f"Coverage: {coverage:.2f}% ({lines_hit}/{lines_found} lines) — threshold {threshold:.1f}%")

    if coverage < threshold:
        print(f"FAIL: coverage {coverage:.2f}% below threshold {threshold:.1f}%")
        return 1

    print(f"PASS: coverage above threshold {threshold:.1f}%")
    return 0


if __name__ == "__main__":
    sys.exit(main())
