#!/usr/bin/env python3
"""Maintainer operation: refresh only after reviewed release changes."""
import hashlib,json
from pathlib import Path
r=Path(__file__).resolve().parents[1]
files=[p for p in r.rglob('*') if p.is_file() and not any(x in p.relative_to(r).parts for x in ['.git','runs','__pycache__']) and p.name!='.DS_Store' and p!=r/'provenance/release-sha256.json']
m={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)}
(r/'provenance/release-sha256.json').write_text(json.dumps(m,sort_keys=True,indent=2)+'\n')
print(f'Manifested {len(m)} files.')
