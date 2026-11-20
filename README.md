# Explainable offer recommendations in mobile banking

A reproducible Swift research artifact supporting **Engineering Explainable Offer Recommendations in Mobile Banking**, a manuscript intended for IEEE Software. This is an independently developed synthetic prototype, not a bank's production implementation. It uses deterministic rules, not a trained AI/ML classifier. No customer engagement, redemption, production benefit, statistical significance or iOS performance is claimed.

**Release status:** prepared for owner review under Apache-2.0; disclosure-rights confirmation and publication approval remain pending. Nothing has been published or pushed. See [publication-readiness report](docs/PUBLICATION_READINESS.md) and [licensing review](docs/THIRD_PARTY.md).

## Research questions

1. How do structured metadata, explicit text rules and combinations trade correctness against coverage and abstention?
2. How sensitive are those tradeoffs to constructed structured-category error rates?
3. When does recent-spending ranking help or hurt relative to an eligible-only list under independently specified synthetic needs?
4. Can authoritative eligibility, account scope and offer validity remain separate from preference heuristics?

## Four classification strategies

| Strategy | Decision |
|---|---|
| Metadata | Recognized structured category, otherwise explicit merchant-ID registry, otherwise unknown |
| Tokens | Apple NLTokenizer plus explicit aliases; no match or cross-category ambiguity abstains |
| Combined | Metadata first; token fallback only when metadata abstains |
| Conflict abstain | Abstain when both channels assert different known categories; otherwise follow combined |

Spending profiles retain unknown amounts and traceable contributions. Duplicate/conflicting IDs, refunds/reversals, account/currency scope and fixed time windows are checked. Offers require explicit, fresh, account-specific authoritative eligibility and current validity. Spending never establishes eligibility. Ranking uses category spending, with deterministic offer-ID ties and neutral fallback. These controls model a trust boundary; no banking service is authenticated or contacted.

## Experiments and findings

The original corpus has 2,160 records generated from 36 authored cases, with seed 20261119 and fixed clock 1800000000. The frozen regression fixture has 72 rows, seed 42. Eight original ranking scenarios and 81 release benchmark trials are retained.

The follow-up intervenes on 600 known-label records with structured categories, at **0, 5, 10, 20, 40, 60, 80 and 100% constructed error**, using allocation seeds **11, 29, 47, 71 and 101**. It preserves labels and metadata missingness. The other 1,560 rows stay fixed, including 60 out-of-scope rows with incorrect metadata, so 0% is not zero error in all metadata. Sixteen new ranking scenarios extend the total to 24; 20 have defined quality and four have no eligible candidates or zero ideal relevance gain.

- On untouched original data, tokens have accuracy **0.583333**, versus combined **0.527778**. Combined covers more rows: **0.611111** versus **0.472222**.
- Across the tested sensitivity allocations, combined retains coverage **0.611111**. It beats tokens on accuracy at tested rates 0–20% but loses at 40–100%. These rates are constructed interventions, not real-world prevalence or deployment thresholds.
- Conflict abstention improves known-class macro-F1 relative to combined at positive rates, with reduced coverage and **no improvement in all-record accuracy** in this corpus. All controlled rows already have correct token predictions—a major limitation.
- In the 12 new scenarios with defined ranking quality, conflict abstention has mean NDCG@3 **0.628090**, below combined **0.711423**. Correct metadata can be rejected because of misleading text. Negative findings are retained.
- Original timing results apply only to the recorded macOS host. No new conflict-policy benchmark or iOS/device measurement was performed.

Labels are independently specified from classifier execution, **not independently or blindly annotated**. The same project author designed cases and rules. Repeated synthetic variants and five allocation seeds do not establish population confidence. Read the reports before interpreting aggregate scores.

## Repository map

| Location | Contents |
|---|---|
| `artifact/Sources`, `artifact/Tests` | Original implementation and 19 XCTest tests |
| `artifact/Fixtures`, `artifact/Sources/SyntheticData/Resources` | Frozen synthetic inputs and original relevance judgments |
| `artifact/results`, `artifact/results-reproduced` | Historical original measurements, CSVs, tables and logs |
| `artifact/Validation` | Additive conflict implementation, 10 tests, protocol, frozen plans, 24 scenarios and follow-up outputs |
| [Original report](artifact/docs/research-report.md) | Original measured results and assumptions |
| [Updated report](artifact/Validation/docs/research-report-updated.md) | Sensitivity conclusions and expanded negative findings |
| [Original tables](artifact/results/tables.md), [updated tables](artifact/Validation/results/tables.md) | Manuscript-ready measured tables |
| [Protocol](artifact/Validation/docs/protocol.md), [dataset methodology](artifact/docs/dataset.md) | Seeds, labels, intervention design and limitations |
| [Architecture](artifact/docs/architecture.md), [threats to validity](artifact/docs/threats-to-validity.md) | Decision contract and Mermaid diagram |
| `scripts` | Public-copy verification, portable reproduction and disclosure scanning |
| `verification` | Sanitized publication-check test/audit evidence |
| `provenance` | Original/public hash mapping, historical manifests and release-integrity manifest |

## Reproduce from a fresh checkout

Requirements: Apple macOS with Xcode command-line tools and Apple Swift 6+, Python 3.9+, Bash. No network or third-party packages are needed. Minimum declared macOS target is 13, but compatibility was tested only on the environment recorded in the logs. Use a writable checkout and sufficient temporary disk space.

From the repository root:

```sh
python3 scripts/verify_release.py
./scripts/reproduce.sh runs/fresh
```

The reproduction script creates a unique empty build/cache directory, runs **19 original and 10 additional XCTest tests**, runs both release experiment suites, independently audits CSV metrics, regenerates follow-up tables, and compares deterministic outputs to the historical CSVs. It writes only beneath the requested new output directory and a temporary build directory; it refuses an existing output directory. Raw logs may contain local user paths and remain in ignored `runs/`; do not publish them without redaction. Benchmarks rerun on the reader's machine and are expected to differ; historical timings are never overwritten.

For a read-only check of the supplied manuscript metrics:

```sh
python3 scripts/check_metrics.py
```

This executes both original metric audits, checks follow-up aggregates, regenerates follow-up manuscript tables in temporary storage, and checks reported scalar metrics and table entries against exported CSV evidence. Version/runtime, test-duration, build-duration and RSS statements are checked against their environment/log evidence rather than misrepresented as classifier CSV metrics.

## Preservation and public-copy redaction

The private source project is unchanged. This repository is a **derived public copy**: personal home-directory and per-user temporary-directory paths in 16 historical logs and one environment command-argument field were replaced by placeholders; numerical outputs and failure evidence were retained. One Finder `.DS_Store` file was excluded from the public copy and retained locally. All Swift/Python experiment source, fixtures, reports, CSV measurements and manuscript tables are byte-identical to the source project. Release-specific hash manifests are refreshed; historical manifests remain under `provenance/historical-manifests`. Historical audit text refers to the original experiments; the public-copy audit baseline refers to the sanitized artifact tree. See [provenance policy](docs/PROVENANCE.md).

## License and citation

Copyright 2026 Abhishek Gang Deb. Original research code, documentation and synthetic datasets owned by the author are licensed under the [Apache License 2.0](LICENSE); see [NOTICE](NOTICE). See [third-party review](docs/THIRD_PARTY.md). Apple SDKs/toolchains are not redistributed or relicensed. No DOI, accepted-publication claim, repository URL or author metadata has been invented. Cite the actual release and manuscript once their bibliographic details are confirmed.
