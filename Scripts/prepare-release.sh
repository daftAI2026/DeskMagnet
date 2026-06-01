#!/usr/bin/env bash
#
# [INPUT]: 依赖 VERSION 与 docs/releases/，接收 SemVer 版本号参数。
# [OUTPUT]: 更新 VERSION，并创建对应 docs/releases/vX.Y.Z.md 模板。
# [POS]: Scripts 的发布准备入口，只同步版本文档，不创建 git tag，不触发 release 打包。
# [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Usage: Scripts/prepare-release.sh X.Y.Z" >&2
  exit 1
fi

TAG="v$VERSION"
NOTES="$ROOT/docs/releases/$TAG.md"

cd "$ROOT"
printf "%s\n" "$VERSION" > VERSION

if [[ ! -f "$NOTES" ]]; then
  cat > "$NOTES" <<EOF
# 桌面清理大师 $TAG

## 这版包含什么

-

## 下载和运行

下载 release 附件 \`Desktop-Cleaner.zip\`，解压后打开 \`桌面清理大师.app\`。

## 权限说明

首次真实清理时，macOS 会要求允许应用控制 Finder。这个权限用于读取和恢复桌面图标位置。

## 已知限制

- 仅支持 macOS。
- 当前是 ad-hoc signed build，没有 Developer ID 签名，也没有 notarization。
- 公开分发时，用户可能仍需要手动处理 macOS 安全提示。
- 本工具只调整 Finder 桌面图标显示位置，不处理真实文件内容。
EOF
fi

echo "$TAG"
