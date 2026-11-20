#!/usr/bin/env python3
import hashlib
import json
import sys
from pathlib import Path
root = Path(__file__).resolve().parents[1]
out = Path(sys.argv[1] if len(sys.argv) > 1 else root/'results').resolve()
files = [root/'Package.swift',root/'README.md',root/'.gitignore']
for directory in ['Sources','Tests','Fixtures','scripts','docs']:
    files += [p for p in (root/directory).rglob('*') if p.is_file()]
files += [p for p in out.iterdir() if p.is_file() and p.name != 'sha256-manifest.json']
manifest = {str(p.relative_to(root)) if p.is_relative_to(root) else str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(set(files))}
(out/'sha256-manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')
print(f'SHA-256 manifest: {len(manifest)} files')
