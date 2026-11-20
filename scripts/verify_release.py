#!/usr/bin/env python3
import hashlib,json
from pathlib import Path
r=Path(__file__).resolve().parents[1]
m=json.loads((r/'provenance/release-sha256.json').read_text())
for name,digest in m.items():assert hashlib.sha256((r/name).read_bytes()).hexdigest()==digest,name
expected=set(m)|{'provenance/release-sha256.json'}
actual={str(p.relative_to(r)) for p in r.rglob('*') if p.is_file() and not any(x in p.relative_to(r).parts for x in ['.git','runs','__pycache__']) and p.name!='.DS_Store'}
assert actual==expected,('unmanifested or missing files',actual^expected)
print(f'PASS: {len(m)} release-file hashes verified; no unmanifested publication files.')
