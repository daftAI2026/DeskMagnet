# DeskMagnet - macOS Finder desktop icon magnet
Swift Package + Swift CLI + Finder AppleScript automation

<directory>
docs/ - 产品规格与参考素材 (1子目录: reference)
</directory>
<directory>
Sources/ - Swift 生产代码入口 (2子目录: DeskMagnetCore, DeskMagnetCLI)
</directory>
<directory>
Tests/ - Swift Testing 测试代码 (1子目录: DeskMagnetCoreTests)
</directory>

<config>
`.gitignore` - 忽略 SwiftPM 构建产物、macOS 元数据与 Xcode 用户状态
Package.swift - SwiftPM 包定义，暴露 DeskMagnetCore library 与 deskmagnet executable
</config>

架构决策:
P0 先做命令行验证器，不做 UI；Finder 真实副作用被 ShellRunning 隔离，纯脚本生成与状态判断可测试；恢复链路优先于移动链路，任何失败都尝试恢复 Finder 设置。

开发规范:
生产文件必须带 L3 INPUT/OUTPUT/POS 头部；新增、删除、改名模块后同步本文件与对应 L2 CLAUDE.md；真实 Finder 流程只通过 `deskmagnet p0 --yes` 显式触发。

变更日志:
2026-05-30: 播种 SwiftPM P0 验证器，建立 DeskMagnetCore/DeskMagnetCLI/Tests 分形文档，并忽略本地构建产物。

法则: 极简·稳定·导航·版本精确
