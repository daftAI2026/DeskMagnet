# Tests/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/CLAUDE.md

成员清单
DeskMagnetAppTests/: Swift Testing App 层测试，覆盖本地化文案等不触碰 AppKit/Finder 的纯 UI 状态
DeskMagnetCoreTests/: Swift Testing 单元测试，覆盖脚本生成、坐标校验与 P0 恢复链路

测试法则:
先 RED 后 GREEN；真实 Finder 副作用用 ShellRunning 替身隔离，命令执行顺序必须可断言。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
