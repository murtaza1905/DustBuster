#!/bin/bash
# DustBuster — evrensel (arm64 + x86_64) Release derlemesi yapar ve imzalar.
# Kurulum yapmaz; kurmak ve başlatmak için ./scripts/install.sh kullanın.
#
# Kullanım:  ./scripts/build.sh
# Çıktı:    build/DustBuster.app  (DUSTBUSTER_SIGN_IDENTITY verilmemişse ad-hoc imzalı)
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

echo
log "$APP_NAME derlemesi"
require_xcode
resolve_xcodegen
generate_project
build_release
sign_app

rm -rf "$BUILD_DIR/$APP_NAME.app"
ditto "$APP_PATH" "$BUILD_DIR/$APP_NAME.app"
ok "Hazır: build/$APP_NAME.app ($(lipo -archs "$BUILD_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME"))"
