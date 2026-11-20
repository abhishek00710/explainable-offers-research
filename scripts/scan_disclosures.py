#!/usr/bin/env python3
"""Heuristic disclosure scan; reports locations/counts, never secret contents."""
import json,re,sys
from pathlib import Path
from urllib.parse import urlsplit
root=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else Path(__file__).resolve().parents[1]
patterns={
 'personal_home_path':re.compile('/'+'Users/'+r'[^/\s"\x27\\<>]+'),
 'per_user_temp_path':re.compile('/'+'(?:private/)?var/folders/'+r'[^\s"\x27\\<>]+'),
 'credential_pattern':re.compile(r'(?:AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----)'),
 'email':re.compile(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'),
 'private_ipv4':re.compile(r'\b(?:10\.\d{1,3}\.\d{1,3}\.\d{1,3}|192\.168\.\d{1,3}\.\d{1,3}|172\.(?:1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3})\b')}
allowed={'developer.apple.com','www.swift.org','www.apache.org'}
findings=[]; hosts=set(); binary=[]; count=0
for p in sorted(root.rglob('*')):
 if not p.is_file() or any(x in p.relative_to(root).parts for x in ['.git','runs','__pycache__']):continue
 count+=1
 try:text=p.read_text()
 except UnicodeDecodeError:binary.append(str(p.relative_to(root)));continue
 if p.suffix=='.json':
  try:text=json.dumps(json.loads(text),ensure_ascii=False)
  except json.JSONDecodeError:pass
 for label,pattern in patterns.items():
  matches=list(pattern.finditer(text))
  if matches:findings.append(dict(path=str(p.relative_to(root)),kind=label,count=len(matches)))
 for url in re.findall(r'https?://[^\s"<>\)]+',text):
  host=urlsplit(url).hostname
  if host:hosts.add(host)
  if host and host not in allowed:findings.append(dict(path=str(p.relative_to(root)),kind='unreviewed_url_host',host=host,count=1))
print(json.dumps(dict(files_scanned=count,findings=findings,binary_files=binary,reviewed_public_hosts=sorted(hosts),limitations='Pattern scan plus source/provenance review; not proof of absence of secrets, ownership, or contractual restrictions. Approved copyright name is intentional public attribution.'),indent=2))
if findings or binary:sys.exit(1)
