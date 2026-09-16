"""Portable iOS configuration checks. Does not substitute for Xcode/device tests."""
import json
from pathlib import Path
import plistlib
import struct
import xml.etree.ElementTree as ET

app = Path(__file__).resolve().parents[1]
ios = app / 'ios'
with (ios / 'Runner/Info.plist').open('rb') as source:
    info = plistlib.load(source)
for key in ('NSCameraUsageDescription', 'NSMicrophoneUsageDescription',
            'NSPhotoLibraryUsageDescription', 'NSLocalNetworkUsageDescription'):
    assert info.get(key, '').strip(), f'Missing purpose string: {key}'
assert not info.get('NSAppTransportSecurity', {}).get('NSAllowsArbitraryLoads', False)
assert info['UIBackgroundModes'] == ['audio'], 'Only active live audio is configured'
with (ios / 'Runner/Runner.entitlements').open('rb') as source:
    entitlements = plistlib.load(source)
assert entitlements['keychain-access-groups'] == [
    '$(AppIdentifierPrefix)$(PRODUCT_BUNDLE_IDENTIFIER)']
assert 'aps-environment' not in entitlements, 'APNs backend is not implemented'
project = (ios / 'Runner.xcodeproj/project.pbxproj').read_text()
assert project.count('CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;') == 3
assert project.count('PRODUCT_BUNDLE_IDENTIFIER = com.tryhub.tryhubApp;') == 3
assert project.count('IPHONEOS_DEPLOYMENT_TARGET = 13.0;') == 3
for config in ('Debug', 'Release'):
    text = (ios / f'Flutter/{config}.xcconfig').read_text()
    assert '#include "Generated.xcconfig"' in text
    assert '#include? "Signing.xcconfig"' in text
ET.parse(ios / 'Runner/Base.lproj/LaunchScreen.storyboard')
icons = ios / 'Runner/Assets.xcassets/AppIcon.appiconset'
catalog = json.loads((icons / 'Contents.json').read_text())
for entry in catalog['images']:
    data = (icons / entry['filename']).read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n'
    width, height, depth, color = struct.unpack('>IIBB', data[16:26])
    expected = int(float(entry['size'].split('x')[0]) * int(entry['scale'][:-1]))
    assert width == height == expected, entry['filename']
    assert depth == 8 and color == 2, f'Icon must be opaque RGB: {entry["filename"]}'
print(f'iOS configuration checks passed; {len(catalog["images"])} icon slots verified.')
