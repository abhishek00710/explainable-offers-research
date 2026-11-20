#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
requested="${1:-runs/fresh}"
if [ -e "$requested" ]; then echo 'Output exists; choose a new directory to preserve evidence.' >&2; exit 2; fi
mkdir -p "$requested"
out="$(cd "$requested" && pwd)"
build_root="$(mktemp -d "${TMPDIR:-/tmp}/offers-clean-build.XXXXXX")"
trap 'rm -rf "$build_root"' EXIT
export CLANG_MODULE_CACHE_PATH="$build_root/clang-cache"
export PYTHONDONTWRITEBYTECODE=1
mkdir -p "$out/original" "$out/validation"
swift --version > "$out/swift-version.txt" 2>&1
sw_vers > "$out/macos-version.txt"
uname -m > "$out/architecture.txt"
swift test --package-path artifact --disable-sandbox --scratch-path "$build_root/original" 2>&1 | tee "$out/original/tests.log"
swift test --package-path artifact/Validation --disable-sandbox --scratch-path "$build_root/validation" 2>&1 | tee "$out/validation/tests.log"
(cd artifact && swift run -c release -debug-info-format none --disable-sandbox --scratch-path "$build_root/original" offer-experiments --seed 20261119 --count 2160 --output "$out/original") 2>&1 | tee "$out/original/experiments.log"
(cd artifact/Validation && swift run -c release -debug-info-format none --disable-sandbox --scratch-path "$build_root/validation" validate-offers "$out/validation") 2>&1 | tee "$out/validation/experiments.log"
python3 artifact/scripts/audit.py "$out/original" | tee "$out/original/audit.log"
python3 artifact/Validation/scripts/summarize.py "$out/validation" | tee "$out/validation/summary.log"
python3 artifact/Validation/scripts/audit.py "$out/validation" | tee "$out/validation/audit.log"
python3 scripts/check_metrics.py | tee "$out/historical-metrics.log"
python3 scripts/compare_runs.py "$out" | tee "$out/comparison.log"
