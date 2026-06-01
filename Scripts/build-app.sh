#!/usr/bin/env bash
#
# [INPUT]: 依赖 VERSION、SwiftPM release 构建产物与 Assets/AppIcon/DeskMagnet.icns。
# [OUTPUT]: 生成带本地化 InfoPlist.strings 的 ad-hoc signed build/桌面清理大师.app，并验证 bundle 签名。
# [POS]: Scripts 的 macOS App 打包入口，供本地与 GitHub Actions runner 复用。
# [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT/build/桌面清理大师.app"
LEGACY_APP_DIR="$ROOT/build/DeskMagnet.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"
VERSION_FILE="$ROOT/VERSION"

cd "$ROOT"
APP_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
if [[ ! "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid VERSION: $APP_VERSION" >&2
  exit 1
fi

swift build -c release --product DeskMagnetApp

rm -rf "$APP_DIR" "$LEGACY_APP_DIR"
mkdir -p "$MACOS" "$RESOURCES"
cp ".build/release/DeskMagnetApp" "$MACOS/DeskMagnet"
cp "Assets/AppIcon/DeskMagnet.icns" "$RESOURCES/DeskMagnet.icns"

cat > "$CONTENTS/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>DeskMagnet</string>
  <key>CFBundleIdentifier</key>
  <string>cool.sofxcking.deskmagnet</string>
  <key>CFBundleName</key>
  <string>桌面清理大师</string>
  <key>CFBundleDisplayName</key>
  <string>桌面清理大师</string>
  <key>CFBundleIconFile</key>
  <string>DeskMagnet</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${APP_VERSION}</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>NSAppleEventsUsageDescription</key>
  <string>DeskMagnet 需要控制 Finder 来读取和恢复桌面图标位置。</string>
</dict>
</plist>
PLIST

write_info_plist_strings() {
  local locale="$1"
  local display_name="$2"
  local permission="$3"
  local locale_dir="$RESOURCES/$locale.lproj"
  mkdir -p "$locale_dir"
  cat > "$locale_dir/InfoPlist.strings" <<STRINGS
CFBundleName = "$display_name";
CFBundleDisplayName = "$display_name";
NSAppleEventsUsageDescription = "$permission";
STRINGS
}

write_info_plist_strings "en" "Desktop Cleaner" "Desktop Cleaner needs to control Finder to read and restore desktop icon positions."
write_info_plist_strings "zh-Hans" "桌面清理大师" "桌面清理大师需要控制 Finder 来读取和恢复桌面图标位置。"
write_info_plist_strings "ja" "デスクトップクリーナー" "デスクトップクリーナーはデスクトップ項目の位置を読み取り、復元するためにFinderを制御する必要があります。"
write_info_plist_strings "zh-Hant" "桌面清理大師" "桌面清理大師需要控制 Finder 來讀取和恢復桌面圖示位置。"
write_info_plist_strings "es" "Limpiador de escritorio" "Limpiador de escritorio necesita controlar Finder para leer y restaurar la posición de los iconos del escritorio."
write_info_plist_strings "fr" "Nettoyeur de bureau" "Nettoyeur de bureau doit contrôler Finder pour lire et restaurer la position des icônes du bureau."
write_info_plist_strings "pt" "Limpador de Desktop" "O Limpador de Desktop precisa controlar o Finder para ler e restaurar as posições dos ícones do Desktop."
write_info_plist_strings "ko" "데스크톱 클리너" "데스크톱 클리너가 데스크톱 항목 위치를 읽고 복원하려면 Finder 제어 권한이 필요합니다."
write_info_plist_strings "de" "Desktop Cleaner" "Desktop Cleaner muss Finder steuern, um die Positionen der Desktop-Symbole zu lesen und wiederherzustellen."
write_info_plist_strings "hi" "डेस्कटॉप क्लीनर" "डेस्कटॉप आइटम की स्थिति पढ़ने और वापस लाने के लिए डेस्कटॉप क्लीनर को Finder नियंत्रित करना होगा।"

codesign --force --deep --sign - "$APP_DIR"
codesign --verify --deep --strict --verbose=2 "$APP_DIR"

echo "$APP_DIR"
