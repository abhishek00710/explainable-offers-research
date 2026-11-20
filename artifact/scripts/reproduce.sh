#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export CLANG_MODULE_CACHE_PATH="${TMPDIR:-/tmp}/explainable-offers-clang-cache"
build_path="${TMPDIR:-/tmp}/explainable-offers-repro-build"
result_path="${1:-results}"
mkdir -p "$result_path"
# --disable-sandbox avoids nested SwiftPM sandbox restrictions; dependencies are all local.
swift test --disable-sandbox --scratch-path "$build_path" 2>&1 | tee "$result_path/tests.log"
swift run -c release -debug-info-format none --disable-sandbox --scratch-path "$build_path" offer-experiments --seed 20261119 --count 2160 --output "$result_path" 2>&1 | tee "$result_path/experiments.log"
python3 scripts/audit.py "$result_path" | tee "$result_path/audit.log"
python3 scripts/manifest.py "$result_path"
