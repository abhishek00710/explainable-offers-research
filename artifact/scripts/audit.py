#!/usr/bin/env python3
"""Independent standard-library recomputation from exported predictions/judgments.
Does not import Swift evaluation or classifier logic. Raises on any discrepancy.
"""
import csv
import json
import math
import sys
from pathlib import Path
from collections import Counter

root = Path(__file__).resolve().parents[1]
out = Path(sys.argv[1] if len(sys.argv) > 1 else root / 'results')
def rows(name):
    with (out / name).open() as stream:
        return list(csv.DictReader(stream))
def near(actual, expected):
    assert math.isfinite(float(actual)) and abs(float(actual) - expected) <= 0.0000011, (actual, expected)
def ratio(n, d):
    return n / d if d else 0
predictions = rows('predictions.csv')
summary = rows('classification-summary.csv')
classes = ['groceries', 'dining', 'transport', 'shopping', 'utilities', 'unknown']
for s in summary:
    selected = [r for r in predictions if r['method'] == s['method']]
    covered = [r for r in selected if r['prediction'] != 'unknown']
    assert len(selected) == int(s['n']) and len(covered) == int(s['classified_n'])
    assert len({r['transaction_id'] for r in selected}) == len(selected)
    correct = sum(r['truth'] == r['prediction'] for r in selected)
    correct_covered = sum(r['truth'] == r['prediction'] for r in covered)
    assert correct == int(s['correct_all']) and correct_covered == int(s['correct_classified'])
    near(s['accuracy_all'], ratio(correct, len(selected)))
    near(s['accuracy_classified'], ratio(correct_covered, len(covered)))
    near(s['coverage'], ratio(len(covered), len(selected)))
    near(s['abstention'], 1-ratio(len(covered), len(selected)))
    known_f1 = []
    for scope, subset in [('all', selected), ('classified', covered)]:
        metrics = []
        for c in classes:
            tp = sum(r['truth'] == c and r['prediction'] == c for r in subset)
            fp = sum(r['truth'] != c and r['prediction'] == c for r in subset)
            fn = sum(r['truth'] == c and r['prediction'] != c for r in subset)
            metrics.append((tp, fp, fn, ratio(tp,tp+fp), ratio(tp,tp+fn), ratio(2*tp,2*tp+fp+fn)))
        for row in rows('classification-by-class.csv'):
            if row['method'] != s['method'] or row['scope'] != scope:
                continue
            assert int(row['denominator']) == len(subset)
            c = row['class']
            if c in classes:
                tp, fp, fn, precision, recall, f1 = metrics[classes.index(c)]
                assert [int(row[k]) for k in ['tp','fp','fn','support']] == [tp,fp,fn,tp+fn]
            else:
                ms = metrics[:5] if c.endswith('known') else metrics
                if c.startswith('micro'):
                    tp, fp, fn = [sum(m[i] for m in ms) for i in range(3)]
                    precision, recall, f1 = ratio(tp,tp+fp),ratio(tp,tp+fn),ratio(2*tp,2*tp+fp+fn)
                else:
                    precision, recall, f1 = [sum(m[i] for m in ms)/len(ms) for i in [3,4,5]]
            for key, value in [('precision',precision),('recall',recall),('f1',f1)]:
                near(row[key],value)
        if scope == 'all':
            near(s['macro_f1_known_all'], sum(m[5] for m in metrics[:5])/5)
    counts = Counter((r['truth'],r['prediction']) for r in selected)
    for row in rows('confusion.csv'):
        if row['method'] == s['method']:
            assert int(row['count']) == counts[row['truth'],row['prediction']]
scenarios = {s['id']: s for s in json.loads((root/'Sources/SyntheticData/Resources/ranking.json').read_text())}
ranking = rows('ranking.csv')
for row in ranking:
    scenario = scenarios[row['scenario']]
    order = row['order'].split()
    assert len(order) == len(set(order)) == int(row['eligible_n'])
    assert all(scenario['decisions'][i] == 'eligible' for i in order)
    judgments = {i: scenario['judgments'][i] for i in order}
    def dcg(grades):
        return sum((2**g-1)/math.log2(i+2) for i,g in enumerate(grades[:3]))
    ideal = dcg(sorted(judgments.values(), reverse=True))
    near(row['ndcg_at_3'], ratio(dcg([judgments[i] for i in order]), ideal))
    near(row['precision_at_3'], sum(judgments[i] > 0 for i in order[:3])/3)
for row in rows('ranking-summary.csv'):
    selected = [r for r in ranking if r['method'] == row['method']]
    assert len(selected) == int(row['scenario_n'])
    near(row['mean_ndcg_at_3'], sum(float(r['ndcg_at_3']) for r in selected)/len(selected))
    near(row['mean_precision_at_3'], sum(float(r['precision_at_3']) for r in selected)/len(selected))
raw = rows('benchmark-trials.csv')
assert len(raw) == 81
for row in rows('benchmark-summary.csv'):
    selected = [r for r in raw if (r['n'],r['method']) == (row['n'],row['method'])]
    assert {int(r['trial']) for r in selected} == set(range(9))
    assert len({r['checksum'] for r in selected}) == 1
    ds = sorted(float(r['elapsed_ms']) for r in selected)
    assert all(math.isfinite(d) and d > 0 for d in ds)
    mean = sum(ds)/9
    for key, value in [('min_ms',ds[0]),('median_ms',ds[4]),('p90_ms',ds[8]),('max_ms',ds[-1]),('mean_ms',mean),('sample_sd_ms',math.sqrt(sum((d-mean)**2 for d in ds)/8))]:
        near(row[key],value)
env = json.loads((out/'environment.json').read_text())
assert env['buildConfiguration'] == 'release'
assert len(json.loads((out/'dataset.json').read_text())) == int(env['datasetCount'])
print(f'PASS: independently recomputed classification metrics ({len(predictions)} predictions), ranking ({len(ranking)} rows), and {len(raw)} benchmark trials.')
