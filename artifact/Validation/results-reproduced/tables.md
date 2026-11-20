# Follow-up manuscript tables

New validation experiments only. Original artifacts remain unchanged. Rates are constructed, not observed prevalence. Seed ranges are descriptive minima/maxima, not confidence intervals.

## Original dataset with added conflict policy

| Method | N | Correct | Classified N | Accuracy | Coverage | Known macro-F1 |
|---|---:|---:|---:|---:|---:|---:|
| metadata | 2160 | 900 | 960 | 0.416666667 | 0.444444444 | 0.435555556 |
| tokens | 2160 | 1260 | 1020 | 0.583333333 | 0.472222222 | 0.680000000 |
| combined | 2160 | 1140 | 1320 | 0.527777778 | 0.611111111 | 0.578181818 |
| conflict_abstain | 2160 | 1140 | 1020 | 0.527777778 | 0.472222222 | 0.640000000 |

## Sensitivity: all

Mean across five assignment seeds; brackets are min–max. Accuracy/coverage denominators are this selected scope. See CSV for six-class/micro metrics and all seed-level counts.

| Controlled error % | Method | Selected N | Accuracy | Coverage | Known macro-F1 |
|---:|---|---:|---:|---:|---:|
| 0 | metadata | 2160 | 0.555556 [0.555556, 0.555556] | 0.444444 [0.444444, 0.444444] | 0.653333 [0.653333, 0.653333] |
| 0 | tokens | 2160 | 0.583333 [0.583333, 0.583333] | 0.472222 [0.472222, 0.472222] | 0.680000 [0.680000, 0.680000] |
| 0 | combined | 2160 | 0.666667 [0.666667, 0.666667] | 0.611111 [0.611111, 0.611111] | 0.770909 [0.770909, 0.770909] |
| 0 | conflict_abstain | 2160 | 0.666667 [0.666667, 0.666667] | 0.611111 [0.611111, 0.611111] | 0.770909 [0.770909, 0.770909] |
| 5 | metadata | 2160 | 0.541667 [0.541667, 0.541667] | 0.444444 [0.444444, 0.444444] | 0.631589 [0.631522, 0.631696] |
| 5 | tokens | 2160 | 0.583333 [0.583333, 0.583333] | 0.472222 [0.472222, 0.472222] | 0.680000 [0.680000, 0.680000] |
| 5 | combined | 2160 | 0.652778 [0.652778, 0.652778] | 0.611111 [0.611111, 0.611111] | 0.751633 [0.751467, 0.751731] |
| 5 | conflict_abstain | 2160 | 0.652778 [0.652778, 0.652778] | 0.597222 [0.597222, 0.597222] | 0.758966 [0.758966, 0.758966] |
| 10 | metadata | 2160 | 0.527778 [0.527778, 0.527778] | 0.444444 [0.444444, 0.444444] | 0.609827 [0.609676, 0.609981] |
| 10 | tokens | 2160 | 0.583333 [0.583333, 0.583333] | 0.472222 [0.472222, 0.472222] | 0.680000 [0.680000, 0.680000] |
| 10 | combined | 2160 | 0.638889 [0.638889, 0.638889] | 0.611111 [0.611111, 0.611111] | 0.732351 [0.732128, 0.732501] |
| 10 | conflict_abstain | 2160 | 0.638889 [0.638889, 0.638889] | 0.583333 [0.583333, 0.583333] | 0.746788 [0.746788, 0.746788] |
| 20 | metadata | 2160 | 0.500000 [0.500000, 0.500000] | 0.444444 [0.444444, 0.444444] | 0.566359 [0.566189, 0.566685] |
| 20 | tokens | 2160 | 0.583333 [0.583333, 0.583333] | 0.472222 [0.472222, 0.472222] | 0.680000 [0.680000, 0.680000] |
| 20 | combined | 2160 | 0.611111 [0.611111, 0.611111] | 0.611111 [0.611111, 0.611111] | 0.693973 [0.693750, 0.694170] |
| 20 | conflict_abstain | 2160 | 0.611111 [0.611111, 0.611111] | 0.555556 [0.555556, 0.555556] | 0.721698 [0.721698, 0.721698] |
| 40 | metadata | 2160 | 0.444444 [0.444444, 0.444444] | 0.444444 [0.444444, 0.444444] | 0.479307 [0.479118, 0.479769] |
| 40 | tokens | 2160 | 0.583333 [0.583333, 0.583333] | 0.472222 [0.472222, 0.472222] | 0.680000 [0.680000, 0.680000] |
| 40 | combined | 2160 | 0.555556 [0.555556, 0.555556] | 0.611111 [0.611111, 0.611111] | 0.616941 [0.616673, 0.617280] |
| 40 | conflict_abstain | 2160 | 0.555556 [0.555556, 0.555556] | 0.500000 [0.500000, 0.500000] | 0.668372 [0.668372, 0.668372] |
| 60 | metadata | 2160 | 0.388889 [0.388889, 0.388889] | 0.444444 [0.444444, 0.444444] | 0.392257 [0.392039, 0.392789] |
| 60 | tokens | 2160 | 0.583333 [0.583333, 0.583333] | 0.472222 [0.472222, 0.472222] | 0.680000 [0.680000, 0.680000] |
| 60 | combined | 2160 | 0.500000 [0.500000, 0.500000] | 0.611111 [0.611111, 0.611111] | 0.540004 [0.539731, 0.540441] |
| 60 | conflict_abstain | 2160 | 0.500000 [0.500000, 0.500000] | 0.444444 [0.444444, 0.444444] | 0.610390 [0.610390, 0.610390] |
| 80 | metadata | 2160 | 0.333333 [0.333333, 0.333333] | 0.444444 [0.444444, 0.444444] | 0.305094 [0.304885, 0.305442] |
| 80 | tokens | 2160 | 0.583333 [0.583333, 0.583333] | 0.472222 [0.472222, 0.472222] | 0.680000 [0.680000, 0.680000] |
| 80 | combined | 2160 | 0.444444 [0.444444, 0.444444] | 0.611111 [0.611111, 0.611111] | 0.462934 [0.462552, 0.463430] |
| 80 | conflict_abstain | 2160 | 0.444444 [0.444444, 0.444444] | 0.388889 [0.388889, 0.388889] | 0.547112 [0.547112, 0.547112] |
| 100 | metadata | 2160 | 0.277778 [0.277778, 0.277778] | 0.444444 [0.444444, 0.444444] | 0.217912 [0.217748, 0.218178] |
| 100 | tokens | 2160 | 0.583333 [0.583333, 0.583333] | 0.472222 [0.472222, 0.472222] | 0.680000 [0.680000, 0.680000] |
| 100 | combined | 2160 | 0.388889 [0.388889, 0.388889] | 0.611111 [0.611111, 0.611111] | 0.385728 [0.385438, 0.386195] |
| 100 | conflict_abstain | 2160 | 0.388889 [0.388889, 0.388889] | 0.333333 [0.333333, 0.333333] | 0.477778 [0.477778, 0.477778] |

