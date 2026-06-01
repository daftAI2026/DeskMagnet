# Changelog

## 1.1.0 - 2026-06-01

### Added

- 扩展 App、菜单和权限提示本地化：新增 Español、Français、Português、Deutsch、हिन्दी，并保留 English、简体中文、日本語、繁體中文、한국어。
- 打包产物生成十种语言的 `InfoPlist.strings`，让 macOS 自动化权限弹窗跟随本地化 App 名和权限说明。
- 增加本地化回归测试，约束语言菜单顺序、CJK 主标题断行、单复数和自然的“桌面图标/項目/항목”语义。

### Changed

- 英文展示名从 `Desktop Cleanup Master` 调整为 `Desktop Cleaner`。
- Core 性能策略只暴露提示类型，用户可见的大量图标提示统一由 App 本地化层渲染。
- 发布下载包统一为 `Desktop-Cleaner.zip`，避免 GitHub Release 对中文 asset 文件名的归一化导致显示成 `app.zip`。

## 1.0.0 - 2026-05-31

首个公开版本。桌面清理大师是一个 macOS 桌面清理玩笑软件：它让桌面看起来变干净，但不会删除、重命名或移动真实文件。

### Added

- macOS App 外壳，对外显示为“桌面清理大师”。
- 一键把 Finder 桌面图标临时收纳到窗口投影内。
- 退出、关闭或手动还原时恢复图标位置和 Finder 桌面设置。
- 窗口拖动跟随，图标很多时自动降频并在松手后全量同步。
- 简体中文、繁體中文、English、日本語、한국어 界面与菜单文案。
- 本地和 GitHub Actions 共用的 `桌面清理大师.app.zip` 打包流程。

### Safety

- 不删除文件。
- 不重命名文件。
- 不移动文件系统路径。
- 只临时调整 Finder 桌面图标显示坐标和 Finder 桌面布局设置。

### Known Limitations

- 仅支持 macOS。
- 当前是 ad-hoc signed build，没有 Developer ID 签名，也没有 notarization。
- 首次真实清理需要用户授予 Finder 自动化权限。
