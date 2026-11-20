#!/usr/bin/env python3
import csv,sys,json
from pathlib import Path
from statistics import mean
V=Path(__file__).resolve().parents[1]; out=Path(sys.argv[1] if len(sys.argv)>1 else V/'results')
def read(name):
 with (out/name).open() as f:return list(csv.DictReader(f))
def write(name,rows):
 with (out/name).open('w',newline='') as f:
  w=csv.DictWriter(f,fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)
def fmt(x):return f'{x:.6f}'
summaries=read('classification-summary.csv')
methods=['metadata','tokens','combined','conflict_abstain']
metrics=['accuracy','coverage','abstention','macro_f1_known','macro_f1_six','micro_f1_known','micro_f1_six']
aggregate=[]
for scope in ['all','known_truth','controlled','classified']:
 for rate in [0,5,10,20,40,60,80,100]:
  for method in methods:
   rs=[r for r in summaries if r['experiment']=='sensitivity' and r['scope']==scope and int(r['rate'])==rate and r['method']==method]
   assert len(rs)==5
   row=dict(scope=scope,rate=rate,method=method,seeds=5,n_min=min(int(r['n']) for r in rs),n_max=max(int(r['n']) for r in rs))
   for m in metrics:
    values=[float(r[m]) for r in rs]
    row[m+'_mean']=fmt(mean(values));row[m+'_min']=fmt(min(values));row[m+'_max']=fmt(max(values))
   aggregate.append(row)
write('sensitivity-aggregate.csv',aggregate)
ranking=read('ranking.csv'); ranking_summary=[]
for cohort in ['original8','new','pooled']:
 for method in ['eligible_id']+methods:
  rs=[r for r in ranking if (cohort=='pooled' or r['cohort']==cohort) and r['method']==method]
  quality=[r for r in rs if r['quality_status']=='defined']
  ranking_summary.append(dict(cohort=cohort,method=method,total_scenarios=len(rs),quality_n=len(quality),excluded_n=len(rs)-len(quality),eligible_set_passes=sum(int(r['eligible_set_pass']) for r in rs),mean_ndcg_at_3=fmt(mean(float(r['ndcg_at_3']) for r in quality)),mean_precision_at_3=fmt(mean(float(r['precision_at_3']) for r in quality))))
write('ranking-summary.csv',ranking_summary)
lines=['# Follow-up manuscript tables','', 'New validation experiments only. Original artifacts remain unchanged. Rates are constructed, not observed prevalence. Seed ranges are descriptive minima/maxima, not confidence intervals.','', '## Original dataset with added conflict policy','', '| Method | N | Correct | Classified N | Accuracy | Coverage | Known macro-F1 |','|---|---:|---:|---:|---:|---:|---:|']
for r in summaries:
 if r['experiment']=='original' and r['scope']=='all':lines.append('| '+' | '.join(r[k] for k in ['method','n','correct','classified_n','accuracy','coverage','macro_f1_known'])+' |')
for scope in ['all','known_truth','controlled','classified']:
 lines+=['',f'## Sensitivity: {scope}','', 'Mean across five assignment seeds; brackets are min–max. Accuracy/coverage denominators are this selected scope. See CSV for six-class/micro metrics and all seed-level counts.','', '| Controlled error % | Method | Selected N | Accuracy | Coverage | Known macro-F1 |','|---:|---|---:|---:|---:|---:|']
 for r in aggregate:
  if r['scope']!=scope:continue
  values=[str(r['rate']),r['method'],str(r['n_min']) if r['n_min']==r['n_max'] else f"{r['n_min']}–{r['n_max']}"]
  for m in ['accuracy','coverage','macro_f1_known']:values.append(f"{r[m+'_mean']} [{r[m+'_min']}, {r[m+'_max']}]")
  lines.append('| '+' | '.join(values)+' |')
lines+=['','## Ranking quality and candidate-set checks','','| Cohort | Method | Total scenarios | Quality denominator | Excluded | Candidate sets passed | Mean NDCG@3 | Mean P@3 |','|---|---|---:|---:|---:|---:|---:|---:|']
for r in ranking_summary:lines.append('| '+' | '.join(str(x) for x in r.values())+' |')
lines+=['','## Per-scenario ranking (negative findings retained)','','| Cohort | Scenario | Method | Candidates | NDCG@3 | P@3 | Status |','|---|---|---|---:|---:|---:|---|']
for r in ranking:lines.append('| '+' | '.join(r[k] for k in ['cohort','scenario','method','returned_n','ndcg_at_3','precision_at_3','quality_status'])+' |')
(out/'tables.md').write_text('\n'.join(lines)+'\n')
print(f'Generated {len(aggregate)} sensitivity summaries, {len(ranking_summary)} cohort summaries, and manuscript tables.')
