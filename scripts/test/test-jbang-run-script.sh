#!/usr/bin/env bash
#
# Regression test for the `jbang-run-script` make target.
#
# It runs `make jbang-run-script`, captures the output, and checks that the
# HarmonicKeyMatcher demo still produces its known-good results. Exits non-zero
# (and prints a diff-style report) if anything drifts.
#
# Usage: ./scripts/test/test-jbang-run-script.sh

set -uo pipefail

# Resolve repo root from this script's location so it can be run from anywhere.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

# Known-good output (compiler/gradle noise stripped, see filtering below).
read -r -d '' EXPECTED <<'EOF'
=== Harmonic Key Matcher Demo ===

parseKey("Bb") => Key[keyNum=10, mode=MAJOR, preferFlats=true]

getCompatibleKeyStrings("A minor") =>
[A minor, C major, E minor, G major, D minor, F major, A# minor, G# minor, C# major, B major, F minor, D# minor, D# minor, C# minor, G# major, F# major, F# major, E major]

getCompatibleKeyStrings("Bb") =>
[Bb major, G minor, F major, D minor, Eb major, C minor, B major, A major, Ab minor, Gb minor, Gb major, E major, E major, D major, Eb minor, Db minor, Db minor, B minor]

getCompatibleKeyStrings("F# major") =>
[F# major, D# minor, C# major, A# minor, B major, G# minor, G major, F major, E minor, D minor, D major, C major, C major, A# major, B minor, A minor, A minor, G minor]
EOF

echo "==> Running 'make jbang-run-script'..."
RAW_OUTPUT="$(make jbang-run-script 2>&1)"
MAKE_STATUS=$?

if [[ $MAKE_STATUS -ne 0 ]]; then
  echo "FAIL: 'make jbang-run-script' exited with status $MAKE_STATUS" >&2
  echo "----- output -----" >&2
  echo "$RAW_OUTPUT" >&2
  exit 1
fi

# Keep only the demo block: from the header onward, with recursive-make's
# "Entering/Leaving directory" chatter (emitted when run via `make`) removed.
ACTUAL="$(printf '%s\n' "$RAW_OUTPUT" \
  | sed -n '/=== Harmonic Key Matcher Demo ===/,$p' \
  | grep -vE '^make(\[[0-9]+\])?:')"

if [[ "$ACTUAL" == "$EXPECTED" ]]; then
  echo "PASS: jbang-run-script output matches the expected demo result."
  exit 0
fi

echo "FAIL: jbang-run-script output did not match expected." >&2
echo "----- diff (expected vs actual) -----" >&2
diff <(printf '%s\n' "$EXPECTED") <(printf '%s\n' "$ACTUAL") >&2
echo "----- full raw output -----" >&2
echo "$RAW_OUTPUT" >&2
exit 1
