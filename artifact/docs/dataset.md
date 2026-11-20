# Dataset schema, provenance and methodology

All names, account IDs, amounts, transactions, offers, and relevance grades were authored for this prototype. No bank dataset, customer record, real account, scraped transaction feed or confidential data was used. The artifacts were constructed during this coding session, not independently annotated by a separate research team.

## Inputs and labels

`Sources/SyntheticData/Resources/catalog.json` freezes 36 fictional cases: six for each of groceries, dining, transport, shopping, utilities and unknown/out-of-scope. Each has literal `caseID`, `label`, `description`, optional `merchantID`, optional `structuredCategory`, and `condition`. The label describes the imagined merchant's business purpose. It is stored separately from supplied metadata, and incorrect-metadata cases deliberately disagree. Unknown is the gold label for out-of-scope activity (e.g., transfers, donations or clinic payments), not an unannotated record.

Labels are copied from this authored catalog; no rule evaluation, tokenizer, registry lookup or classifier call generates or repairs them. This is procedural independence from the rule implementation, **not** blinded annotation or independent authorship. Explicit examples and rules were designed by the same author, so overlap and construct bias remain. There is no training, tuning, train/test split, or held-out generalization claim. Frozen fixtures are regression evidence, not an independent accuracy sample.

The default evaluation uses 2,160 rows: 60 observations per catalog case and 360 per class. Cases cycle in catalog order; variation does not create new merchant identities. Five spending classes each have clean, identifier-only, incorrect-metadata, ambiguous, OOV and alias/punctuation cases. The unknown class has two out-of-scope cases, one OOV, one ambiguous, one keyword trap and one incorrect-metadata case. Exact counts are exported in `composition.csv`.

SplitMix64, with explicit wrapping UInt64 arithmetic, supplies four draws per row: payment prefix (none, POS, CARD PURCHASE, PAYPAL, SQ or DEBIT), integer amount 100–20,099 USD cents, age 0–2,505,599 seconds, and whether to add a numeric suffix. The seed defaults to 20261119. IDs are `s<seed>-<index>` within account A. The fixed epoch clock is 1,800,000,000 seconds. All evaluation rows are posted positive debits inside the 30-day window. The frozen regression file has 72 rows and seed 42, two per case; ordinary reproduction does not rewrite it. Status, refund, duplicate, account and validity edge cases belong to hand-written unit tests, not classification frequency estimates.

## JSON schemas (field contract)

| Object | Fields and semantics |
|---|---|
| LabeledTransaction | `transaction` object, `label` enum, `caseID` string, `condition` string |
| Transaction | `id`, `accountID` strings; `timestamp` Int64 epoch seconds; `amountCents` Int64 signed minor units; `currency` ISO-style string; `description` string; optional `merchantID` string; optional `structuredCategory` enum; `status` posted/pending/refunded/reversed; optional `reversesID` account-local original ID |
| SpendingCategory | groceries/dining/transport/shopping/utilities/unknown |
| Offer | `id`, `currency` strings; `category` enum; `validFrom`, `validUntil` Int64 epoch seconds, end exclusive |
| EligibilitySnapshot | `accountID`; `issuedAt`, `expiresAt` Int64 epoch seconds; `decisions` map offer ID → eligible/ineligible/unknown |
| RankingScenario | `id`; `transactions` array; `offers` array; `decisions` map; `judgments` map offer ID → ordinal relevance 0–3 |

Optional fields may be absent or null on input; Swift's JSON encoder omits nil. The model does not normalize currencies or convert exchange rates. It is a USD synthetic experiment, not a general monetary library. Invalid enum values fail JSON decoding.

## Ranking judgments

`ranking.json` freezes eight authored needs scenarios with five candidate offers each. Grades are explicit: 0 irrelevant, 1 weakly relevant, 2 relevant, 3 strongly relevant. Five scenarios align declared need with a major spending category. One has utility/shopping history but grocery/dining need, one has unrecognized transport history, and one has grocery history with incorrect utility metadata. Grades were written directly from these stated needs; the scorer and spending proportions do not generate them. This tests behavior against constructed relevance, not a validated preference instrument. All five offers are eligible and currently valid in these ranking-quality cases; rejection behavior is tested separately in XCTest.

## Limits

There are only 36 unique merchant cases and eight ranking personas. Repeated prefixes and amounts are correlated replicas; do not describe 2,160 rows as 2,160 independent merchants or bootstrap them as independent evidence. The corpus is balanced and adversarial by construction, not prevalence-weighted. It covers English-oriented tokens, a diacritic, punctuation, two spelling aliases, and small OOV examples; it does not establish multilingual, arbitrary typo, MCC hierarchy, temporal-drift or unseen-market performance. Future evaluation needs separately sourced, consented/de-identified and independently annotated data; that is not part of these measured results.
