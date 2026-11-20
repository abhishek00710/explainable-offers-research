# Measured synthetic experiment tables

Seed: 20261119. Fixed clock: 1800000000. Classification records: 2160. No production data.

## Classification

All-label accuracy includes correct unknown outcomes; classified accuracy excludes predicted unknown. Macro-F1 uses five spending classes.

| Method | N | Classified N | All accuracy | Classified accuracy | Coverage | Abstention | Macro-F1 (all) |
|---|---:|---:|---:|---:|---:|---:|---:|
| metadata | 2160 | 960 | 0.416667 | 0.625000 | 0.444444 | 0.555556 | 0.435556 |
| tokens | 2160 | 1020 | 0.583333 | 0.941176 | 0.472222 | 0.527778 | 0.680000 |
| combined | 2160 | 1320 | 0.527778 | 0.681818 | 0.611111 | 0.388889 | 0.578182 |

## Per-class metrics on all records

| Method | Class | Support | Precision | Recall | F1 |
|---|---|---:|---:|---:|---:|
| metadata | groceries | 360 | 0.500000 | 0.333333 | 0.400000 |
| metadata | dining | 360 | 0.666667 | 0.333333 | 0.444444 |
| metadata | transport | 360 | 0.666667 | 0.333333 | 0.444444 |
| metadata | shopping | 360 | 0.666667 | 0.333333 | 0.444444 |
| metadata | utilities | 360 | 0.666667 | 0.333333 | 0.444444 |
| metadata | unknown | 360 | 0.250000 | 0.833333 | 0.384615 |
| tokens | groceries | 360 | 1.000000 | 0.666667 | 0.800000 |
| tokens | dining | 360 | 0.750000 | 0.500000 | 0.600000 |
| tokens | transport | 360 | 1.000000 | 0.500000 | 0.666667 |
| tokens | shopping | 360 | 1.000000 | 0.500000 | 0.666667 |
| tokens | utilities | 360 | 1.000000 | 0.500000 | 0.666667 |
| tokens | unknown | 360 | 0.263158 | 0.833333 | 0.400000 |
| combined | groceries | 360 | 0.600000 | 0.500000 | 0.545455 |
| combined | dining | 360 | 0.600000 | 0.500000 | 0.545455 |
| combined | transport | 360 | 0.750000 | 0.500000 | 0.600000 |
| combined | shopping | 360 | 0.750000 | 0.500000 | 0.600000 |
| combined | utilities | 360 | 0.750000 | 0.500000 | 0.600000 |
| combined | unknown | 360 | 0.285714 | 0.666667 | 0.400000 |

## Metrics on classified records only

Predicted unknown rows are excluded; zero denominators map to zero.

