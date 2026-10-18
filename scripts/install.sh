#!/bin/bash
# DustBuster — hub kurulum scripti.
#
#   ./scripts/install.sh                      → GitHub'dan son kodu çek, sıfırdan derle,
#                                               releases/ altına arşivle, /Applications'taki
#                                               eski sürümü kaldırıp yenisini kur ve aç.
#   ./scripts/install.sh releases/<dosya>.zip → derlemeden, arşivdeki o sürümü kur.
#   ./scripts/install.sh --list               → saklanan sürümleri listele.
#
# İsteğe bağlı ortam değişkenleri:
#   DUSTBUSTER_NO_PULL=1                      → git pull adımını atla
#   DUSTBUSTER_SIGN_IDENTITY="Apple Development: Ad Soyad (TEAMID)" → kalıcı imza
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

echo
case "${1:-}" in
    --list|-l)
        log "Saklanan sürümler (releases/):"
        if [[ -d "$RELEASES_DIR" ]] && ls -1 "$RELEASES_DIR"/*.zip >/dev/null 2>&1; then
            ls -1t "$RELEASES_DIR"/*.zip | sed "s|$RELEASES_DIR/|  |"
        else
            echo "  (henüz yok)"
        fi
        exit 0
        ;;
    "")
        log "$APP_NAME güncelleme ve sıfırdan kurulum"
        require_xcode
        pull_latest
        resolve_xcodegen
        generate_project
        build_release
        sign_app
        archive_release
        ;;
    *)
        log "$APP_NAME — arşivden kurulum"
        unpack_release "$1"
        ;;
esac

install_app

cat <<EOF

────────────────────────────────────────────────────────────
 $APP_NAME kuruldu ve açıldı.

 Tam Disk Erişimi gerekiyor (her yeni kurulumda yeniden):
   1. Sistem Ayarları › Gizlilik ve Güvenlik › Tam Disk Erişimi
   2. "+" ile /Applications/$APP_NAME.app dosyasını ekleyin (veya listedeki anahtarı açın)
   3. $APP_NAME penceresine geri dönün — durum otomatik güncellenir

 Ayarları doğrudan açmak için:
   open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"

 Saklanan sürümler:  ./scripts/install.sh --list
 Eski sürüme dönüş:  ./scripts/install.sh releases/<dosya>.zip
────────────────────────────────────────────────────────────
EOF