## Sensitivity: known_truth

Mean across five assignment seeds; brackets are min–max. Accuracy/coverage denominators are this selected scope. See CSV for six-class/micro metrics and all seed-level counts.

| Controlled error % | Method | Selected N | Accuracy | Coverage | Known macro-F1 |
|---:|---|---:|---:|---:|---:|
| 0 | metadata | 1800 | 0.500000 [0.500000, 0.500000] | 0.500000 [0.500000, 0.500000] | 0.666667 [0.666667, 0.666667] |
| 0 | tokens | 1800 | 0.533333 [0.533333, 0.533333] | 0.533333 [0.533333, 0.533333] | 0.693333 [0.693333, 0.693333] |
| 0 | combined | 1800 | 0.666667 [0.666667, 0.666667] | 0.666667 [0.666667, 0.666667] | 0.800000 [0.800000, 0.800000] |
| 0 | conflict_abstain | 1800 | 0.666667 [0.666667, 0.666667] | 0.666667 [0.666667, 0.666667] | 0.800000 [0.800000, 0.800000] |
| 5 | metadata | 1800 | 0.483333 [0.483333, 0.483333] | 0.500000 [0.500000, 0.500000] | 0.644451 [0.644447, 0.644457] |
| 5 | tokens | 1800 | 0.533333 [0.533333, 0.533333] | 0.533333 [0.533333, 0.533333] | 0.693333 [0.693333, 0.693333] |
| 5 | combined | 1800 | 0.650000 [0.650000, 0.650000] | 0.666667 [0.666667, 0.666667] | 0.780006 [0.780003, 0.780012] |
| 5 | conflict_abstain | 1800 | 0.650000 [0.650000, 0.650000] | 0.650000 [0.650000, 0.650000] | 0.787879 [0.787879, 0.787879] |
| 10 | metadata | 1800 | 0.466667 [0.466667, 0.466667] | 0.500000 [0.500000, 0.500000] | 0.622238 [0.622226, 0.622253] |
| 10 | tokens | 1800 | 0.533333 [0.533333, 0.533333] | 0.533333 [0.533333, 0.533333] | 0.693333 [0.693333, 0.693333] |
| 10 | combined | 1800 | 0.633333 [0.633333, 0.633333] | 0.666667 [0.666667, 0.666667] | 0.760015 [0.760004, 0.760030] |
| 10 | conflict_abstain | 1800 | 0.633333 [0.633333, 0.633333] | 0.633333 [0.633333, 0.633333] | 0.775510 [0.775510, 0.775510] |
| 20 | metadata | 1800 | 0.433333 [0.433333, 0.433333] | 0.500000 [0.500000, 0.500000] | 0.577803 [0.577786, 0.577845] |
| 20 | tokens | 1800 | 0.533333 [0.533333, 0.533333] | 0.533333 [0.533333, 0.533333] | 0.693333 [0.693333, 0.693333] |
| 20 | combined | 1800 | 0.600000 [0.600000, 0.600000] | 0.666667 [0.666667, 0.666667] | 0.720026 [0.720008, 0.720068] |
| 20 | conflict_abstain | 1800 | 0.600000 [0.600000, 0.600000] | 0.600000 [0.600000, 0.600000] | 0.750000 [0.750000, 0.750000] |
| 40 | metadata | 1800 | 0.366667 [0.366667, 0.366667] | 0.500000 [0.500000, 0.500000] | 0.488945 [0.488896, 0.489019] |
| 40 | tokens | 1800 | 0.533333 [0.533333, 0.533333] | 0.533333 [0.533333, 0.533333] | 0.693333 [0.693333, 0.693333] |
| 40 | combined | 1800 | 0.533333 [0.533333, 0.533333] | 0.666667 [0.666667, 0.666667] | 0.640060 [0.640007, 0.640138] |
| 40 | conflict_abstain | 1800 | 0.533333 [0.533333, 0.533333] | 0.533333 [0.533333, 0.533333] | 0.695652 [0.695652, 0.695652] |
| 60 | metadata | 1800 | 0.300000 [0.300000, 0.300000] | 0.500000 [0.500000, 0.500000] | 0.400095 [0.400011, 0.400204] |
| 60 | tokens | 1800 | 0.533333 [0.533333, 0.533333] | 0.533333 [0.533333, 0.533333] | 0.693333 [0.693333, 0.693333] |
| 60 | combined | 1800 | 0.466667 [0.466667, 0.466667] | 0.666667 [0.666667, 0.666667] | 0.560108 [0.560012, 0.560231] |
| 60 | conflict_abstain | 1800 | 0.466667 [0.466667, 0.466667] | 0.466667 [0.466667, 0.466667] | 0.636364 [0.636364, 0.636364] |
| 80 | metadata | 1800 | 0.233333 [0.233333, 0.233333] | 0.500000 [0.500000, 0.500000] | 0.311195 [0.311129, 0.311265] |
| 80 | tokens | 1800 | 0.533333 [0.533333, 0.533333] | 0.533333 [0.533333, 0.533333] | 0.693333 [0.693333, 0.693333] |
| 80 | combined | 1800 | 0.400000 [0.400000, 0.400000] | 0.666667 [0.666667, 0.666667] | 0.480105 [0.480023, 0.480193] |
| 80 | conflict_abstain | 1800 | 0.400000 [0.400000, 0.400000] | 0.400000 [0.400000, 0.400000] | 0.571429 [0.571429, 0.571429] |
| 100 | metadata | 1800 | 0.166667 [0.166667, 0.166667] | 0.500000 [0.500000, 0.500000] | 0.222285 [0.222240, 0.222356] |
| 100 | tokens | 1800 | 0.533333 [0.533333, 0.533333] | 0.533333 [0.533333, 0.533333] | 0.693333 [0.693333, 0.693333] |
| 100 | combined | 1800 | 0.333333 [0.333333, 0.333333] | 0.666667 [0.666667, 0.666667] | 0.400092 [0.400026, 0.400195] |
| 100 | conflict_abstain | 1800 | 0.333333 [0.333333, 0.333333] | 0.333333 [0.333333, 0.333333] | 0.500000 [0.500000, 0.500000] |

