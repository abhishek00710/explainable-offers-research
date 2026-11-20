# IEEE Software follow-up validation

This standalone extension preserves **all 64 pre-existing files**, including the original source, package manifest, reports and both original result directories. SHA-256 checks enforce this. It compiles byte-identical copies of OfferCore/Evaluation plus one additive conflict-abstaining policy; it does not edit the original package.

Read [updated report](docs/research-report-updated.md), [generated manuscript tables](results/tables.md), and [pre-execution protocol](docs/protocol.md). Original results remain in `../results` and the original report in `../docs/research-report.md`. The new results are **additional synthetic experiments**, not corrected/replaced original measurements.

## Reproduce

From this directory, on macOS with Apple Swift 6+ and Python 3.9+:

```sh
./scripts/reproduce.sh results-reproduced
```

The script runs the original 19 XCTest cases, 10 new XCTest cases, release-mode validation, the original audit, the independent new audit, and table generation. It records version/architecture evidence. SwiftPM caches/build products are redirected to `/tmp`; debug-symbol output is disabled because the original execution environment blocked `dsymutil`. There are no external package dependencies.

Individual experiment command:

```sh
export CLANG_MODULE_CACHE_PATH=/tmp/offer-validation-cache
swift run -c release -debug-info-format none --disable-sandbox \
  --scratch-path /tmp/offer-validation-build validate-offers results-reproduced
python3 scripts/audit.py results-reproduced
python3 scripts/summarize.py results-reproduced
```

Normal reproduction **consumes frozen inputs**, not regenerated labels. `scripts/prepare.py` records their construction and can deliberately regenerate `inputs/plans.json` and `inputs/ranking-expanded.json` for review (optional first argument selects a separate output directory). This script imports no classifier and never changes original files or labels. The output-directory argument must be relative to this Validation directory or absolute. Logs, run time and version records can differ; measured classifications/ranking, metrics and tables should match with the same framework behavior.

## Design and artifacts

- Eight controlled error levels: 0, 5, 10, 20, 40, 60, 80, 100%; five allocation seeds: 11, 29, 47, 71, 101. A separate untouched original-data run is included. Fixed original data-generation seed: 20261119; clock: 1800000000.
- Exactly 600 known-category records with structured metadata are intervened on, 120 per class. 0% is an oracle-clean constructed channel; it is not the original dataset. The remaining 1,560 records are unchanged, including 60 out-of-scope records with incorrect metadata. See `interventions.csv` for both controlled and all-structured denominators.
- Four classification methods; five rankers including eligible-ID baseline. `conflict_abstain` abstains only when metadata and token channels both assert known, different categories. It does not treat missing/ambiguous token evidence as disagreement and cannot correct joint mistakes.
- Eight unchanged original ranking scenarios plus 16 new authored scenarios. Each has explicit relevance grades, rationale, snapshot and independently authored expected candidate IDs. New scenarios also record `historyTruth` for provenance; the ranker never reads this field. Grades were frozen before outcome inspection.
- `predictions.csv`: all 354,240 raw predictions with fixed truth, identity and controlled-pool membership. `classification-summary.csv`: all 656 per-seed/method/subset summaries. `per-class.csv` and `confusion.csv`: all class counts and cells, including zeros.
- `sensitivity-aggregate.csv`: five-seed arithmetic means and min/max ranges, **not** confidence intervals. `ranking.csv`: 120 scenario/method rows with candidate-set checks and explicit quality status. `ranking-summary.csv`: original8/new/pooled means with separate eligible quality denominators.
- `inputs/original-sha256.json`: frozen hashes of original files. `results/audit.log`: preservation, label, intervention, count, denominator, confusion and ranking audits. `results/original-audit.log`: recomputation of the original exported metrics and benchmarks.
- `results/tests.log`, `results/original-tests.log`, `results/experiments.log`: execution evidence. `results/environment.json` and version files identify the actual host. `sha256-manifest.json` hashes the validation artifacts.

## Denominators and conventions

`all`: all 2,160 records. `known_truth`: 1,800 rows whose authored truth is one of five spending categories. `controlled`: the 600 intervened rows. `classified`: only rows with a non-unknown prediction, therefore method/rate-dependent N. Accuracy = exact matches / selected N; coverage = non-unknown predictions / selected N. Coverage within the classified-only subset is necessarily one; use the `all` row for useful global coverage. An empty subset's accuracy/coverage/abstention is NA.

Every scope reports per-class TP/FP/FN/support, precision, recall and F1. `macro_f1_known` averages the five class F1 values equally; `macro_f1_six` includes unknown as a sixth outcome. It is **not** the harmonic mean of macro precision and recall. Absent-class/zero-denominator P/R/F1 are zero. Known-class micro excludes unknown as a target but still counts known→unknown as FN and unknown→known as FP. Six-class micro-F1 equals overall accuracy for these single-label outcomes. Unknown gold means out-of-scope; unknown prediction is abstention even when correct.

Ranking uses gain `2^grade-1`, logarithmic discount, and k=3. The ideal candidate set comes from authored expected eligibility, not the returned ranking. Candidate-set equality is checked before interpreting quality. Missing/stale/wrong-account snapshots produce no candidates: quality NA. A nonempty candidate set with no positive relevance has zero ideal gain: quality also NA. These cases stay in the candidate-set checks and are excluded from quality means. P@3 divides by three when quality is defined, even for one or two eligible offers. This protocol is explicit; the original metric helper's zero-ideal convention is left unchanged and is bypassed by the new runner for undefined cases.

No new latency or per-method memory benchmark was run. Original timings are retained only as measurements on their recorded macOS/Swift/arm64 environment. The conflict profile adapter reuses ledger filtering then reclassifies admitted contributions, and is not intended as a performance-optimized implementation. No iOS, production, human-comprehension, significance or benefit claims follow from these experiments.

After any deliberate artifact update, run `python3 scripts/manifest.py` to regenerate the validation manifest. This does not change the original preservation manifest.
