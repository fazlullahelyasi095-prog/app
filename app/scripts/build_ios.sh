#!/bin/sh
# Invoke from any directory on the Mac that owns the iOS signing environment.
set -eu
mode=${1:-help}
case "$mode" in
  simulator|unsigned|ipa) ;;
  *) echo 'Usage: API_BASE_URL=https://host/api SOCKET_BASE_URL=https://host sh scripts/build_ios.sh simulator|unsigned|ipa'; exit 0 ;;
esac
if [ "$(uname -s)" != Darwin ]; then
  echo 'iOS compilation requires macOS and Xcode.' >&2
  exit 1
fi
: "${API_BASE_URL:?Set the existing TryHub HTTPS API URL ending in /api}"
: "${SOCKET_BASE_URL:?Set the existing TryHub HTTPS Socket.io origin}"
case "$API_BASE_URL" in https://*/api) ;; *) echo 'API_BASE_URL must use HTTPS and end in /api.' >&2; exit 1 ;; esac
case "$SOCKET_BASE_URL" in https://?*) ;; *) echo 'SOCKET_BASE_URL must use HTTPS.' >&2; exit 1 ;; esac
cd "$(dirname "$0")/.."
python3 scripts/verify_ios.py
flutter pub get
case "$mode" in
  simulator) set -- build ios --simulator --debug ;;
  unsigned) set -- build ios --release --no-codesign ;;
  ipa) set -- build ipa --release ;;
esac
flutter "$@" "--dart-define=API_BASE_URL=$API_BASE_URL" "--dart-define=SOCKET_BASE_URL=$SOCKET_BASE_URL"