## Sensitivity: controlled

Mean across five assignment seeds; brackets are min–max. Accuracy/coverage denominators are this selected scope. See CSV for six-class/micro metrics and all seed-level counts.

| Controlled error % | Method | Selected N | Accuracy | Coverage | Known macro-F1 |
|---:|---|---:|---:|---:|---:|
| 0 | metadata | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 0 | tokens | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 0 | combined | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 0 | conflict_abstain | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 5 | metadata | 600 | 0.950000 [0.950000, 0.950000] | 1.000000 [1.000000, 1.000000] | 0.950049 [0.950020, 0.950092] |
| 5 | tokens | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 5 | combined | 600 | 0.950000 [0.950000, 0.950000] | 1.000000 [1.000000, 1.000000] | 0.950049 [0.950020, 0.950092] |
| 5 | conflict_abstain | 600 | 0.950000 [0.950000, 0.950000] | 0.950000 [0.950000, 0.950000] | 0.974359 [0.974359, 0.974359] |
| 10 | metadata | 600 | 0.900000 [0.900000, 0.900000] | 1.000000 [1.000000, 1.000000] | 0.900113 [0.900031, 0.900221] |
| 10 | tokens | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 10 | combined | 600 | 0.900000 [0.900000, 0.900000] | 1.000000 [1.000000, 1.000000] | 0.900113 [0.900031, 0.900221] |
| 10 | conflict_abstain | 600 | 0.900000 [0.900000, 0.900000] | 0.900000 [0.900000, 0.900000] | 0.947368 [0.947368, 0.947368] |
| 20 | metadata | 600 | 0.800000 [0.800000, 0.800000] | 1.000000 [1.000000, 1.000000] | 0.800176 [0.800055, 0.800466] |
| 20 | tokens | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 20 | combined | 600 | 0.800000 [0.800000, 0.800000] | 1.000000 [1.000000, 1.000000] | 0.800176 [0.800055, 0.800466] |
| 20 | conflict_abstain | 600 | 0.800000 [0.800000, 0.800000] | 0.800000 [0.800000, 0.800000] | 0.888889 [0.888889, 0.888889] |
| 40 | metadata | 600 | 0.600000 [0.600000, 0.600000] | 1.000000 [1.000000, 1.000000] | 0.600349 [0.600042, 0.600794] |
| 40 | tokens | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 40 | combined | 600 | 0.600000 [0.600000, 0.600000] | 1.000000 [1.000000, 1.000000] | 0.600349 [0.600042, 0.600794] |
| 40 | conflict_abstain | 600 | 0.600000 [0.600000, 0.600000] | 0.600000 [0.600000, 0.600000] | 0.750000 [0.750000, 0.750000] |
| 60 | metadata | 600 | 0.400000 [0.400000, 0.400000] | 1.000000 [1.000000, 1.000000] | 0.400476 [0.400056, 0.401016] |
| 60 | tokens | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 60 | combined | 600 | 0.400000 [0.400000, 0.400000] | 1.000000 [1.000000, 1.000000] | 0.400476 [0.400056, 0.401016] |
| 60 | conflict_abstain | 600 | 0.400000 [0.400000, 0.400000] | 0.400000 [0.400000, 0.400000] | 0.571429 [0.571429, 0.571429] |
| 80 | metadata | 600 | 0.200000 [0.200000, 0.200000] | 1.000000 [1.000000, 1.000000] | 0.200268 [0.200059, 0.200492] |
| 80 | tokens | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 80 | combined | 600 | 0.200000 [0.200000, 0.200000] | 1.000000 [1.000000, 1.000000] | 0.200268 [0.200059, 0.200492] |
| 80 | conflict_abstain | 600 | 0.200000 [0.200000, 0.200000] | 0.200000 [0.200000, 0.200000] | 0.333333 [0.333333, 0.333333] |
| 100 | metadata | 600 | 0.000000 [0.000000, 0.000000] | 1.000000 [1.000000, 1.000000] | 0.000000 [0.000000, 0.000000] |
| 100 | tokens | 600 | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] | 1.000000 [1.000000, 1.000000] |
| 100 | combined | 600 | 0.000000 [0.000000, 0.000000] | 1.000000 [1.000000, 1.000000] | 0.000000 [0.000000, 0.000000] |
| 100 | conflict_abstain | 600 | 0.000000 [0.000000, 0.000000] | 0.000000 [0.000000, 0.000000] | 0.000000 [0.000000, 0.000000] |

