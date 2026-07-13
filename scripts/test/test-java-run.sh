#!/usr/bin/env bash
#
# Regression test for the `java-run` make target.
#
# It runs `make java-run`, captures the output, and checks that compiling
# HarmonicKeyMatcher.java with javac and running it against the gradle-built
# backend classes still produces its known-good results. Exits non-zero (with a
# diff-style report) if anything drifts.
#
# Usage: ./scripts/test/test-java-run.sh

set -uo pipefail

# Resolve repo root from this script's location so it can be run from anywhere.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

# Known-good output: the three compatible-key lists printed by main().
read -r -d '' EXPECTED <<'EOF'
[A minor, C major, E minor, G major, D minor, F major, A# minor, G# minor, C# major, B major, F minor, D# minor, D# minor, C# minor, G# major, F# major, F# major, E major]
[Bb major, G minor, F major, D minor, Eb major, C minor, B major, A major, Ab minor, Gb minor, Gb major, E major, E major, D major, Eb minor, Db minor, Db minor, B minor]
[F# major, D# minor, C# major, A# minor, B major, G# minor, G major, F major, E minor, D minor, D major, C major, C major, A# major, B minor, A minor, A minor, G minor]
EOF

echo "==> Running 'make java-run'..."
RAW_OUTPUT="$(make java-run 2>&1)"
MAKE_STATUS=$?

if [[ $MAKE_STATUS -ne 0 ]]; then
  echo "FAIL: 'make java-run' exited with status $MAKE_STATUS" >&2
  echo "----- output -----" >&2
  echo "$RAW_OUTPUT" >&2
  exit 1
fi

# Keep only the bracketed key-list lines, dropping any compiler/JVM warnings
# and recursive-make's "Entering/Leaving directory" chatter.
ACTUAL="$(printf '%s\n' "$RAW_OUTPUT" | grep -E '^\[')"

if [[ "$ACTUAL" == "$EXPECTED" ]]; then
  echo "PASS: java-run output matches the expected result."
  exit 0
fi

echo "FAIL: java-run output did not match expected." >&2
echo "----- diff (expected vs actual) -----" >&2
diff <(printf '%s\n' "$EXPECTED") <(printf '%s\n' "$ACTUAL") >&2
echo "----- full raw output -----" >&2
echo "$RAW_OUTPUT" >&2
exit 1
