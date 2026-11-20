#!/usr/bin/env python3
"""Audit historical results and manuscript values without changing evidence."""
import csv, subprocess, sys, tempfile, shutil, re
from pathlib import Path
R=Path(__file__).resolve().parents[1]; A=R/'artifact'
def run(*args): subprocess.run([sys.executable,*map(str,args)],check=True)
run(A/'scripts/audit.py',A/'results')
run(A/'scripts/audit.py',A/'results-reproduced')
run(A/'Validation/scripts/audit.py',A/'Validation/results')
run(A/'Validation/scripts/audit.py',A/'Validation/results-reproduced')
with tempfile.TemporaryDirectory(prefix='offers-table-audit-') as temp:
 t=Path(temp)
 for name in ['classification-summary.csv','ranking.csv']:
  shutil.copyfile(A/'Validation/results'/name,t/name)
 run(A/'Validation/scripts/summarize.py',t)
 for name in ['tables.md','sensitivity-aggregate.csv','ranking-summary.csv']:
  assert (t/name).read_bytes()==(A/'Validation/results'/name).read_bytes(),name
# Every historical original manuscript-table data row must match an ordered
# projection of a measured CSV row; headers and alignment rows are excluded.
original_csv=[]
for p in (A/'results').glob('*.csv'):
 with p.open() as f:original_csv.extend(list(csv.reader(f))[1:])
def projected(values,row):
 it=iter(row)
 return all(any(cell==v for cell in it) for v in values)
count=0
for line in (A/'results/tables.md').read_text().splitlines():
 if not line.startswith('|'):continue
 cells=[v.strip() for v in line.strip('|').split('|')]
 if not any(re.fullmatch(r'\d+\.\d{6}',v) for v in cells):continue
 assert any(projected(cells,row) for row in original_csv),cells
 count+=1
# Check all six-decimal manuscript metric literals against exported score/timing
# evidence. This is a scalar consistency check, not automatic semantic review.
for report,directory in [(A/'docs/research-report.md',A/'results'),(A/'Validation/docs/research-report-updated.md',A/'Validation/results')]:
 values=set()
 for p in directory.glob('*.csv'):
  with p.open() as f:
   for row in csv.reader(f):
    for cell in row:
     try: values.add(f'{float(cell):.6f}')
     except ValueError:pass
 literals=set(re.findall(r'(?<![\d.])\d+\.\d{6}(?!\d)',report.read_text()))
 assert literals<=values,(report.name,literals-values)
# Key contextual claims: deliberately check method, cohort and scope associations.
def rows(path):
 with path.open() as f:return list(csv.DictReader(f))
original={r['method']:r for r in rows(A/'results/classification-summary.csv')}
assert original['tokens']['accuracy_all']=='0.583333'
assert original['combined']['accuracy_all']=='0.527778'
follow=rows(A/'Validation/results/sensitivity-aggregate.csv')
for rate in [0,5,10,20,40,60,80,100]:
 rs={r['method']:r for r in follow if r['scope']=='all' and int(r['rate'])==rate}
 assert rs['combined']['coverage_mean']=='0.611111'
 assert (float(rs['combined']['accuracy_mean'])>float(rs['tokens']['accuracy_mean']))==(rate<=20)
 assert rs['combined']['accuracy_mean']==rs['conflict_abstain']['accuracy_mean']
 if rate>0:
  assert float(rs['conflict_abstain']['coverage_mean'])<float(rs['combined']['coverage_mean'])
  assert float(rs['conflict_abstain']['macro_f1_known_min'])>float(rs['combined']['macro_f1_known_max'])
ranking=rows(A/'Validation/results/ranking-summary.csv')
new={r['method']:r for r in ranking if r['cohort']=='new'}
assert new['conflict_abstain']['mean_ndcg_at_3']=='0.628090'
assert new['combined']['mean_ndcg_at_3']=='0.711423'
assert all(r['quality_n']=='12' and r['excluded_n']=='4' for r in new.values())
print(f'PASS: {count} original table rows are CSV projections; follow-up tables/aggregates regenerate byte-identically; all six-decimal report metrics are present in CSV evidence; key contextual conclusions checked.')
print('Scope: prose meaning and non-score numbers require the documented manual evidence map; this is not automated proof of every sentence.')

# Validate each manually authored report table against its specific CSV context.
def tables(path):
 blocks=[]; block=[]
 for line in path.read_text().splitlines()+['']:
  if line.startswith('|'): block.append([x.strip() for x in line.strip('|').split('|')])
  elif block: blocks.append(block);block=[]
 return [b[2:] for b in blocks]
orig_tables=tables(A/'docs/research-report.md')
for cells in orig_tables[0]:
 method=cells[0].lower(); r=original[method]
 expected=[f"{r['correct_all']}/{r['n']}",r['classified_n'],r['accuracy_all'],r['accuracy_classified'],r['coverage'],r['macro_f1_known_all']]
 assert cells[1:]==expected,cells
orank={r['method']:r for r in rows(A/'results/ranking-summary.csv')}
for cells in orig_tables[1]:
 method={'Eligible ID baseline':'eligible_id','Metadata profile':'metadata','Token profile':'tokens','Combined profile':'combined'}[cells[0]]
 assert cells[1:]==[orank[method]['mean_ndcg_at_3'],orank[method]['mean_precision_at_3']]
bench={(r['n'],r['method']):r for r in rows(A/'results/benchmark-summary.csv')}
for cells in orig_tables[2]:
 n=cells[0].replace(',','')
 assert cells[1:]==[bench[n,m]['median_ms'] for m in ['metadata','tokens','combined']]
new_tables=tables(A/'Validation/docs/research-report-updated.md')
for cells in new_tables[0]:
 rate=cells[0].rstrip('%');method=cells[1].replace(' ','_')
 r=next(r for r in follow if r['scope']=='all' and r['rate']==rate and r['method']==method)
 assert cells[2:]==[r['accuracy_mean'],r['coverage_mean'],r['macro_f1_known_mean']],cells
rankmap={(r['cohort'],r['method']):r for r in ranking}
for cells in new_tables[1]:
 method={'Eligible ID baseline':'eligible_id','Metadata':'metadata','Tokens':'tokens','Combined':'combined','Conflict abstain':'conflict_abstain'}[cells[0]]
 assert cells[1:]==[rankmap[c,method]['mean_ndcg_at_3'] for c in ['original8','new','pooled']]+[rankmap['pooled',method]['mean_precision_at_3']],cells
print('PASS: all five manually authored report tables verified against method/rate/cohort-specific CSV rows, including original timing medians.')
