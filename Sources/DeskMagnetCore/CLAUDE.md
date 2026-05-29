# DeskMagnetCore/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Sources/CLAUDE.md

成员清单
AppleScriptEscaper.swift: AppleScript 字符串字面量转义，处理 Finder item 名称中的引号与反斜杠
FinderIconController.swift: Finder 桌面图标 I/O，读取 item 坐标、批量移动、校验多数坐标有效
FinderIconScript.swift: Finder AppleScript 构造器，生成读取、移动、自由排列、退出 Finder 脚本
FinderSettingsManager.swift: Finder 偏好生命周期，导出快照、进入兼容模式、恢复原始设置
Models.swift: 领域数据模型，定义 Point、DesktopItem、IconMove、P0Snapshot、DeskMagnetError
P0Workflow.swift: P0 技术验证编排，串联兼容模式、读取、移动、恢复
ShellRunner.swift: 系统命令边界，封装 Process 执行并允许测试替换

模块法则:
真实副作用集中在 ShellRunner；AppleScript 文本生成保持纯函数；P0Workflow 只编排，不拼脚本，不解析输出。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
