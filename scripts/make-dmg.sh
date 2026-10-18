#!/bin/bash
# DustBuster — evrensel (Intel + Apple Silicon) .dmg üretir.
# Kullanım:  ./scripts/make-dmg.sh
# Çıktı:    dist/DustBuster-<sürüm>.dmg
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

DIST_DIR="$ROOT_DIR/dist"

echo
log "$APP_NAME DMG üretimi"
require_xcode
resolve_xcodegen
generate_project
build_release
sign_app

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
DMG_NAME="$APP_NAME-$VERSION.dmg"
STAGING="$BUILD_DIR/dmg-staging"

rm -rf "$STAGING" && mkdir -p "$STAGING" "$DIST_DIR"
cp -R "$APP_PATH" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

rm -f "$DIST_DIR/$DMG_NAME"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING" -ov -format UDZO "$DIST_DIR/$DMG_NAME" >/dev/null \
    || die "hdiutil DMG oluşturamadı."

ok "DMG hazır: $DIST_DIR/$DMG_NAME"
echo "GitHub'da yayınlamak için: Releases › New release › tag v$VERSION › bu dosyayı sürükleyin."
