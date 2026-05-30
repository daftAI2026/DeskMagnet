# DeskMagnet - macOS Finder desktop icon magnet
Swift Package + Swift CLI + Finder AppleScript automation

<directory>
Assets/ - 应用视觉资产 (1子目录: AppIcon)
</directory>
<directory>
docs/ - 产品规格与参考素材 (1子目录: reference)
</directory>
<directory>
Scripts/ - 构建脚本 (1文件: build-app.sh)
</directory>
<directory>
Sources/ - Swift 生产代码入口 (3子目录: DeskMagnetApp, DeskMagnetCore, DeskMagnetCLI)
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
2026-05-30: 接入清扫 glyph 作为 DeskMagnet canonical app icon，保存 SVG 源与 macOS `.icns` 产物。
2026-05-30: 增加 P1 macOS App 外壳、状态恢复编排、窗口拖动跟随与 `.app` 构建脚本；DeskMagnetCore 拆分 Automation/Coordination/State，根目录不堆文件。
2026-05-30: 完成 P2 体验优化，加入确定性随机堆叠、多显示器边界、图标数量分级策略、恢复详情和 UI 文案打磨。
2026-05-30: 修正 Finder/AppKit 坐标系差异，窗口放大到双倍规格，UI 回归“桌面清理大师”清理工具伪装。
2026-05-30: 将图标吸附模型从窗口外下方改为窗口 X/Y 投影内，利用桌面层天然处于窗口后方的 Z 轴关系隐藏图标。
2026-05-30: 收紧图标隐藏安全区并固定主窗口 800x520，避免标题栏、圆角边缘和缩放动作暴露桌面图标。
2026-05-30: 将 App 外观固定为 Aqua 亮色，重塑 ContentView 为浅色工具面板，移除黑底与霓虹色状态。

法则: 极简·稳定·导航·版本精确
