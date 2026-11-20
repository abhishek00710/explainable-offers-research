#!/usr/bin/env python3
"""Independent recomputation from exported predictions, never Swift metric helpers."""
import csv,json,hashlib,math,sys
from pathlib import Path
from collections import defaultdict,Counter
V=Path(__file__).resolve().parents[1]; R=V.parent
out=Path(sys.argv[1] if len(sys.argv)>1 else V/'results')
def rows(name):
 with (out/name).open() as f: return list(csv.DictReader(f))
def near(x,y): assert abs(float(x)-y)<2e-9,(x,y)
def ratio(n,d): return n/d if d else 0
cats=['groceries','dining','transport','shopping','utilities','unknown']
manifest=json.loads((V/'inputs/original-sha256.json').read_text())
for name,digest in manifest.items(): assert hashlib.sha256((R/name).read_bytes()).hexdigest()==digest,('Original modified',name)
for module in ['OfferCore','Evaluation']:
 for p in (R/'Sources'/module).glob('*.swift'): assert p.read_bytes()==(V/'Sources'/module/p.name).read_bytes(),p.name
print(f'PASS: preserved all {len(manifest)} original files; baseline module copies are byte-identical.')
catalog={c['caseID']:c for c in json.loads((R/'Sources/SyntheticData/Resources/catalog.json').read_text())}
data=json.loads((R/'results/dataset.json').read_text()); truth={r['transaction']['id']:r['label'] for r in data}
assert all(r['label']==catalog[r['caseID']]['label'] for r in data)
plans=json.loads((V/'inputs/plans.json').read_text()); pool=set(plans[0]['assigned'])
previous={}; wrongs={}; original_by_id={r['transaction']['id']:r for r in data}
for p in plans:
 seed,rate=p['seed'],p['rate']; assigned=p['assigned']; assert set(assigned)==pool
 bad={id for id,c in assigned.items() if c!=truth[id]}
 assert len(bad)==600*rate//100
 for c in cats[:5]: assert sum(truth[id]==c for id in bad)==120*rate//100
 assert previous.get(seed,set()) <= bad; previous[seed]=bad
 for id in bad:
  key=(seed,id)
  assert assigned[id] in cats[:5] and assigned[id]!=truth[id]
  if key in wrongs: assert wrongs[key]==assigned[id]
  wrongs[key]=assigned[id]
print('PASS: labels match frozen catalog; exact stratified corruption rates, nested sets and fixed wrong categories verified. Preparation imports no classifier; authorship is not blinded.')
groups=defaultdict(list)
for r in rows('predictions.csv'):
 assert r['truth']==truth[r['id']]
 assert r['controlled']==str(int(r['id'] in pool))
 groups[r['experiment'],r['seed'],r['rate'],r['method']].append(r)
assert len(groups)==164
summary={tuple(r[k] for k in ['experiment','seed','rate','method','scope']):r for r in rows('classification-summary.csv')}
class_rows={tuple(r[k] for k in ['experiment','seed','rate','method','scope','class']):r for r in rows('per-class.csv')}
confusion_rows={tuple(r[k] for k in ['experiment','seed','rate','method','scope','truth','prediction']):int(r['count']) for r in rows('confusion.csv')}
token_reference=None
for key,all_rows in groups.items():
 assert len(all_rows)==2160 and len({r['id'] for r in all_rows})==2160
 if key[-1]=='tokens':
  current={r['id']:r['prediction'] for r in all_rows}
  if token_reference is None: token_reference=current
  assert token_reference==current
 for scope in ['all','known_truth','controlled','classified']:
  subset=[r for r in all_rows if scope=='all' or (scope=='known_truth' and r['truth']!='unknown') or (scope=='controlled' and r['controlled']=='1') or (scope=='classified' and r['prediction']!='unknown')]
  k=key+(scope,); s=summary[k]; cm=Counter((r['truth'],r['prediction']) for r in subset)
  n=len(subset); correct=sum(cm[c,c] for c in cats); covered=sum(r['prediction']!='unknown' for r in subset)
  assert [int(s[c]) for c in ['n','correct','classified_n']]==[n,correct,covered]
  if n:
   near(s['accuracy'],correct/n); near(s['coverage'],covered/n); near(s['abstention'],1-covered/n)
  else: assert s['accuracy']==s['coverage']==s['abstention']=='NA'
  measures=[]
  for c in cats:
   tp=cm[c,c]; fp=sum(cm[t,c] for t in cats if t!=c); fn=sum(cm[c,p] for p in cats if p!=c)
   m=(tp,fp,fn,ratio(tp,tp+fp),ratio(tp,tp+fn),ratio(2*tp,2*tp+fp+fn)); measures.append(m)
   r=class_rows[k+(c,)]
   assert [int(r[z]) for z in ['n','support','tp','fp','fn']]==[n,tp+fn,tp,fp,fn]
   for z,value in zip(['precision','recall','f1'],m[3:]): near(r[z],value)
   for p in cats: assert confusion_rows[k+(c,p)]==cm[c,p]
  for label,ms in [('known',measures[:5]),('six',measures)]:
   near(s['macro_f1_'+label],sum(m[5] for m in ms)/len(ms))
   tp,fp,fn=[sum(m[i] for m in ms) for i in range(3)]
   near(s['micro_f1_'+label],ratio(2*tp,2*tp+fp+fn))
  near(s['macro_precision_known'],sum(m[3] for m in measures[:5])/5)
  near(s['macro_recall_known'],sum(m[4] for m in measures[:5])/5)
  if n: near(s['micro_f1_six'],correct/n)
