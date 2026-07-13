#!/usr/bin/env bash
#
# Regression test for the `jbang-run` make target.
#
# It runs `make jbang-run`, captures the output, and checks that running
# HarmonicKeyMatcher.java via jbang (which resolves //SOURCES and //DEPS itself)
# still produces its known-good results. Exits non-zero (with a diff-style
# report) if anything drifts.
#
# Usage: ./scripts/test/test-jbang-run.sh

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

echo "==> Running 'make jbang-run'..."
RAW_OUTPUT="$(make jbang-run 2>&1)"
MAKE_STATUS=$?

if [[ $MAKE_STATUS -ne 0 ]]; then
  echo "FAIL: 'make jbang-run' exited with status $MAKE_STATUS" >&2
  echo "----- output -----" >&2
  echo "$RAW_OUTPUT" >&2
  exit 1
fi

# Keep only the bracketed key-list lines (each starts with a note name A-G),
# dropping jbang's "[jbang] Resolving dependencies..." progress lines (printed
# on a cold dependency cache, e.g. CI), the incubator-module WARNING, and
# recursive-make's "Entering/Leaving directory" chatter.
ACTUAL="$(printf '%s\n' "$RAW_OUTPUT" | grep -E '^\[[A-G]')"

if [[ "$ACTUAL" == "$EXPECTED" ]]; then
  echo "PASS: jbang-run output matches the expected result."
  exit 0
fi

echo "FAIL: jbang-run output did not match expected." >&2
echo "----- diff (expected vs actual) -----" >&2
diff <(printf '%s\n' "$EXPECTED") <(printf '%s\n' "$ACTUAL") >&2
echo "----- full raw output -----" >&2
echo "$RAW_OUTPUT" >&2
exit 1
