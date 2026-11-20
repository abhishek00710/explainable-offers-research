# Explainable offer recommendations: reproducible Swift prototype

Research companion for **Engineering Explainable Offer Recommendations in Mobile Banking** (intended IEEE Software manuscript). This is an independent synthetic research prototype, not a bank's production implementation. It contains deterministic rules, not a trained AI/ML classifier. No production impact, redemption, engagement or customer-outcome claims are made.

## Run

Requirements: macOS, Xcode/Apple Swift 6+, Python 3.9+ for the independent audit. No third-party dependencies or network access are needed. Package minimum macOS target is 13; see `results/environment.json` for the host actually tested.

From this directory:

```sh
./scripts/reproduce.sh results-reproduced
```

This executes XCTest, builds and runs the release experiment, independently audits the CSVs, and writes a SHA-256 manifest. It fails on any failed stage. The frozen fixture is consumed, never silently regenerated. Reproduction writes a separate directory to preserve the supplied results.

Equivalent individual commands (build/cache paths deliberately writable in restricted environments):

```sh
export CLANG_MODULE_CACHE_PATH=/tmp/explainable-clang-cache
swift test --disable-sandbox --scratch-path /tmp/explainable-offers-build
swift run -c release -debug-info-format none --disable-sandbox \
  --scratch-path /tmp/explainable-offers-build offer-experiments \
  --seed 20261119 --count 2160 --output results-reproduced
python3 scripts/audit.py results-reproduced
python3 scripts/manifest.py results-reproduced
```

`-debug-info-format none` avoids a sandbox-blocked `dsymutil` step on the measured host; optimizations remain release mode. `--disable-sandbox` disables the nested SwiftPM build sandbox, not the enclosing execution environment. Compilation cache warnings may still appear. These switches were tested on the recorded Swift version. On older compatible toolchains consult `swift run --help` if a build option differs.

To deliberately regenerate a fixture **for review** (not part of the normal test command):

```sh
swift run --disable-sandbox --scratch-path /tmp/explainable-offers-build \
  offer-experiments --seed 42 --count 72 --freeze /tmp/candidate-fixture.json
cmp Fixtures/frozen-seed42.json /tmp/candidate-fixture.json
```

`--seed` accepts UInt64, `--count` a positive Int. Default evaluation count is 2,160. Classification and ranking are deterministic for the same inputs and framework behavior; timing, memory, environment timestamps and logs are measurements and will differ.

## Read the artifacts

| Artifact | Purpose |
|---|---|
| `Sources/OfferCore` | Native NLTokenizer adapter, three classification methods, scoped profiles, authoritative eligibility gate, ranking and explanations |
| `Sources/SyntheticData` | Seeded generator and separately authored merchant/relevance resources |
| `Sources/Evaluation` | Classification and ranking metric formulas |
| `Sources/Experiments` | Fixed-clock experiment orchestration and timed pipeline |
| `Tests/OfferCoreTests` | Native-framework, boundary, safety, metric, determinism and frozen-fixture XCTest cases |
| `Fixtures/frozen-seed42.json` | Frozen 72-record regression fixture |
| `results/tables.md` | Generated Markdown tables for manuscript use |
| `results/*.csv` | Measured summaries, per-class/subset metrics, confusion, slices, raw predictions, ranking and benchmark trials |
| `results/dataset.json` | Complete labeled synthetic evaluation dataset |
| `results/environment.json` | Actual runtime, hardware, Swift/macOS versions and whole-process peak RSS |
| `results/*.log` | Console evidence, including initial failures and successful retries |
| `results/sha256-manifest.json` | Content hashes for code, tests, inputs, documentation and outputs |
| `docs/research-report.md` | Results, assumptions, failure cases and hypothetical production recommendations |
| `docs/dataset.md` | Schema, composition, provenance, generation and relevance-label methodology |
| `docs/architecture.md` | Mermaid architecture and decision contract |
| `docs/threats-to-validity.md` | Construct, internal, external, statistical and reproducibility limitations |

## Methods and metric denominators

- `metadata`: recognized structured category, otherwise explicit merchant-ID registry, otherwise unknown.
- `tokens`: word tokenization using Apple NaturalLanguage and reviewed aliases; ambiguity or no match yields unknown.
- `combined`: metadata first, then token fallback only when metadata abstains.
- `eligible_id`: ranking baseline using the identical authoritative eligibility/validity gate and ascending offer ID; no spending preference.

For each class: precision = TP/(TP+FP), recall = TP/(TP+FN), F1 = 2TP/(2TP+FP+FN). Zero denominators map to zero (including empty selected subsets). All-record accuracy counts exact label matches, including correct unknown. Classified-only metrics select prediction != unknown and retain all truth labels in that subset. Coverage = classified N / all N; abstention = 1 − coverage. Thus correct rejection of unknown is still abstention. `micro_six` aggregates all six labels; `macro_six` averages six; `micro_known` and `macro_known` use the five spending classes. Unknown predictions for true spending classes count as false negatives in all-record metrics. Per-class accuracy is not presented because true negatives would dominate; class-specific precision/recall/F1 and global accuracy are provided.

NDCG@3 uses gain `2^grade−1` and discount `log2(rank+1)` with one-based ranks; its ideal ranking contains the same eligible candidates. P@3 counts grades >0 and divides by 3, including when fewer than three candidates exist. Zero ideal gain yields NDCG zero by convention. Means equally weight eight scenarios. Relevance is synthetic and independently specified, not generated by the scorer.

Benchmarks measure the full in-memory pipeline (scope, deduplicate, filter, classify, profile, eligibility, ranking) at 100, 1,000 and 10,000 transactions for each method: two warmups and nine recorded trials, rotating method order. Dataset generation, serialization, process launch, compilation and environment collection are outside the timed region. Min/median/P90/max/mean/sample SD and all 81 trial times are exported. No confidence intervals are implied. RSS is a process-wide high-water mark, not method-specific allocation. This is not an iPhone latency or service-level benchmark.

## Framework reference

The tokenizer follows Apple's [NLTokenizer documentation](https://developer.apple.com/documentation/naturallanguage/nltokenizer) and [word-tokenization example](https://developer.apple.com/documentation/NaturalLanguage/tokenizing-natural-language-text). Each invocation creates its own instance, avoiding shared mutable tokenizer state. These references establish API usage; they do not validate the rules or banking use case.
