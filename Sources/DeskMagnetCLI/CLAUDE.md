# DeskMagnetCLI/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Sources/CLAUDE.md

成员清单
main.swift: deskmagnet 入口，要求 `p0 --yes` 或 `p1 --yes` 才触发真实 Finder 桌面验证

模块法则:
CLI 只做参数门禁和结果呈现，不承载 Finder 操作细节；P1 验证必须走 AppCoordinator。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
