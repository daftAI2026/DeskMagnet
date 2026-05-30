#!/usr/bin/env bash
#
# [INPUT]: 依赖 SwiftPM release 构建产物与 Assets/AppIcon/DeskMagnet.icns。
# [OUTPUT]: 生成 ad-hoc signed build/DeskMagnet.app，并验证 bundle 签名。
# [POS]: Scripts 的 macOS App 打包入口，供本地与 GitHub Actions runner 复用。
# [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT/build/DeskMagnet.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

cd "$ROOT"
swift build -c release --product DeskMagnetApp

rm -rf "$APP_DIR"
mkdir -p "$MACOS" "$RESOURCES"
cp ".build/release/DeskMagnetApp" "$MACOS/DeskMagnet"
cp "Assets/AppIcon/DeskMagnet.icns" "$RESOURCES/DeskMagnet.icns"

cat > "$CONTENTS/Info.plist" <<'PLIST'
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
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>NSAppleEventsUsageDescription</key>
  <string>DeskMagnet 需要控制 Finder 来读取和恢复桌面图标位置。</string>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP_DIR"
codesign --verify --deep --strict --verbose=2 "$APP_DIR"

echo "$APP_DIR"
