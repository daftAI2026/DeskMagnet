# Automation/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/Sources/DeskMagnetCore/CLAUDE.md

成员清单
AppleScriptEscaper.swift: AppleScript 字符串字面量转义，处理 Finder item 路径/名称中的引号与反斜杠
FinderIconController.swift: Finder 桌面图标 I/O，读取 JSON line 坐标、按 POSIX path 移动、校验多数坐标有效
FinderIconScript.swift: Finder AppleScript 构造器，生成 JSON 读取、路径移动、自由排列、退出 Finder 脚本
FinderSettingsManager.swift: Finder 偏好生命周期，导出快照、后台重启 Finder 进入兼容模式、恢复原始设置
ShellRunner.swift: 系统命令边界，封装 Process 执行并边运行边排空 stdout/stderr，允许测试替换

边界法则:
只有本目录触碰系统命令和 Finder AppleScript；上层只能调用协议或控制器。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
