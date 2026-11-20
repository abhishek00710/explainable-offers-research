# Engineering Explainable Offer Recommendations in Mobile Banking
## Follow-up experimental validation for an intended IEEE Software manuscript

This report adds reproducible synthetic sensitivity and ranking experiments to the original prototype. **The original report, source and experiment outputs are preserved unchanged.** This is not a bank's implementation or a production evaluation. All comparisons concern deterministic rules; NaturalLanguage supplies tokenization, not a trained merchant classifier.

### What was measured, and what was assumed

The original 2,160 labeled rows, 36 authored merchant cases and original eight ranking judgments were reused without changing labels. A new standalone package compiles byte-identical copies of the original OfferCore/Evaluation sources and an additive `ConflictAware` implementation. The original 19 XCTest cases and 10 new XCTest cases executed successfully on macOS. The new release runner produced 354,240 predictions (41 datasets × four methods × 2,160 rows) and 120 ranking rows (24 scenarios × five rankers). The independent Python audit verified all 64 original files unchanged, reproduced original predictions, recomputed all 23,616 confusion cells and 3,936 per-class rows, and checked all 656 metric summaries. The original metric/benchmark audit also passed.

Eight error rates (0, 5, 10, 20, 40, 60, 80, 100%) were constructed at five fixed allocation seeds. The intervention affects 600 records with both a known gold category and structured metadata, stratified at 120 per spending class. At 0% their metadata is set to their gold category; at each higher rate a nested seeded subset is assigned a different known category. Descriptions, amounts, account/transaction identities, gold labels, missingness and the other 1,560 rows do not change. Within a seed, a selected record retains the same wrong category at higher rates. Neither record selection nor wrong-category selection inspects classifier predictions or aliases.

**These percentages are experimental assignments, not estimates of real-world metadata error prevalence.** The original controlled pool has 300/600 incorrect categories (50%) assigned by the original authored cases; it is separate from every randomized sensitivity condition. There are 660 structured-category records overall. Sixty fixed out-of-scope records with incorrect structured metadata remain outside the controlled pool. Therefore the all-structured error fraction is `(60 + 600 × controlledRate)/660`, ranging from 9.09% to 100%; “0%” means zero error in the controlled pool only. Availability and identifier-only behavior remain fixed. These interventions are not corrected historical measurements.

The alternative, `conflict_abstain`, returns unknown when recognized metadata and unambiguous token evidence assert different known categories. Otherwise it follows the combined policy. It cannot determine which channel is correct, cannot veto incorrect metadata without a token assertion, and can accept joint mistakes. The profile adapter retains the original ledger gates, then reclassifies only admitted contributions. It makes no new timing claim.

### Sensitivity results

Selected all-record results below are means over five assignment seeds; every rate and seed, classified-only results, known-label results, and controlled-pool results are supplied in the [manuscript tables](../results/tables.md) and CSVs. No statistical confidence or significance is claimed.

| Controlled error | Method | All-record accuracy (N=2160) | Coverage | Five-class macro-F1 |
|---:|---|---:|---:|---:|
| 0% | metadata | 0.555556 | 0.444444 | 0.653333 |
| 0% | tokens | 0.583333 | 0.472222 | 0.680000 |
| 0% | combined | 0.666667 | 0.611111 | 0.770909 |
| 0% | conflict abstain | 0.666667 | 0.611111 | 0.770909 |
| 20% | combined | 0.611111 | 0.611111 | 0.693973 |
| 20% | conflict abstain | 0.611111 | 0.555556 | 0.721698 |
| 40% | combined | 0.555556 | 0.611111 | 0.616941 |
| 40% | conflict abstain | 0.555556 | 0.500000 | 0.668372 |
| 100% | metadata | 0.277778 | 0.444444 | 0.217912 |
| 100% | tokens | 0.583333 | 0.472222 | 0.680000 |
| 100% | combined | 0.388889 | 0.611111 | 0.385728 |
| 100% | conflict abstain | 0.388889 | 0.333333 | 0.477778 |

Token-only predictions were identical at every rate and seed, as expected because only structured metadata changes. Combined retains coverage 0.611111 throughout, while its all-record accuracy decreases from 0.666667 to 0.388889. Its accuracy and known macro-F1 exceed tokens at tested rates 0–20%, and fall below tokens at tested rates 40–100%, for all five seeds. The experiment brackets a change in ordering between tested rates; it does not establish a transferable operating threshold.

Conflict abstention has **the same all-record accuracy as combined at every tested rate**, while reducing coverage at every positive rate. Its five-class macro-F1 exceeds combined at every positive rate in every seed. At 100%, for example, macro-F1 is 0.477778 versus combined's mean 0.385728, but coverage falls to 0.333333 versus 0.611111. Classified-only accuracy rises relative to combined (0.833333 on 720 classified rows versus 0.454545 on 1,320 at 100%), not all-record accuracy. Thus “improvement” depends on which rejection/correctness tradeoff is valued.

