#!/bin/bash
# Ortak yardımcılar — install.sh ve make-dmg.sh tarafından kaynak olarak yüklenir.

APP_NAME="DustBuster"
BUNDLE_ID="com.muratonurcu.DustBuster"
SCHEME="DustBuster"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
TOOLS_DIR="$ROOT_DIR/.tools"
RELEASES_DIR="$ROOT_DIR/releases"
INSTALL_PATH="/Applications/$APP_NAME.app"
XCODEGEN_ZIP_URL="https://github.com/yonaskolb/XcodeGen/releases/latest/download/xcodegen.zip"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✔\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m✖ %s\033[0m\n' "$*" >&2; exit 1; }

require_xcode() {
    if ! xcode-select -p >/dev/null 2>&1; then
        die "Xcode bulunamadı. App Store'dan Xcode'u kurun, bir kez açıp lisansı kabul edin, sonra tekrar deneyin."
    fi
    if ! xcodebuild -version >/dev/null 2>&1; then
        die "xcodebuild çalışmıyor. Şu komutu çalıştırın:  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    fi
    if ! xcrun swift --version >/dev/null 2>&1; then
        die "Swift derleyicisi bulunamadı. Xcode'u bir kez açıp 'Install additional components' adımını tamamlayın."
    fi
    ok "Xcode: $(xcodebuild -version | head -1)"
}

# XcodeGen'i bulur; yoksa Homebrew olmadan GitHub'dan indirir.
resolve_xcodegen() {
    if command -v xcodegen >/dev/null 2>&1; then
        XCODEGEN="$(command -v xcodegen)"
        ok "XcodeGen: $XCODEGEN"
        return
    fi
    local local_bin="$TOOLS_DIR/xcodegen/bin/xcodegen"
    if [[ -x "$local_bin" ]]; then
        XCODEGEN="$local_bin"
        ok "XcodeGen (yerel): $XCODEGEN"
        return
    fi
    log "XcodeGen bulunamadı, indiriliyor..."
    mkdir -p "$TOOLS_DIR"
    curl -fsSL "$XCODEGEN_ZIP_URL" -o "$TOOLS_DIR/xcodegen.zip" || die "XcodeGen indirilemedi. İnternet bağlantısını kontrol edin."
    rm -rf "$TOOLS_DIR/xcodegen"
    unzip -qo "$TOOLS_DIR/xcodegen.zip" -d "$TOOLS_DIR" || die "XcodeGen arşivi açılamadı."
    rm -f "$TOOLS_DIR/xcodegen.zip"
    [[ -x "$local_bin" ]] || die "XcodeGen ikilisi beklenen konumda değil: $local_bin"
    xattr -dr com.apple.quarantine "$TOOLS_DIR/xcodegen" 2>/dev/null || true
    XCODEGEN="$local_bin"
    ok "XcodeGen indirildi: $XCODEGEN"
}

generate_project() {
    log "Xcode projesi üretiliyor (project.yml → $APP_NAME.xcodeproj)"
    (cd "$ROOT_DIR" && "$XCODEGEN" generate --quiet) || die "XcodeGen proje üretemedi."
    ok "$APP_NAME.xcodeproj hazır"
}

# Release derleme — evrensel (arm64 + x86_64), imzasız; imza sonradan atılır.
build_release() {
    log "Release derlemesi başlıyor (arm64 + x86_64)..."
    rm -rf "$BUILD_DIR"
    (cd "$ROOT_DIR" && xcodebuild \
        -project "$APP_NAME.xcodeproj" \
        -scheme "$SCHEME" \
        -configuration Release \
        -derivedDataPath "$BUILD_DIR" \
        ARCHS="arm64 x86_64" \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGNING_REQUIRED=NO \
        DEVELOPMENT_TEAM="" \
        build 2>&1 | tee "$BUILD_DIR.log" | grep -E "error:|warning: unre|BUILD (SUCCEEDED|FAILED)" || true)
    APP_PATH="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"
    [[ -d "$APP_PATH" ]] || die "Derleme başarısız. Tam log: $BUILD_DIR.log"
    ok "Derlendi: $APP_PATH"
}

# İmzalama: DUSTBUSTER_SIGN_IDENTITY verilmişse onu, yoksa ad-hoc ("-") kullanır.
sign_app() {
    local identity="${DUSTBUSTER_SIGN_IDENTITY:--}"
    if [[ "$identity" == "-" ]]; then
        log "Ad-hoc imzalanıyor (Tam Disk Erişimi her yeniden kurulumda yeniden verilmelidir)"
    else
        log "İmzalanıyor: $identity"
    fi
    codesign --force --deep --options runtime --sign "$identity" "$APP_PATH" || die "codesign başarısız."
    codesign --verify --deep --strict "$APP_PATH" || die "İmza doğrulanamadı."
    ok "İmza tamam"
}

quit_running_app() {
    if pgrep -x "$APP_NAME" >/dev/null 2>&1; then
        log "Çalışan $APP_NAME kapatılıyor..."
        osascript -e "tell application \"$APP_NAME\" to quit" >/dev/null 2>&1 || pkill -x "$APP_NAME" || true
        sleep 1
    fi
}

# Hub bir git deposuysa son kodu çeker. DUSTBUSTER_NO_PULL=1 ile atlanır.
pull_latest() {
    if [[ -n "${DUSTBUSTER_NO_PULL:-}" ]]; then
        warn "git pull atlandı (DUSTBUSTER_NO_PULL)"
        return
    fi
    if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        warn "Bu klasör bir git deposu değil; güncelleme çekilmedi, mevcut kod derlenecek."
        return
    fi
    if [[ -n "$(git -C "$ROOT_DIR" status --porcelain --untracked-files=no)" ]]; then
        die "Hub'da kaydedilmemiş değişiklik var; git pull güvenli değil. Önce 'git -C $ROOT_DIR status' ile kontrol edin veya DUSTBUSTER_NO_PULL=1 ile derleyin."
    fi
    log "GitHub'dan son kod çekiliyor..."
    git -C "$ROOT_DIR" pull --ff-only --quiet || die "git pull başarısız. İnternet bağlantısını veya dal durumunu kontrol edin."
    ok "Kod güncel: $(git -C "$ROOT_DIR" log -1 --format='%h %s')"
}

# Derlenen uygulamayı releases/ altına tarihli zip olarak arşivler. Hiçbir sürüm silinmez.
archive_release() {
    mkdir -p "$RELEASES_DIR"
    local version build stamp hash name
    version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
    build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP_PATH/Contents/Info.plist")"
    stamp="$(date +%Y%m%d-%H%M)"
    hash="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || echo nogit)"
    name="$APP_NAME-$version-$build-$stamp-$hash.zip"
    ditto -c -k --keepParent "$APP_PATH" "$RELEASES_DIR/$name" || die "Arşivleme başarısız."
    RELEASE_ZIP="$RELEASES_DIR/$name"
    ok "Arşivlendi: releases/$name"
}

# Verilen .zip (releases/ içinden) veya .app yolunu APP_PATH olarak hazırlar.
unpack_release() {
    local src="$1"
    [[ -e "$src" ]] || die "Bulunamadı: $src"
    if [[ "$src" == *.app && -d "$src" ]]; then
        APP_PATH="$src"
    elif [[ "$src" == *.zip ]]; then
        local tmp="$BUILD_DIR/unpack"
        rm -rf "$tmp" && mkdir -p "$tmp"
        ditto -x -k "$src" "$tmp" || die "Arşiv açılamadı: $src"
        APP_PATH="$tmp/$APP_NAME.app"
        [[ -d "$APP_PATH" ]] || die "Arşivde $APP_NAME.app yok: $src"
    else
        die "Desteklenmeyen dosya: $src (.zip veya .app bekleniyor)"
    fi
    ok "Kurulacak sürüm: $(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist") — $src"
}

# /Applications'taki eski sürümü kaldırır, yenisini kopyalar ve açar.
install_app() {
    quit_running_app
    log "/Applications içindeki eski sürüm kaldırılıyor, yenisi kuruluyor..."
    if [[ -d "$INSTALL_PATH" ]]; then
        rm -rf "$INSTALL_PATH" || die "Eski sürüm silinemedi: $INSTALL_PATH"
    fi
    if [[ -d "/Applications/CleanerApp.app" ]]; then
        warn "Eski 'CleanerApp.app' bulundu, kaldırılıyor."
        rm -rf "/Applications/CleanerApp.app" || true
    fi
    cp -R "$APP_PATH" "$INSTALL_PATH" || die "/Applications içine kopyalanamadı (yetki?)."
    xattr -dr com.apple.quarantine "$INSTALL_PATH" 2>/dev/null || true
    ok "Kuruldu: $INSTALL_PATH"
    log "Başlatılıyor..."
    open "$INSTALL_PATH"
}
