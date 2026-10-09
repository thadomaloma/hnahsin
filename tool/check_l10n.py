"""Checks l10n/<code>.json against the app's English texts (from
tool/l10n_english.dart): every id there, no unknown ids, and the same
{placeholders}. Run it after adding a text to the app.

    python3 tool/check_l10n.py
"""
import glob
import json
import os
import re
import subprocess
import sys

ph = lambda s: sorted(set(re.findall(r'\{(\w+)\}', s)))
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
output = subprocess.run(['dart', 'run', 'tool/l10n_english.dart'], cwd=ROOT, capture_output=True, text=True, check=True).stdout
english = json.loads(output[output.index('{'):])
ok = True
for path in sorted(glob.glob(os.path.join(ROOT, 'l10n', '*.json'))):
    code = os.path.basename(path)[:-5]
    texts = json.load(open(path, encoding='utf-8'))
    missing = [k for k in english if k not in texts]
    extra = [k for k in texts if k not in english]
    wrong = [k for k in english if k in texts and ph(texts[k]) != ph(english[k])]
    if missing or extra or wrong:
        ok = False
    print(code, len(texts), 'missing', missing[:8], 'extra', extra[:8], 'placeholders', wrong[:8])
sys.exit(0 if ok else 1)
