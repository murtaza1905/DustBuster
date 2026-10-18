#!/bin/bash
# DustBuster — tek komutla derle, /Applications'a kur ve başlat.
# Kullanım:  ./scripts/install.sh
# İsteğe bağlı: DUSTBUSTER_SIGN_IDENTITY="Apple Development: Ad Soyad (TEAMID)" ./scripts/install.sh
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

INSTALL_PATH="/Applications/$APP_NAME.app"

echo
log "$APP_NAME kurulumu"
require_xcode
resolve_xcodegen
generate_project
build_release
sign_app

quit_running_app
log "/Applications içine kopyalanıyor..."
if [[ -d "$INSTALL_PATH" ]]; then
    rm -rf "$INSTALL_PATH" || die "Eski sürüm silinemedi: $INSTALL_PATH"
fi
# Eski adla kurulmuş sürüm varsa kaldır
if [[ -d "/Applications/CleanerApp.app" ]]; then
    warn "Eski 'CleanerApp.app' bulundu, kaldırılıyor."
    rm -rf "/Applications/CleanerApp.app" || true
fi
cp -R "$APP_PATH" "$INSTALL_PATH" || die "/Applications içine kopyalanamadı (yetki?)."
xattr -dr com.apple.quarantine "$INSTALL_PATH" 2>/dev/null || true
ok "Kuruldu: $INSTALL_PATH"

log "Başlatılıyor..."
open "$INSTALL_PATH"

cat <<EOF

────────────────────────────────────────────────────────────
 $APP_NAME kuruldu ve açıldı.

 Tam Disk Erişimi gerekiyor:
   1. Sistem Ayarları › Gizlilik ve Güvenlik › Tam Disk Erişimi
   2. "+" ile /Applications/$APP_NAME.app dosyasını ekleyin (veya listedeki anahtarı açın)
   3. $APP_NAME penceresine geri dönün — durum otomatik güncellenir

 Ayarları doğrudan açmak için:
   open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
────────────────────────────────────────────────────────────
EOF