| Method | Class or summary | Selected N | Support | Precision | Recall | F1 |
|---|---|---:|---:|---:|---:|---:|
| metadata | groceries | 960 | 180 | 0.500000 | 0.666667 | 0.571429 |
| metadata | dining | 960 | 180 | 0.666667 | 0.666667 | 0.666667 |
| metadata | transport | 960 | 180 | 0.666667 | 0.666667 | 0.666667 |
| metadata | shopping | 960 | 180 | 0.666667 | 0.666667 | 0.666667 |
| metadata | utilities | 960 | 180 | 0.666667 | 0.666667 | 0.666667 |
| metadata | unknown | 960 | 60 | 0.000000 | 0.000000 | 0.000000 |
| metadata | micro_six | 960 | 960 | 0.625000 | 0.625000 | 0.625000 |
| metadata | macro_six | 960 | 960 | 0.527778 | 0.555556 | 0.539683 |
| metadata | micro_known | 960 | 900 | 0.625000 | 0.666667 | 0.645161 |
| metadata | macro_known | 960 | 900 | 0.633333 | 0.666667 | 0.647619 |
| tokens | groceries | 1020 | 240 | 1.000000 | 1.000000 | 1.000000 |
| tokens | dining | 1020 | 180 | 0.750000 | 1.000000 | 0.857143 |
| tokens | transport | 1020 | 180 | 1.000000 | 1.000000 | 1.000000 |
| tokens | shopping | 1020 | 180 | 1.000000 | 1.000000 | 1.000000 |
| tokens | utilities | 1020 | 180 | 1.000000 | 1.000000 | 1.000000 |
| tokens | unknown | 1020 | 60 | 0.000000 | 0.000000 | 0.000000 |
| tokens | micro_six | 1020 | 1020 | 0.941176 | 0.941176 | 0.941176 |
| tokens | macro_six | 1020 | 1020 | 0.791667 | 0.833333 | 0.809524 |
| tokens | micro_known | 1020 | 960 | 0.941176 | 1.000000 | 0.969697 |
| tokens | macro_known | 1020 | 960 | 0.950000 | 1.000000 | 0.971429 |
| combined | groceries | 1320 | 240 | 0.600000 | 0.750000 | 0.666667 |
| combined | dining | 1320 | 240 | 0.600000 | 0.750000 | 0.666667 |
| combined | transport | 1320 | 240 | 0.750000 | 0.750000 | 0.750000 |
| combined | shopping | 1320 | 240 | 0.750000 | 0.750000 | 0.750000 |
| combined | utilities | 1320 | 240 | 0.750000 | 0.750000 | 0.750000 |
| combined | unknown | 1320 | 120 | 0.000000 | 0.000000 | 0.000000 |
| combined | micro_six | 1320 | 1320 | 0.681818 | 0.681818 | 0.681818 |
| combined | macro_six | 1320 | 1320 | 0.575000 | 0.625000 | 0.597222 |
| combined | micro_known | 1320 | 1200 | 0.681818 | 0.750000 | 0.714286 |
| combined | macro_known | 1320 | 1200 | 0.690000 | 0.750000 | 0.716667 |

## Classification failure slices

| Method | Condition | N | Accuracy | Coverage |
|---|---|---:|---:|---:|
| metadata | alias_variation | 120 | 0.000000 | 0.000000 |
| metadata | ambiguous | 360 | 0.166667 | 0.000000 |
| metadata | clean | 300 | 1.000000 | 1.000000 |
| metadata | identifier_only | 300 | 1.000000 | 1.000000 |
| metadata | incorrect_metadata | 360 | 0.000000 | 1.000000 |
| metadata | keyword_trap | 60 | 1.000000 | 0.000000 |
| metadata | oov | 360 | 0.166667 | 0.000000 |
| metadata | out_of_scope | 120 | 1.000000 | 0.000000 |
| metadata | punctuation | 180 | 0.000000 | 0.000000 |
| tokens | alias_variation | 120 | 1.000000 | 1.000000 |
| tokens | ambiguous | 360 | 0.166667 | 0.000000 |
| tokens | clean | 300 | 1.000000 | 1.000000 |
| tokens | identifier_only | 300 | 0.200000 | 0.200000 |
| tokens | incorrect_metadata | 360 | 1.000000 | 0.833333 |
| tokens | keyword_trap | 60 | 0.000000 | 1.000000 |
| tokens | oov | 360 | 0.166667 | 0.000000 |
| tokens | out_of_scope | 120 | 1.000000 | 0.000000 |
| tokens | punctuation | 180 | 1.000000 | 1.000000 |
| combined | alias_variation | 120 | 1.000000 | 1.000000 |
| combined | ambiguous | 360 | 0.166667 | 0.000000 |
| combined | clean | 300 | 1.000000 | 1.000000 |
| combined | identifier_only | 300 | 1.000000 | 1.000000 |
| combined | incorrect_metadata | 360 | 0.000000 | 1.000000 |
| combined | keyword_trap | 60 | 0.000000 | 1.000000 |
| combined | oov | 360 | 0.166667 | 0.000000 |
| combined | out_of_scope | 120 | 1.000000 | 0.000000 |
| combined | punctuation | 180 | 1.000000 | 1.000000 |

## Ranking (independent synthetic relevance; k=3)

