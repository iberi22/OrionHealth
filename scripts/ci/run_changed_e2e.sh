#!/usr/bin/env bash
# Runs the integration tests passed as arguments on the attached emulator.
# android-emulator-runner executes every `script:` line on its own, so loops live here.
set -u
mkdir -p test-results
adb logcat -c
rc=0
for f in "$@"; do
  echo "Running $f..."
  flutter test "$f" --flavor prod || rc=1
done
if [ $rc -ne 0 ]; then
  adb logcat -d > test-results/logcat.txt
fi
exit $rc
