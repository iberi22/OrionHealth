#!/usr/bin/env bash
set -euo pipefail

if [ -z "${GITHUB_BASE_REF:-}" ]; then
    BASE_REF="HEAD^1"
else
    BASE_REF="origin/$GITHUB_BASE_REF"
fi

changed_tests=$(git diff --name-only "$BASE_REF" HEAD || true)

for f in $changed_tests; do
    if [[ "$f" == integration_test/*_e2e_test.dart ]] && [[ -f "$f" ]]; then
        echo "$f"
    fi
done