## Sensitivity: classified

Mean across five assignment seeds; brackets are min–max. Accuracy/coverage denominators are this selected scope. See CSV for six-class/micro metrics and all seed-level counts.

| Controlled error % | Method | Selected N | Accuracy | Coverage | Known macro-F1 |
|---:|---|---:|---:|---:|---:|
| 0 | metadata | 960 | 0.937500 [0.937500, 0.937500] | 1.000000 [1.000000, 1.000000] | 0.971429 [0.971429, 0.971429] |
| 0 | tokens | 1020 | 0.941176 [0.941176, 0.941176] | 1.000000 [1.000000, 1.000000] | 0.971429 [0.971429, 0.971429] |
| 0 | combined | 1320 | 0.909091 [0.909091, 0.909091] | 1.000000 [1.000000, 1.000000] | 0.955556 [0.955556, 0.955556] |
| 0 | conflict_abstain | 1320 | 0.909091 [0.909091, 0.909091] | 1.000000 [1.000000, 1.000000] | 0.955556 [0.955556, 0.955556] |
| 5 | metadata | 960 | 0.906250 [0.906250, 0.906250] | 1.000000 [1.000000, 1.000000] | 0.939154 [0.938946, 0.939488] |
| 5 | tokens | 1020 | 0.941176 [0.941176, 0.941176] | 1.000000 [1.000000, 1.000000] | 0.971429 [0.971429, 0.971429] |
| 5 | combined | 1320 | 0.886364 [0.886364, 0.886364] | 1.000000 [1.000000, 1.000000] | 0.931661 [0.931347, 0.931845] |
| 5 | conflict_abstain | 1290 | 0.906977 [0.906977, 0.906977] | 1.000000 [1.000000, 1.000000] | 0.954545 [0.954545, 0.954545] |
| 10 | metadata | 960 | 0.875000 [0.875000, 0.875000] | 1.000000 [1.000000, 1.000000] | 0.906825 [0.906352, 0.907310] |
| 10 | tokens | 1020 | 0.941176 [0.941176, 0.941176] | 1.000000 [1.000000, 1.000000] | 0.971429 [0.971429, 0.971429] |
| 10 | combined | 1320 | 0.863636 [0.863636, 0.863636] | 1.000000 [1.000000, 1.000000] | 0.907753 [0.907334, 0.908037] |
| 10 | conflict_abstain | 1260 | 0.904762 [0.904762, 0.904762] | 1.000000 [1.000000, 1.000000] | 0.953488 [0.953488, 0.953488] |
| 20 | metadata | 960 | 0.812500 [0.812500, 0.812500] | 1.000000 [1.000000, 1.000000] | 0.842335 [0.841803, 0.843360] |
| 20 | tokens | 1020 | 0.941176 [0.941176, 0.941176] | 1.000000 [1.000000, 1.000000] | 0.971429 [0.971429, 0.971429] |
| 20 | combined | 1320 | 0.818182 [0.818182, 0.818182] | 1.000000 [1.000000, 1.000000] | 0.860292 [0.859872, 0.860665] |
| 20 | conflict_abstain | 1200 | 0.900000 [0.900000, 0.900000] | 1.000000 [1.000000, 1.000000] | 0.951220 [0.951220, 0.951220] |
| 40 | metadata | 960 | 0.687500 [0.687500, 0.687500] | 1.000000 [1.000000, 1.000000] | 0.713004 [0.712404, 0.714444] |
| 40 | tokens | 1020 | 0.941176 [0.941176, 0.941176] | 1.000000 [1.000000, 1.000000] | 0.971429 [0.971429, 0.971429] |
| 40 | combined | 1320 | 0.727273 [0.727273, 0.727273] | 1.000000 [1.000000, 1.000000] | 0.764847 [0.764344, 0.765489] |
| 40 | conflict_abstain | 1080 | 0.888889 [0.888889, 0.888889] | 1.000000 [1.000000, 1.000000] | 0.945946 [0.945946, 0.945946] |
| 60 | metadata | 960 | 0.562500 [0.562500, 0.562500] | 1.000000 [1.000000, 1.000000] | 0.583674 [0.582983, 0.585332] |
| 60 | tokens | 1020 | 0.941176 [0.941176, 0.941176] | 1.000000 [1.000000, 1.000000] | 0.971429 [0.971429, 0.971429] |
| 60 | combined | 1320 | 0.636364 [0.636364, 0.636364] | 1.000000 [1.000000, 1.000000] | 0.669583 [0.669071, 0.670408] |
| 60 | conflict_abstain | 960 | 0.875000 [0.875000, 0.875000] | 1.000000 [1.000000, 1.000000] | 0.939394 [0.939394, 0.939394] |
| 80 | metadata | 960 | 0.437500 [0.437500, 0.437500] | 1.000000 [1.000000, 1.000000] | 0.453988 [0.453325, 0.455060] |
| 80 | tokens | 1020 | 0.941176 [0.941176, 0.941176] | 1.000000 [1.000000, 1.000000] | 0.971429 [0.971429, 0.971429] |
| 80 | combined | 1320 | 0.545455 [0.545455, 0.545455] | 1.000000 [1.000000, 1.000000] | 0.574066 [0.573348, 0.575004] |
| 80 | conflict_abstain | 840 | 0.857143 [0.857143, 0.857143] | 1.000000 [1.000000, 1.000000] | 0.931034 [0.931034, 0.931034] |
| 100 | metadata | 960 | 0.312500 [0.312500, 0.312500] | 1.000000 [1.000000, 1.000000] | 0.324240 [0.323720, 0.325060] |
| 100 | tokens | 1020 | 0.941176 [0.941176, 0.941176] | 1.000000 [1.000000, 1.000000] | 0.971429 [0.971429, 0.971429] |
| 100 | combined | 1320 | 0.454545 [0.454545, 0.454545] | 1.000000 [1.000000, 1.000000] | 0.478294 [0.477749, 0.479174] |
| 100 | conflict_abstain | 720 | 0.833333 [0.833333, 0.833333] | 1.000000 [1.000000, 1.000000] | 0.920000 [0.920000, 0.920000] |

