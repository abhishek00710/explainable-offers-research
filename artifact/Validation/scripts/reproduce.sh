#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
out="${1:-results-reproduced}"
mkdir -p "$out"
export CLANG_MODULE_CACHE_PATH=/tmp/offer-validation-cache
swift test --package-path .. --disable-sandbox --scratch-path /tmp/explainable-offers-build 2>&1 | tee "$out/original-tests.log"
swift test --disable-sandbox --scratch-path /tmp/offer-validation-build 2>&1 | tee "$out/tests.log"
swift run -c release -debug-info-format none --disable-sandbox --scratch-path /tmp/offer-validation-build validate-offers "$out" 2>&1 | tee "$out/experiments.log"
python3 ../scripts/audit.py ../results | tee "$out/original-audit.log"
python3 scripts/audit.py "$out" | tee "$out/audit.log"
python3 scripts/summarize.py "$out" | tee "$out/summary.log"
python3 scripts/audit.py "$out" > "$out/audit-final.log"
swift --version > "$out/swift-version.txt" 2>&1
sw_vers > "$out/macos-version.txt"
uname -m > "$out/architecture.txt"