# Original predictions must reproduce archived behavior exactly, not just aggregate metrics.
with (R/'results/predictions.csv').open() as f:
 for r in csv.DictReader(f):
  observed={x['id']:x['prediction'] for x in groups['original','-1','-1',r['method']]}
  assert observed[r['transaction_id']]==r['prediction']
assert all(token_reference[id]==truth[id] for id in pool), 'Controlled-pool token correctness assumption failed'
print('PASS: 354240 raw predictions; 656 scope summaries; all 23616 confusion cells and 3936 per-class rows independently recomputed. Original predictions reproduced; token predictions invariant to intervention.')
scenarios={s['id']:s for s in json.loads((V/'inputs/ranking-expanded.json').read_text())}
with (R/'Sources/SyntheticData/Resources/ranking.json').open() as f:
 for original in json.load(f):
  s=scenarios[original['id']]
  for field in ['transactions','offers','judgments']: assert s[field]==original[field]
  assert s['snapshot']['decisions']==original['decisions']
ranking=rows('ranking.csv'); assert len(ranking)==120
for r in ranking:
 s=scenarios[r['scenario']]; expected=set(s['expectedEligible']); order=r['order'].split(); snap=s['snapshot']; now=1800000000
 # Independently evaluate the authoritative gate against hand-authored expected sets.
 eligible=set()
 if snap and snap['accountID']==s['accountID'] and now-3600<snap['issuedAt']<=now<snap['expiresAt']:
  eligible={o['id'] for o in s['offers'] if snap['decisions'].get(o['id'])=='eligible' and o['currency']=='USD' and o['validFrom']<=now<o['validUntil']}
 assert eligible==expected
 assert set(order)==expected and len(order)==len(expected) and r['eligible_set_pass']=='1'
 judgments={i:s['judgments'][i] for i in expected}
 def dcg(gs): return sum((2**g-1)/math.log2(i+2) for i,g in enumerate(gs[:3]))
 ideal=dcg(sorted(judgments.values(),reverse=True))
 if not ideal: assert r['ndcg_at_3']==r['precision_at_3']=='NA'
 else:
  near(r['ndcg_at_3'],dcg([judgments[i] for i in order])/ideal)
  near(r['precision_at_3'],sum(judgments[i]>0 for i in order[:3])/3)
print('PASS: all 120 ranking candidate sets and independently calculated scores; original judgments unchanged; 20 safety/zero-gain rows excluded from quality means.')
# Classifier-free intervention implementation is small enough to inspect; these checks guard accidental dependencies.
prepare=(V/'scripts/prepare.py').read_text()
assert 'import OfferCore' not in prepare and 'Classifier(' not in prepare and '.classify(' not in prepare
print('No statistical significance or population prevalence inferred. Independence is procedural, not independent/blinded annotation.')

if (out/'sensitivity-aggregate.csv').exists():
 for r in rows('sensitivity-aggregate.csv'):
  selected=[x for x in summary.values() if x['experiment']=='sensitivity' and x['scope']==r['scope'] and x['rate']==r['rate'] and x['method']==r['method']]
  assert len(selected)==5
  for m in ['accuracy','coverage','abstention','macro_f1_known','macro_f1_six','micro_f1_known','micro_f1_six']:
   vals=[float(x[m]) for x in selected]
   for suffix,value in [('mean',sum(vals)/5),('min',min(vals)),('max',max(vals))]: assert abs(float(r[m+'_'+suffix])-value)<0.0000011
 for r in rows('ranking-summary.csv'):
  selected=[x for x in ranking if x['method']==r['method'] and (r['cohort']=='pooled' or x['cohort']==r['cohort'])]
  defined=[x for x in selected if x['quality_status']=='defined']
  assert int(r['total_scenarios'])==len(selected) and int(r['quality_n'])==len(defined)
  assert int(r['excluded_n'])==len(selected)-len(defined)
  for m in ['ndcg_at_3','precision_at_3']: assert abs(float(r['mean_'+m])-sum(float(x[m]) for x in defined)/len(defined))<0.0000011
 print('PASS: seed aggregates and ranking cohort summaries independently checked.')