## Ranking quality and candidate-set checks

| Cohort | Method | Total scenarios | Quality denominator | Excluded | Candidate sets passed | Mean NDCG@3 | Mean P@3 |
|---|---|---:|---:|---:|---:|---:|---:|
| original8 | eligible_id | 8 | 8 | 0 | 8 | 0.602084 | 0.500000 |
| original8 | metadata | 8 | 8 | 0 | 8 | 0.800465 | 0.500000 |
| original8 | tokens | 8 | 8 | 0 | 8 | 0.846598 | 0.500000 |
| original8 | combined | 8 | 8 | 0 | 8 | 0.800465 | 0.500000 |
| original8 | conflict_abstain | 8 | 8 | 0 | 8 | 0.846598 | 0.500000 |
| new | eligible_id | 16 | 12 | 4 | 16 | 0.611728 | 0.361111 |
| new | metadata | 16 | 12 | 4 | 16 | 0.669756 | 0.361111 |
| new | tokens | 16 | 12 | 4 | 16 | 0.711423 | 0.361111 |
| new | combined | 16 | 12 | 4 | 16 | 0.711423 | 0.361111 |
| new | conflict_abstain | 16 | 12 | 4 | 16 | 0.628090 | 0.333333 |
| pooled | eligible_id | 24 | 20 | 4 | 24 | 0.607871 | 0.416667 |
| pooled | metadata | 24 | 20 | 4 | 24 | 0.722040 | 0.416667 |
| pooled | tokens | 24 | 20 | 4 | 24 | 0.765493 | 0.416667 |
| pooled | combined | 24 | 20 | 4 | 24 | 0.747040 | 0.416667 |
| pooled | conflict_abstain | 24 | 20 | 4 | 24 | 0.715493 | 0.400000 |

