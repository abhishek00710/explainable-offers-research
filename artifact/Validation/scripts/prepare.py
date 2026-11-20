#!/usr/bin/env python3
"""Construct interventions without importing/calling classifiers. Labels remain frozen."""
from pathlib import Path
import json, copy, sys
V=Path(__file__).resolve().parents[1]; R=V.parent
destination=Path(sys.argv[1]) if len(sys.argv)>1 else V/'inputs'
destination.mkdir(parents=True,exist_ok=True)
cats=['groceries','dining','transport','shopping','utilities']
class RNG:
 def __init__(self,seed): self.s=seed
 def next(self):
  mask=(1<<64)-1; self.s=(self.s+0x9E3779B97F4A7C15)&mask; z=self.s
  z=((z^(z>>30))*0xBF58476D1CE4E5B9)&mask
  z=((z^(z>>27))*0x94D049BB133111EB)&mask
  return z^(z>>31)
def write(name,data): (destination/name).write_text(json.dumps(data,indent=2,sort_keys=True)+'\n')
data=json.loads((R/'results/dataset.json').read_text())
pool=[r for r in data if r['label'] in cats and r['transaction'].get('structuredCategory') in cats]
assert len(pool)==600
plans=[]
for seed in [11,29,47,71,101]:
 rng=RNG(seed); orders={}; wrong={}
 for c in cats:
  ids=sorted(r['transaction']['id'] for r in pool if r['label']==c)
  assert len(ids)==120
  for i in range(len(ids)-1,0,-1):
   j=rng.next()%(i+1); ids[i],ids[j]=ids[j],ids[i]
  orders[c]=ids
  for id in ids: wrong[id]=cats[(cats.index(c)+1+rng.next()%4)%5]
 for rate in [0,5,10,20,40,60,80,100]:
  assigned={}
  for c in cats:
   for i,id in enumerate(orders[c]): assigned[id]=wrong[id] if i < 120*rate//100 else c
  plans.append(dict(seed=seed,rate=rate,assigned=assigned))
write('plans.json',plans)
now=1800000000
base=json.loads((R/'Sources/SyntheticData/Resources/ranking.json').read_text())
scenarios=[]
for s in base:
 s=copy.deepcopy(s); s['cohort']='original8'; s['rationale']='Unchanged original authored judgments.'
 s['accountID']='A'; s['snapshot']=dict(accountID='A',issuedAt=now-10,expiresAt=now+100,decisions=s.pop('decisions'))
 s['expectedEligible']=[o['id'] for o in s['offers']]; scenarios.append(s)
offers=copy.deepcopy(base[0]['offers'])
# Each history tuple is description, observed category, gold category, cents, age days.
def make(id,hist,grades,rationale):
 ts=[]; truth={}
 for i,(text,observed,gold,cents,days) in enumerate(hist):
  tid=id+'-'+str(i); truth[tid]=gold
  ts.append(dict(id=tid,accountID='A',timestamp=now-days*86400,amountCents=cents,currency='USD',description=text,structuredCategory=observed,status='posted'))
 return dict(id=id,cohort='new',rationale=rationale,accountID='A',transactions=ts,historyTruth=truth,
  offers=copy.deepcopy(offers),snapshot=dict(accountID='A',issuedAt=now-10,expiresAt=now+100,decisions={o['id']:'eligible' for o in offers}),
  expectedEligible=[o['id'] for o in offers],judgments={o['id']:g for o,g in zip(offers,grades)})
new=[
make('sparse_empty',[],[0,0,3,0,0],'No observed history; declared need is a transit pass.'),
make('sparse_aligned',[('Metro',None,'transport',250,1)],[0,0,3,0,0],'One small transit purchase; declared commuting need aligns.'),
make('sparse_misleading',[('Apparel','shopping','shopping',80000,1)],[3,1,0,0,0],'One exceptional apparel purchase; current stated need is groceries.'),
make('changed_to_transit',[('Cafe','dining','dining',20000,24),('Metro','transport','transport',1000,1)],[0,0,3,0,0],'New commute replaces prior dining preference; unweighted 30-day total may lag.'),
make('changed_to_dining',[('Electric','utilities','utilities',30000,27),('Cafe','dining','dining',1500,1)],[0,3,0,0,0],'One-off old utility bill; present stated need is dining.'),
make('old_outside_window',[('Apparel','shopping','shopping',90000,31),('Metro','transport','transport',500,1)],[0,0,3,0,0],'Old exceptional purchase is outside the specified window; transit need now.'),
make('wrong_metadata_transit',[('Metro','groceries','transport',12000,1)],[0,0,3,0,0],'Transit purchase incorrectly tagged groceries; transit need independently declared.'),
make('correct_metadata_bad_token',[('Coffee Warehouse','shopping','shopping',9000,1)],[0,0,0,3,0],'Fictional appliance shop with coffee in its name; correct shopping metadata conflicts with token cue.'),
make('jointly_wrong',[('Coffee Foundation','dining','unknown',9000,1)],[3,0,0,0,0],'Donation mislabeled dining by metadata and lexical cue; groceries is declared need.'),
make('wrong_metadata_no_tokens',[('Zephyr Mobility','shopping','transport',8000,1)],[0,0,3,0,0],'Transit merchant unknown to aliases; erroneous shopping metadata cannot be cross-checked.'),
make('missing_snapshot',[('Cafe','dining','dining',1000,1)],[0,3,0,0,0],'Missing authoritative eligibility must suppress all offers.'),
make('stale_snapshot',[('Cafe','dining','dining',1000,1)],[0,3,0,0,0],'One-hour-old snapshot is stale at exact policy boundary.'),
make('other_account_snapshot',[('Cafe','dining','dining',1000,1)],[0,3,0,0,0],'Snapshot belongs to another account; no inference allowed.'),
make('mixed_eligibility',[('Cafe','dining','dining',15000,1),('Metro','transport','transport',500,1)],[0,3,2,0,0],'Preferred dining denied; only transit explicitly eligible; missing and unknown decisions fail closed.'),
make('mixed_validity',[('Electric','utilities','utilities',2000,1)],[1,3,0,2,3],'Expired, future and wrong-currency offers excluded independently of relevance.'),
make('no_relevant_eligible',[('Cafe','dining','dining',1000,1)],[0,3,0,0,0],'Only irrelevant groceries eligible; no ideal relevance gain, quality undefined.')]
for s in new:
 id=s['id']
 if id=='missing_snapshot': s['snapshot']=None; s['expectedEligible']=[]
 if id=='stale_snapshot': s['snapshot']['issuedAt']=now-3600; s['expectedEligible']=[]
 if id=='other_account_snapshot': s['snapshot']['accountID']='B'; s['expectedEligible']=[]
 if id=='mixed_eligibility':
  s['snapshot']['decisions']={'o1':'unknown','o2':'ineligible','o3':'eligible','o5':'ineligible'}; s['expectedEligible']=['o3']
 if id=='mixed_validity':
  s['offers'][1]['validUntil']=now; s['offers'][2]['validFrom']=now+1; s['offers'][3]['currency']='EUR'; s['expectedEligible']=['o1','o5']
 if id=='no_relevant_eligible': s['snapshot']['decisions']={'o1':'eligible','o2':'ineligible'}; s['expectedEligible']=['o1']
scenarios+=new
write('ranking-expanded.json',scenarios)
print(f'Prepared {len(plans)} intervention plans; {len(pool)} controlled rows; {len(scenarios)} ranking scenarios (8 original + {len(new)} new). No classifier used.')
