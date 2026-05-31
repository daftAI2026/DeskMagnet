# workflows/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/.github/CLAUDE.md

成员清单
build.yml: GitHub Actions 主工作流，push/PR 跑 SwiftPM build+test，workflow_dispatch 或 v* tag 复用 Scripts/build-app.sh 生成 signed 桌面清理大师.app zip artifact，并在 tag 构建后发布 GitHub Release

依赖边界:
workflow 只调用 SwiftPM 和仓库脚本；`.app` 结构、Info.plist、签名和验证必须留在 `Scripts/build-app.sh`。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