| Method | Scenarios | Mean NDCG@3 | Mean P@3 |
|---|---:|---:|---:|
| eligible_id | 8 | 0.602084 | 0.500000 |
| metadata | 8 | 0.800465 | 0.500000 |
| tokens | 8 | 0.846598 | 0.500000 |
| combined | 8 | 0.800465 | 0.500000 |

## Ranking by scenario

| Scenario | Method | NDCG@3 | P@3 |
|---|---|---:|---:|
| grocery_need | eligible_id | 1.000000 | 0.666667 |
| commuter | eligible_id | 0.458660 | 0.333333 |
| utility_need | eligible_id | 0.065523 | 0.333333 |
| dining_need | eligible_id | 0.709810 | 0.666667 |
| shopping_need | eligible_id | 0.082681 | 0.333333 |
| needs_diverge_from_spend | eligible_id | 1.000000 | 1.000000 |
| unrecognized_history | eligible_id | 0.500000 | 0.333333 |
| wrong_metadata | eligible_id | 1.000000 | 0.333333 |
| grocery_need | metadata | 1.000000 | 0.666667 |
| commuter | metadata | 1.000000 | 0.666667 |
| utility_need | metadata | 0.917319 | 0.333333 |
| dining_need | metadata | 1.000000 | 0.666667 |
| shopping_need | metadata | 0.982842 | 0.666667 |
| needs_diverge_from_spend | metadata | 0.372626 | 0.333333 |
| unrecognized_history | metadata | 0.500000 | 0.333333 |
| wrong_metadata | metadata | 0.630930 | 0.333333 |
| grocery_need | tokens | 1.000000 | 0.666667 |
| commuter | tokens | 1.000000 | 0.666667 |
| utility_need | tokens | 0.917319 | 0.333333 |
| dining_need | tokens | 1.000000 | 0.666667 |
| shopping_need | tokens | 0.982842 | 0.666667 |
| needs_diverge_from_spend | tokens | 0.372626 | 0.333333 |
| unrecognized_history | tokens | 0.500000 | 0.333333 |
| wrong_metadata | tokens | 1.000000 | 0.333333 |
| grocery_need | combined | 1.000000 | 0.666667 |
| commuter | combined | 1.000000 | 0.666667 |
| utility_need | combined | 0.917319 | 0.333333 |
| dining_need | combined | 1.000000 | 0.666667 |
| shopping_need | combined | 0.982842 | 0.666667 |
| needs_diverge_from_spend | combined | 0.372626 | 0.333333 |
| unrecognized_history | combined | 0.500000 | 0.333333 |
| wrong_metadata | combined | 0.630930 | 0.333333 |

## Release pipeline benchmark

Two warmups per size/method, nine measured trials, nearest-rank percentiles; milliseconds.

| N | Method | Min | Median | P90 | Max | Mean | Sample SD |
|---:|---|---:|---:|---:|---:|---:|---:|
| 100 | metadata | 0.080791 | 0.081209 | 0.088541 | 0.088541 | 0.082866 | 0.002925 |
| 100 | tokens | 2.897625 | 2.928208 | 3.273666 | 3.273666 | 2.969477 | 0.117126 |
| 100 | combined | 1.663833 | 1.681667 | 1.713833 | 1.713833 | 1.686097 | 0.017014 |
| 1000 | metadata | 0.739333 | 0.749250 | 0.795084 | 0.795084 | 0.760986 | 0.021005 |
| 1000 | tokens | 28.519875 | 29.171584 | 42.987458 | 42.987458 | 32.067477 | 5.567302 |
| 1000 | combined | 16.497500 | 17.340708 | 18.257083 | 18.257083 | 17.283884 | 0.662255 |
| 10000 | metadata | 7.022458 | 7.303709 | 7.641916 | 7.641916 | 7.296444 | 0.228581 |
| 10000 | tokens | 279.681750 | 285.055791 | 301.978708 | 301.978708 | 287.476611 | 6.445738 |
| 10000 | combined | 160.370458 | 165.664666 | 176.165958 | 176.165958 | 165.917741 | 4.574323 |
