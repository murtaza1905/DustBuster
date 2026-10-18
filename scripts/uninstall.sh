#!/bin/bash
# DustBuster — uygulamayı ve kullanıcı verilerini tamamen kaldırır.
# Kullanım:  ./scripts/uninstall.sh
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

echo
log "$APP_NAME kaldırılıyor"
quit_running_app

for app in "/Applications/$APP_NAME.app" "/Applications/CleanerApp.app"; do
    if [[ -d "$app" ]]; then
        rm -rf "$app" && ok "Silindi: $app"
    fi
done

for id in "$BUNDLE_ID" "muratonurcu.CleanerApp"; do
    defaults delete "$id" >/dev/null 2>&1 && ok "Tercihler silindi: $id" || true
    rm -rf "$HOME/Library/Caches/$id" \
           "$HOME/Library/Saved Application State/$id.savedState" \
           "$HOME/Library/Preferences/$id.plist" \
           "$HOME/Library/HTTPStorages/$id" 2>/dev/null || true
done

ok "$APP_NAME tamamen kaldırıldı."
echo "Not: Sistem Ayarları › Tam Disk Erişimi listesindeki eski kayıt macOS tarafından otomatik temizlenmez; isterseniz oradan '-' ile kaldırabilirsiniz."
