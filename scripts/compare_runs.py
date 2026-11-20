#!/usr/bin/env python3
from pathlib import Path
import sys
r=Path(__file__).resolve().parents[1]; out=Path(sys.argv[1])
original=['dataset.json','classification-summary.csv','classification-by-class.csv','predictions.csv','confusion.csv','classification-slices.csv','composition.csv','ranking.csv','ranking-summary.csv']
validation=['predictions.csv','classification-summary.csv','per-class.csv','confusion.csv','interventions.csv','ranking.csv','sensitivity-aggregate.csv','ranking-summary.csv','tables.md']
for names,baseline,current in [(original,r/'artifact/results',out/'original'),(validation,r/'artifact/Validation/results',out/'validation')]:
 for name in names:assert (baseline/name).read_bytes()==(current/name).read_bytes(),name
print('PASS: 18 deterministic files match historical outputs byte-for-byte. New benchmark timings, environment and logs are intentionally excluded; new benchmark summaries are independently audited.')
