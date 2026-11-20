# Engineering Explainable Offer Recommendations in Mobile Banking

## Research prototype report

This artifact supports technical discussion for a manuscript intended for IEEE Software. It is not submitted, peer-reviewed, a production bank implementation, or evidence of customer benefit. The implemented methods are deterministic metadata lookups and token-based rules. Apple NaturalLanguage provides tokenization; no classifier is trained in this project.

### Research questions

1. How do metadata-only, explicit token rules and metadata-first fallback differ in correctness, coverage and failure modes on an inspectable synthetic corpus?
2. Does category-spending ranking improve ordering over an eligible-only ID baseline under separately authored relevance judgments, and when does it fail?
3. What runtime distributions are observed for the complete in-memory pipeline on this macOS host at three input sizes?

### Measured facts

The minimal metadata baseline executed three XCTest cases successfully before the expanded implementation. The expanded suite executed **19 XCTest cases with zero failures** on macOS, including direct `NLTokenizer` output assertions. `results/tests.log` contains named test cases and console output; the final Swift Testing footer reports zero tests because this package uses XCTest. It does not mean the XCTest suite failed to run.

The recorded release experiment used Apple Swift 6.4.2, macOS 27.2.1 (build 26B131), arm64, eight logical processors, seed 20261119 and fixed epoch clock 1,800,000,000. Actual run UTC was 2026-11-19T21:22:14Z. Hardware model/physical-memory lookup through `sysctl` was blocked by the sandbox, and is explicitly unavailable in the environment record. Classification consumed 2,160 records representing **36 authored cases**, six categories with 360 rows each. Ranking consumed eight scenarios, each with five eligible candidates. Benchmarking completed 81 measured trials plus 18 warmups. The independent Python audit recomputed all exported classification class/aggregate metrics, confusion counts, ranking scores and benchmark distributions from raw rows without calling the Swift metric implementation.

| Method | Correct/all | Classified N | All accuracy | Classified accuracy | Coverage | Five-class macro-F1, all |
|---|---:|---:|---:|---:|---:|---:|
| Metadata | 900/2160 | 960 | 0.416667 | 0.625000 | 0.444444 | 0.435556 |
| Tokens | 1260/2160 | 1020 | 0.583333 | 0.941176 | 0.472222 | 0.680000 |
| Combined | 1140/2160 | 1320 | 0.527778 | 0.681818 | 0.611111 | 0.578182 |

Correct unknown outcomes count toward all-record accuracy but are abstentions for coverage. Classified-only accuracies have denominators 960, 1,020 and 1,320 respectively, and correct counts 600, 960 and 900. These conditional numbers must be read together with coverage. Full six-class and five-class micro/macro, per-class precision/recall/F1, abstention, confusion and selected-subset results are in the generated [tables](../results/tables.md) and CSVs. Zero-denominator metrics are explicitly zero by convention.

| Ranking method | Mean NDCG@3, 8 scenarios | Mean P@3 |
|---|---:|---:|
| Eligible ID baseline | 0.602084 | 0.500000 |
| Metadata profile | 0.800465 | 0.500000 |
| Token profile | 0.846598 | 0.500000 |
| Combined profile | 0.800465 | 0.500000 |

These are measured scores against synthetic ordinal judgments, not engagement, redemption, causal uplift or customer satisfaction. Mean P@3 did not change. Metadata and combined have identical rankings in this small scenario set; it therefore provides no measured evidence of incremental ranking benefit from combined fallback over metadata. Candidate eligibility is all-positive in these quality scenarios, while expiry, missing eligibility and other gate failures are tested separately.

| Transactions | Metadata median ms | Tokens median ms | Combined median ms |
|---:|---:|---:|---:|
| 100 | 0.081209 | 2.928208 | 1.681667 |
| 1,000 | 0.749250 | 29.171584 | 17.340708 |
| 10,000 | 7.303709 | 285.055791 | 165.664666 |

Each cell summarizes nine release trials after two warmups. The region includes scoping, duplicate detection, cancellation/window/currency filtering, classification, profile construction, eligibility/validity filtering, ranking and explanation construction. It excludes generation, JSON/CSV I/O, compile/startup and environment capture. Full min, median, nearest-rank P90, max, mean, sample SD and individual trials are supplied. With nine trials P90 is the maximum. Inputs are nested deterministic synthetic sequences, not representative banking traces. These figures describe this run only; they do not establish an iOS latency budget.

Darwin `getrusage` returned a whole-process high-water resident set size of **55,623,680 bytes** after the experiments. This includes framework initialization, evaluation buffers and output preparation; it is not incremental memory per input or method. No allocation tracing or isolated per-method memory experiment was performed.

### Failure cases and interpretation

The combined method increased coverage relative to both baselines on this corpus, but **did not achieve the best accuracy or macro-F1**. In the deliberately incorrect-metadata slice (360 records, six cases), metadata and combined were wrong on all rows, whereas tokens were correct on all rows. This is a property of this constructed stress slice, not an estimate of real metadata error frequency. The precedence rule has no independent way to validate an asserted category. For identifier-only cases, combined and metadata were correct on 300/300 rows; tokens classified only 60/300 correctly. Thus the method trades resilience to missing descriptions for susceptibility to incorrect metadata.

