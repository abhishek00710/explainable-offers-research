#!/usr/bin/env python3
from pathlib import Path
import hashlib,json
v=Path(__file__).resolve().parents[1]
files=[p for p in v.rglob('*') if p.is_file() and p.name!='sha256-manifest.json' and '.build' not in p.parts and '__pycache__' not in p.parts]
m={str(p.relative_to(v)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)}
(v/'sha256-manifest.json').write_text(json.dumps(m,sort_keys=True,indent=2)+'\n')
print(f'Hashed {len(m)} validation artifacts; originals separately protected by inputs/original-sha256.json.')
