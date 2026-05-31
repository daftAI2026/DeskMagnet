# Scripts/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/CLAUDE.md

成员清单
build-app.sh: 构建 release 可执行文件并组装 ad-hoc signed 桌面清理大师.app，从 VERSION 写入 Info.plist 版本号并验证 bundle 签名
prepare-release.sh: 更新 VERSION 并创建对应 docs/releases/vX.Y.Z.md 模板，不创建 tag、不触发打包

脚本法则:
脚本只做可重复构建，不隐藏业务逻辑；App 行为必须留在 Sources。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