All methods abstained on the ambiguous and OOV slices. Each slice has 360 rows: five known-category cases and one unknown case. Their 60/360 exact-label correctness reflects correct unknown outcomes; it does not mean successful recognition of the five spending categories. The keyword-trap donation case was incorrectly labeled dining by tokens and combined on 60/60 rows; metadata abstained correctly. Explicit aliases and token boundaries do not establish merchant meaning.

In `needs_diverge_from_spend`, all spending-based methods scored NDCG@3 **0.372626**, below the eligible-ID baseline's **1.000000**. In `wrong_metadata`, combined scored **0.630930**, while tokens and the baseline scored **1.000000**. In `unrecognized_history`, all methods scored **0.500000**, because the profile could not identify transport spending and reverted to the baseline order. The baseline's favorable placement in some cases follows the chosen offer IDs; it is not a universally optimal neutral policy. These examples make a universal-superiority claim untenable.

### Design assumptions, not empirical findings

- Structured categories take precedence over the registry and text. Merchant identifiers and categories are synthetic conveniences, not a validated bank MCC taxonomy.
- A 30-day inclusive lookback and maximum eligibility age strictly below one hour are prototype policies, not empirically optimized parameters or bank requirements.
- Category spend in integer USD cents is a transparent ranking heuristic. Unknown spending cannot personalize; a zero-score eligible list is a neutral fallback.
- Authoritative eligibility is supplied by a trusted caller. This library does not authenticate, contact or validate the provenance of a bank service. It never infers eligibility from spending.
- Transaction IDs are stable within an account; cancellation links are provided; the input contains the relevant cancellation records. Partial refunds cause conservative whole-purchase exclusion. Missing links cannot be recovered reliably.
- Explanations faithfully expose the score's inputs by construction and tests. Their understandability has not been measured with users.

### Hypothetical production recommendations (not implemented or evaluated)

A real integration would need authenticated, versioned eligibility and revocation handling; account-transition and asynchronous-response controls; auditable merchant-category provenance; consent and data minimization; secure storage and transport; complete ledger/reversal reconciliation; and a reviewed policy for conflicts between metadata and text. Revalidating authoritative eligibility at a redemption/action boundary would address a different risk from ranking-time freshness. These suggestions do not assert any current bank's architecture.

Further research should preregister comparison policies and independently label de-identified data under appropriate permissions; separate merchants and time periods between development and evaluation; test multilingual and drift scenarios; evaluate on physical target devices; and conduct accessibility and explanation-comprehension studies. None of those studies was performed here. The supplied [threats-to-validity discussion](threats-to-validity.md) details why synthetic repetitions and eight scenarios cannot establish population performance or statistical confidence.

### Execution evidence and missing evaluations

The first baseline attempt failed because the compiler's default module-cache path was not writable. Redirecting `CLANG_MODULE_CACHE_PATH` to `/tmp` allowed the baseline tests to execute. During expansion, generic names `Category` and `Method` collided with Objective-C runtime types; they were renamed to `SpendingCategory` and `ClassificationMethod`. The first release build failed in sandbox-blocked `dsymutil`; the successful command disabled debug-symbol output with `-debug-info-format none`. Initial and retry logs are retained, not replaced with invented results. The hardware lookup failure remains reported.

Successful experiment command:

```sh
CLANG_MODULE_CACHE_PATH=/tmp/explainable-clang-cache swift run \
  -c release -debug-info-format none --disable-sandbox \
  --scratch-path /tmp/explainable-offers-build offer-experiments \
  --seed 20261119 --count 2160 --output results
```

Console excerpts from actual successful logs:

```text
Executed 19 tests, with 0 failures (0 unexpected) in 0.015 (0.018) seconds
Build complete! (6.35 sec)
Completed benchmark n=100
Completed benchmark n=1000
Completed benchmark n=10000
Completed classification N=2160, ranking scenarios=8, benchmark trials=81.
PASS: independently recomputed classification metrics (6480 predictions), ranking (32 rows), and 81 benchmark trials.
```

The final runner line above omits only its absolute output directory; the full line is preserved in `results/experiments-retry.log`. See README for the exact test and reproduction commands. All requested synthetic evaluation components ran; unperformed evaluations include production/customer validation, iOS/device tests, cross-OS compatibility, independent human labeling, explanation comprehension, significance/confidence analysis and per-method memory profiling. No results are claimed for them.

### Fresh-build reproduction check

The documented `./scripts/reproduce.sh results-reproduced` command completed successfully from a separate build directory: 19 XCTest cases passed, the release runner completed all 81 measured trials, and the independent audit passed. Nine deterministic outputs (dataset, predictions, classification summaries/details/slices/confusion, composition and ranking details/summary) were byte-identical to the original run. `results/reproducibility-check.log` records the comparison; `results-reproduced` preserves the second run, including its separate timings and environment. The tables above report the original run only; trials from the two runs were not pooled.

### Verified API sources

Apple's [NLTokenizer reference](https://developer.apple.com/documentation/naturallanguage/nltokenizer) documents token segmentation and the need to avoid concurrent use of one tokenizer instance. The [word-tokenization example](https://developer.apple.com/documentation/NaturalLanguage/tokenizing-natural-language-text) documents assigning a string and enumerating word ranges. The implementation creates a fresh tokenizer per call. These are API references, not evidence of banking accuracy or a literature review. No other external research citations are asserted.
