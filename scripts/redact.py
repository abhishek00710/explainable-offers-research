#!/usr/bin/env python3
"""Remove personal home and per-user temporary paths, preserving numerical results."""
import re

def redact(text):
    text = re.sub('/'+'Users/'+r'[^/\s"\x27\\<>]+', '<USER_HOME>', text)
    text = re.sub('/'+'(?:private/)?var/folders/'+r'[^\s"\x27\\<>]+', '<TEMP_PATH>', text)
    return text
