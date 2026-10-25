#!/bin/bash
# DustBuster — dağıtım için disk imajı üretir.
#
# Kullanım:
#   ./scripts/make-dmg.sh              önce derler (scripts/build.sh), sonra paketler
#   ./scripts/make-dmg.sh --app YOL    derlenmiş bir DustBuster.app'i paketler
#
# Çıktı: dist/DustBuster-<sürüm>.dmg
# Pencere düzeni için create-dmg (https://github.com/create-dmg/create-dmg) kuruluysa
# onu kullanır; yoksa düz hdiutil imajına düşer.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

DIST_DIR="$ROOT_DIR/dist"
APP=""

while [ $# -gt 0 ]; do
    case "$1" in
        --app) APP="$2"; shift 2 ;;
        *) die "Bilinmeyen seçenek: $1" ;;
    esac
done

if [ -z "$APP" ]; then
    "$ROOT_DIR/scripts/build.sh"
    APP="$BUILD_DIR/$APP_NAME.app"
fi
[ -d "$APP" ] || die "Uygulama paketi bulunamadı: $APP"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")"
DMG="$DIST_DIR/$APP_NAME-$VERSION.dmg"
STAGING="$BUILD_DIR/dmg-staging"
ICON="$APP/Contents/Resources/AppIcon.icns"

echo
log "$APP_NAME-$VERSION.dmg üretiliyor"
rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING" "$DIST_DIR"
cp -R "$APP" "$STAGING/$APP_NAME.app"

if command -v create-dmg >/dev/null 2>&1; then
    args=(
        --volname "$APP_NAME $VERSION"
        --window-pos 200 120
        --window-size 660 400
        --icon-size 128
        --text-size 14
        --icon "$APP_NAME.app" 180 170
        --hide-extension "$APP_NAME.app"
        --app-drop-link 480 170
        --no-internet-enable
    )
    [ -f "$ICON" ] && args+=(--volicon "$ICON")
    if ! create-dmg "${args[@]}" "$DMG" "$STAGING"; then
        warn "create-dmg başarısız oldu; hdiutil ile devam ediliyor."
        rm -f "$DMG"
    fi
fi

if [ ! -f "$DMG" ]; then
    ln -sfn /Applications "$STAGING/Applications"
    hdiutil create -volname "$APP_NAME $VERSION" -srcfolder "$STAGING" -ov -format UDZO "$DMG" >/dev/null \
        || die "hdiutil DMG oluşturamadı."
fi

rm -rf "$STAGING"
ok "DMG hazır: dist/$APP_NAME-$VERSION.dmg"
echo "Yayınlamak için: git tag v$VERSION && git push origin v$VERSION  (Release workflow DMG'yi kendisi üretir ve yayınlar)"