This equality in accuracy has a specific structural explanation: **all 600 controlled rows already have correct token predictions in the original corpus**. When their metadata becomes wrong, conflict rejection converts a wrong known label into unknown; both are incorrect relative to a known gold label. Rejection removes false positives but leaves false negatives and reduces coverage. This intervention does not test correct-metadata/incorrect-token conflicts or undetectable errors within the controlled pool; those failures are included in the new ranking scenarios instead. This alignment is a dataset limitation, not evidence that token cues generally validate structured metadata.

Five-seed ranges are narrow under this stratification. At 40%, combined's known macro-F1 ranges from 0.616673 to 0.617280, whereas conflict's value is 0.668372 in all seeds. Equal per-class corruption counts and uniform within-pool token correctness largely determine these patterns; they must not be interpreted as precise real-world uncertainty bounds. The repeated rows are variants of a small case catalog, not independently sampled merchants.

On the **untouched original dataset**, conflict abstention has accuracy 0.527778, coverage 0.472222 and known macro-F1 0.640000. Original combined has the same accuracy, higher coverage 0.611111 and lower macro-F1 0.578182. Original tokens still lead both on accuracy (0.583333) and macro-F1 (0.680000). This new comparison does not revise any original value.

### Expanded ranking results and counterexamples

Sixteen additional scenarios were authored and frozen before outcome inspection, with stated needs, explicit ordinal relevance judgments and expected eligible candidate IDs. They cover empty/single-purchase histories, changing preferences, old transactions outside the window, wrong metadata, misleading tokens, jointly wrong channels, missing/stale/wrong-account eligibility, denied/missing/unknown decisions, offer validity/currency and a no-relevant-candidate condition. New `historyTruth` fields document imagined merchant purpose; neither the ranker nor the classifier uses those fields. Original judgments are identical to the original file.

All **120/120 candidate-set checks passed**. Three new scenarios have no eligible candidates, and one has no positive relevance among eligible candidates. Quality is NA for these four scenarios, excluded from ranking means with explicit counts. These are not treated as perfect recommendations or zero-quality failures. Twelve new scenarios and eight original scenarios have defined quality, for a pooled denominator of 20. The ideal ranking uses the independently authored eligible set; it is not restricted to whatever the ranker happened to return.

| Method | Original 8: mean NDCG@3 | New 12 defined: mean NDCG@3 | Pooled 20: mean NDCG@3 | Pooled mean P@3 |
|---|---:|---:|---:|---:|
| Eligible ID baseline | 0.602084 | 0.611728 | 0.607871 | 0.416667 |
| Metadata | 0.800465 | 0.669756 | 0.722040 | 0.416667 |
| Tokens | 0.846598 | 0.711423 | 0.765493 | 0.416667 |
| Combined | 0.800465 | 0.711423 | 0.747040 | 0.416667 |
| Conflict abstain | 0.846598 | 0.628090 | 0.715493 | 0.400000 |

Conflict abstention helps on the original `wrong_metadata` scenario: NDCG@3 rises from combined's 0.630930 to 1.000000. That gain comes from falling back to an ID order favorable to the grocery judgment, not recovering the correct category. In the new `wrong_metadata_transit` scenario, abstention remains at 0.500000, while tokens achieve 1.000000. The neutral ID ordering is not invariably helpful.

The new `correct_metadata_bad_token` case is a fictional appliance shop called Coffee Warehouse. Correct shopping metadata conflicts with the dining cue. Combined scores 1.000000, but conflict abstention scores **0.000000**, discarding the only useful evidence. In `wrong_metadata_no_tokens`, the token channel cannot identify a transit merchant; combined and conflict score **0.000000**, while the neutral baseline and tokens score 0.500000. In `jointly_wrong`, both channels agree on dining for a donation, so conflict rejection does not activate; all personalized methods score 0.630930 versus the baseline's 1.000000.

Sparse history also remains hazardous: one exceptional apparel purchase in `sparse_misleading` produces NDCG@3 **0.644287** for every personalized method versus **1.000000** for the eligible-ID baseline. Preference-change scenarios show that a 30-day unweighted total does not directly represent present needs: all personalized policies score 0.630930 in both new change scenarios, below an ideal 1.000000. Eligibility filtering passes independently of these relevance failures.

Consequently the conflict alternative's original-eight ranking improvement reverses in the added cohort: mean NDCG@3 is 0.628090 versus combined's 0.711423. Its pooled P@3 is also lower. No labels were adjusted to make an alternative win. Scenario means depend on the authored mix and chosen tie-breaking IDs; they are not population effect estimates.

### Audit of metrics and label provenance

The independent Python auditor reconstructs a six-by-six confusion matrix from raw predictions for each experiment/method/subset, including zero cells. Row totals equal class supports; the trace divided by selected N is accuracy. Per-class TP is the diagonal, FP is the remaining prediction column, FN is the remaining truth row. Six-class micro-F1 equals accuracy in this single-label setting. Known-class micro counts known→unknown as FN and unknown→known as FP while omitting unknown as a target class.

