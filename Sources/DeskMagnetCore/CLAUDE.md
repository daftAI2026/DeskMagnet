# DeskMagnetCore/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Sources/CLAUDE.md

成员清单
Automation/: Finder 自动化边界，封装 AppleScript 生成、osascript/defaults/open/pgrep 执行、JSON 图标读取与路径移动
Coordination/: 流程编排，承载 P0Workflow 与 P1 AppCoordinator，负责恢复跳过统计与损坏状态探测
State/: 领域模型、恢复状态存储、纯布局计算、路径移动身份与图标数量性能策略

模块法则:
真实副作用集中在 ShellRunner；AppleScript 文本生成保持纯函数；流程层只编排，不拼脚本，不解析输出。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
