"""Read-only release preflight. Never prints credentials or uploads artifacts."""
import json
from pathlib import Path
import re
import sys
from urllib.parse import urlsplit

app = Path(__file__).resolve().parents[1]
blockers = []
config_path = app / 'release/production.json'
config = json.loads(config_path.read_text()) if config_path.is_file() else {}
for key in ('API_BASE_URL', 'SOCKET_BASE_URL'):
    try:
        url = urlsplit(config.get(key, ''))
        host = url.hostname or ''
        valid = (url.scheme == 'https' and '.' in host and ':' not in host
                 and not re.fullmatch(r'[0-9.]+', host)
                 and host != 'localhost' and host != 'example.com'
                 and not host.endswith(('.localhost', '.local', '.test', '.invalid', '.example', '.example.com'))
                 and not url.username and not url.password and not url.query and not url.fragment
                 and (key != 'API_BASE_URL' or url.path.endswith('/api')))
    except (ValueError, TypeError):
        valid = False
    if not valid:
        blockers.append(f'{key}: configure an actual public HTTPS production endpoint.')

signing_path = app / 'android/key.properties'
signing = {}
if signing_path.is_file():
    for line in signing_path.read_text().splitlines():
        if '=' in line and not line.lstrip().startswith(('#', '!')):
            key, value = line.split('=', 1)
            signing[key.strip()] = value.strip()
if not all(signing.get(key) for key in ('storeFile', 'storePassword', 'keyAlias', 'keyPassword')):
    blockers.append('Upload signing: android/key.properties is absent or incomplete.')
elif not (app / 'android' / signing['storeFile']).is_file():
    blockers.append('Upload signing: configured keystore file is missing.')
elif signing['keyAlias'] == 'androiddebugkey':
    blockers.append('Upload signing: debug key is forbidden for release.')

# Heuristic source scan only. Report locations, never matched values.
patterns = {
    'private key': r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    'AWS access key': r'\bAKIA[0-9A-Z]{16}\b',
    'Google API key': r'\bAIza[0-9A-Za-z_-]{35}\b',
    'literal secret': r'''(?i)(?:api_key|apiKey|client_secret|secret)\s*[:=]\s*['"][^'"\s]{16,}['"]''',
}
scanned = 0
for directory in (app / 'lib', app / 'android/app/src'):
    for path in directory.rglob('*'):
        if path.suffix not in ('.dart', '.kt', '.java', '.xml', '.json'):
            continue
        scanned += 1
        text = path.read_text(encoding='utf-8')
        for label, pattern in patterns.items():
            if re.search(pattern, text):
                blockers.append(f'Review possible {label}: {path.relative_to(app)} (value redacted).')
print(f'Scanned {scanned} application source/configuration files for selected secret patterns.')
print('This is not a complete secret audit, TLS check, signing verification or device test.')
if blockers:
    print('RELEASE BLOCKED')
    for blocker in blockers:
        print(f'- {blocker}')
    sys.exit(1)
print('Local configuration preflight passed; complete the production checklist before release.')