Macro-F1 is the arithmetic mean of five spending-class F1 scores (or six when explicitly named). It is not the harmonic mean of averaged precision/recall. Per-class metrics with zero denominators are zero by stated convention. All-record accuracy includes correctly rejected unknown gold rows; coverage excludes all unknown predictions. Classified-only metrics use their own variable N and cannot replace all-record evaluation. Raw counts, denominators and separate all/known/controlled/classified scopes are exported. The tests include a hand-calculated confusion example, macro and micro definitions, and an independent ideal-order ranking example.

Original gold labels are literal catalog values and the audit verifies every row matches its case. The intervention generator changes only the observed structured-category channel and uses gold to ensure substitutions are wrong; it never calls the classifier. Ranking grades are explicit statements of synthetic needs, not functions of scores or token rules. **Independence here is procedural, not independent authorship, blind annotation or external validation.** The same project author designed rules, cases and relevance scenarios. This construct-validity limitation remains, despite immutable labels and classifier-free generation. There is no trained model, held-out merchant evaluation or generalization claim.

### Stable and assumption-dependent conclusions

Stable across these tested allocations:

- Metadata-first fallback increases coverage relative to metadata-only and token-only; combined exceeds metadata accuracy and known macro-F1 throughout this particular intervention because its fallback cases remain fixed.
- Token-only output is invariant to metadata corruption. This is an architectural property confirmed by measurements, not robustness to text corruption.
- Conflict rejection trades coverage for better known-class macro-F1 and conditional accuracy relative to combined at positive corruption rates in this pool; it does not improve all-record accuracy.
- Missing, stale and wrong-account eligibility cannot be replaced by spending inference; candidate sets satisfy all newly authored eligibility/validity cases. Ranking relevance can still be poor.
- None of the measured comparisons establishes universal superiority, human comprehension, customer engagement, redemption or production benefit.

Dependent on synthetic assumptions:

- Which classifier has the best accuracy/macro-F1 depends on the assigned metadata error rate; the original token advantage is not stable at low constructed rates.
- The benefits of conflict rejection depend on token reliability, correlated errors, metadata availability, out-of-scope prevalence and rejection cost. Uniformly correct token evidence in the controlled pool favors rejection's precision tradeoff; new ranking counterexamples demonstrate the opposite case.
- The neutral ID baseline and fallback outcomes depend on ID ordering; scenario weighting changes aggregate ranking conclusions. Conflict helps the original cohort but worsens the new cohort and pooled mean relative to combined.
- Five seeds vary allocations within repeated case templates; they do not measure uncertainty over banks, countries, languages, customers or new merchants. No significance tests, confidence intervals or causal effects are reported.

### Runtime limits and unperformed work

New tests and experiments ran on the recorded macOS 27.2.1 / Apple Swift 6.4.2 / arm64 host. Exact version logs and UTC run time are in the new results directory. **No new latency benchmark was performed for the conflict alternative.** The original release timings and 81 trials remain unchanged, audited and limited to the original measured macOS environment. The adapter repeats some classification work to preserve the original profile gate; it is not an optimized production path. No iOS/device, network/service, production throughput, power or comparative memory conclusion is drawn.

The original threats to validity still apply. Further research would need independently annotated data, separately sourced merchant cases, non-English/temporal drift evaluation, metadata/text error correlation studies, alternative corruption mechanisms, explicit rejection costs, an independently justified neutral ordering, target-device measurements and human explanation studies. These are future recommendations, not completed measurements.

### Reproduction and evidence

From `ExplainableOffers/Validation`, run `./scripts/reproduce.sh results-reproduced`. Inputs and protocol are frozen under `inputs/` and `docs/protocol.md`; code, raw CSVs, generated tables and audits are included. Original files are protected by `inputs/original-sha256.json` and checked on every audit. New artifact hashes are in `sha256-manifest.json`.

Actual console evidence:

```text
Executed 19 tests, with 0 failures (0 unexpected)
Executed 10 tests, with 0 failures (0 unexpected)
Completed 41 datasets × 4 methods; 24 scenarios × 5 rankers. No new timing claims.
PASS: preserved all 64 original files; baseline module copies are byte-identical.
PASS: 354240 raw predictions; 656 scope summaries; all 23616 confusion cells and 3936 per-class rows independently recomputed. Original predictions reproduced; token predictions invariant to intervention.
```

Test excerpts omit only timing suffixes; complete console output is retained in the test logs. All requested follow-up synthetic evaluations executed successfully. No Apple framework execution is inferred from a build alone: native tokenizer assertions ran in XCTest on macOS.

The documented reproduction command also completed end to end. Nine deterministic output files, including all predictions, summary/detail metrics, ranking and manuscript tables, were byte-identical across the two executions. Input plans and ranking scenarios regenerated separately in `/tmp` were byte-identical to their frozen inputs. Environment and console timing records were excluded from byte-equality checks. See `results/reproducibility-check.log` and `results-reproduced/`; the reported values are from `results/`, not pooled executions.