## Per-scenario ranking (negative findings retained)

| Cohort | Scenario | Method | Candidates | NDCG@3 | P@3 | Status |
|---|---|---|---:|---:|---:|---|
| original8 | grocery_need | eligible_id | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | grocery_need | metadata | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | grocery_need | tokens | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | grocery_need | combined | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | grocery_need | conflict_abstain | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | commuter | eligible_id | 5 | 0.458659706 | 0.333333333 | defined |
| original8 | commuter | metadata | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | commuter | tokens | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | commuter | combined | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | commuter | conflict_abstain | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | utility_need | eligible_id | 5 | 0.065522815 | 0.333333333 | defined |
| original8 | utility_need | metadata | 5 | 0.917319413 | 0.333333333 | defined |
| original8 | utility_need | tokens | 5 | 0.917319413 | 0.333333333 | defined |
| original8 | utility_need | combined | 5 | 0.917319413 | 0.333333333 | defined |
| original8 | utility_need | conflict_abstain | 5 | 0.917319413 | 0.333333333 | defined |
| original8 | dining_need | eligible_id | 5 | 0.709809741 | 0.666666667 | defined |
| original8 | dining_need | metadata | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | dining_need | tokens | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | dining_need | combined | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | dining_need | conflict_abstain | 5 | 1.000000000 | 0.666666667 | defined |
| original8 | shopping_need | eligible_id | 5 | 0.082680587 | 0.333333333 | defined |
| original8 | shopping_need | metadata | 5 | 0.982842228 | 0.666666667 | defined |
| original8 | shopping_need | tokens | 5 | 0.982842228 | 0.666666667 | defined |
| original8 | shopping_need | combined | 5 | 0.982842228 | 0.666666667 | defined |
| original8 | shopping_need | conflict_abstain | 5 | 0.982842228 | 0.666666667 | defined |
| original8 | needs_diverge_from_spend | eligible_id | 5 | 1.000000000 | 1.000000000 | defined |
| original8 | needs_diverge_from_spend | metadata | 5 | 0.372626267 | 0.333333333 | defined |
| original8 | needs_diverge_from_spend | tokens | 5 | 0.372626267 | 0.333333333 | defined |
| original8 | needs_diverge_from_spend | combined | 5 | 0.372626267 | 0.333333333 | defined |
| original8 | needs_diverge_from_spend | conflict_abstain | 5 | 0.372626267 | 0.333333333 | defined |
| original8 | unrecognized_history | eligible_id | 5 | 0.500000000 | 0.333333333 | defined |
| original8 | unrecognized_history | metadata | 5 | 0.500000000 | 0.333333333 | defined |
| original8 | unrecognized_history | tokens | 5 | 0.500000000 | 0.333333333 | defined |
| original8 | unrecognized_history | combined | 5 | 0.500000000 | 0.333333333 | defined |
| original8 | unrecognized_history | conflict_abstain | 5 | 0.500000000 | 0.333333333 | defined |
| original8 | wrong_metadata | eligible_id | 5 | 1.000000000 | 0.333333333 | defined |
| original8 | wrong_metadata | metadata | 5 | 0.630929754 | 0.333333333 | defined |
| original8 | wrong_metadata | tokens | 5 | 1.000000000 | 0.333333333 | defined |
| original8 | wrong_metadata | combined | 5 | 0.630929754 | 0.333333333 | defined |
| original8 | wrong_metadata | conflict_abstain | 5 | 1.000000000 | 0.333333333 | defined |
| new | sparse_empty | eligible_id | 5 | 0.500000000 | 0.333333333 | defined |
| new | sparse_empty | metadata | 5 | 0.500000000 | 0.333333333 | defined |
| new | sparse_empty | tokens | 5 | 0.500000000 | 0.333333333 | defined |
| new | sparse_empty | combined | 5 | 0.500000000 | 0.333333333 | defined |
| new | sparse_empty | conflict_abstain | 5 | 0.500000000 | 0.333333333 | defined |
| new | sparse_aligned | eligible_id | 5 | 0.500000000 | 0.333333333 | defined |
| new | sparse_aligned | metadata | 5 | 0.500000000 | 0.333333333 | defined |
| new | sparse_aligned | tokens | 5 | 1.000000000 | 0.333333333 | defined |
| new | sparse_aligned | combined | 5 | 1.000000000 | 0.333333333 | defined |
| new | sparse_aligned | conflict_abstain | 5 | 1.000000000 | 0.333333333 | defined |
| new | sparse_misleading | eligible_id | 5 | 1.000000000 | 0.666666667 | defined |
| new | sparse_misleading | metadata | 5 | 0.644286926 | 0.666666667 | defined |
| new | sparse_misleading | tokens | 5 | 0.644286926 | 0.666666667 | defined |
| new | sparse_misleading | combined | 5 | 0.644286926 | 0.666666667 | defined |
| new | sparse_misleading | conflict_abstain | 5 | 0.644286926 | 0.666666667 | defined |
| new | changed_to_transit | eligible_id | 5 | 0.500000000 | 0.333333333 | defined |
| new | changed_to_transit | metadata | 5 | 0.630929754 | 0.333333333 | defined |
| new | changed_to_transit | tokens | 5 | 0.630929754 | 0.333333333 | defined |
| new | changed_to_transit | combined | 5 | 0.630929754 | 0.333333333 | defined |
| new | changed_to_transit | conflict_abstain | 5 | 0.630929754 | 0.333333333 | defined |
| new | changed_to_dining | eligible_id | 5 | 0.630929754 | 0.333333333 | defined |
| new | changed_to_dining | metadata | 5 | 0.630929754 | 0.333333333 | defined |
| new | changed_to_dining | tokens | 5 | 0.630929754 | 0.333333333 | defined |
| new | changed_to_dining | combined | 5 | 0.630929754 | 0.333333333 | defined |
| new | changed_to_dining | conflict_abstain | 5 | 0.630929754 | 0.333333333 | defined |
| new | old_outside_window | eligible_id | 5 | 0.500000000 | 0.333333333 | defined |
| new | old_outside_window | metadata | 5 | 1.000000000 | 0.333333333 | defined |
| new | old_outside_window | tokens | 5 | 1.000000000 | 0.333333333 | defined |
| new | old_outside_window | combined | 5 | 1.000000000 | 0.333333333 | defined |
| new | old_outside_window | conflict_abstain | 5 | 1.000000000 | 0.333333333 | defined |
| new | wrong_metadata_transit | eligible_id | 5 | 0.500000000 | 0.333333333 | defined |
| new | wrong_metadata_transit | metadata | 5 | 0.500000000 | 0.333333333 | defined |
| new | wrong_metadata_transit | tokens | 5 | 1.000000000 | 0.333333333 | defined |
| new | wrong_metadata_transit | combined | 5 | 0.500000000 | 0.333333333 | defined |
| new | wrong_metadata_transit | conflict_abstain | 5 | 0.500000000 | 0.333333333 | defined |
| new | correct_metadata_bad_token | eligible_id | 5 | 0.000000000 | 0.000000000 | defined |
| new | correct_metadata_bad_token | metadata | 5 | 1.000000000 | 0.333333333 | defined |
| new | correct_metadata_bad_token | tokens | 5 | 0.000000000 | 0.000000000 | defined |
| new | correct_metadata_bad_token | combined | 5 | 1.000000000 | 0.333333333 | defined |
| new | correct_metadata_bad_token | conflict_abstain | 5 | 0.000000000 | 0.000000000 | defined |
| new | jointly_wrong | eligible_id | 5 | 1.000000000 | 0.333333333 | defined |
| new | jointly_wrong | metadata | 5 | 0.630929754 | 0.333333333 | defined |
| new | jointly_wrong | tokens | 5 | 0.630929754 | 0.333333333 | defined |
| new | jointly_wrong | combined | 5 | 0.630929754 | 0.333333333 | defined |
| new | jointly_wrong | conflict_abstain | 5 | 0.630929754 | 0.333333333 | defined |
| new | wrong_metadata_no_tokens | eligible_id | 5 | 0.500000000 | 0.333333333 | defined |
| new | wrong_metadata_no_tokens | metadata | 5 | 0.000000000 | 0.000000000 | defined |
| new | wrong_metadata_no_tokens | tokens | 5 | 0.500000000 | 0.333333333 | defined |
| new | wrong_metadata_no_tokens | combined | 5 | 0.000000000 | 0.000000000 | defined |
| new | wrong_metadata_no_tokens | conflict_abstain | 5 | 0.000000000 | 0.000000000 | defined |
| new | missing_snapshot | eligible_id | 0 | NA | NA | no_eligible_candidates |
| new | missing_snapshot | metadata | 0 | NA | NA | no_eligible_candidates |
| new | missing_snapshot | tokens | 0 | NA | NA | no_eligible_candidates |
| new | missing_snapshot | combined | 0 | NA | NA | no_eligible_candidates |
| new | missing_snapshot | conflict_abstain | 0 | NA | NA | no_eligible_candidates |
| new | stale_snapshot | eligible_id | 0 | NA | NA | no_eligible_candidates |
| new | stale_snapshot | metadata | 0 | NA | NA | no_eligible_candidates |
| new | stale_snapshot | tokens | 0 | NA | NA | no_eligible_candidates |
| new | stale_snapshot | combined | 0 | NA | NA | no_eligible_candidates |
| new | stale_snapshot | conflict_abstain | 0 | NA | NA | no_eligible_candidates |
| new | other_account_snapshot | eligible_id | 0 | NA | NA | no_eligible_candidates |
| new | other_account_snapshot | metadata | 0 | NA | NA | no_eligible_candidates |
| new | other_account_snapshot | tokens | 0 | NA | NA | no_eligible_candidates |
| new | other_account_snapshot | combined | 0 | NA | NA | no_eligible_candidates |
| new | other_account_snapshot | conflict_abstain | 0 | NA | NA | no_eligible_candidates |
| new | mixed_eligibility | eligible_id | 1 | 1.000000000 | 0.333333333 | defined |
| new | mixed_eligibility | metadata | 1 | 1.000000000 | 0.333333333 | defined |
| new | mixed_eligibility | tokens | 1 | 1.000000000 | 0.333333333 | defined |
| new | mixed_eligibility | combined | 1 | 1.000000000 | 0.333333333 | defined |
| new | mixed_eligibility | conflict_abstain | 1 | 1.000000000 | 0.333333333 | defined |
| new | mixed_validity | eligible_id | 2 | 0.709809741 | 0.666666667 | defined |
| new | mixed_validity | metadata | 2 | 1.000000000 | 0.666666667 | defined |
| new | mixed_validity | tokens | 2 | 1.000000000 | 0.666666667 | defined |
| new | mixed_validity | combined | 2 | 1.000000000 | 0.666666667 | defined |
| new | mixed_validity | conflict_abstain | 2 | 1.000000000 | 0.666666667 | defined |
| new | no_relevant_eligible | eligible_id | 1 | NA | NA | zero_ideal_gain |
| new | no_relevant_eligible | metadata | 1 | NA | NA | zero_ideal_gain |
| new | no_relevant_eligible | tokens | 1 | NA | NA | zero_ideal_gain |
| new | no_relevant_eligible | combined | 1 | NA | NA | zero_ideal_gain |
| new | no_relevant_eligible | conflict_abstain | 1 | NA | NA | zero_ideal_gain |
