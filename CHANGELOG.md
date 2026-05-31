# Changelog

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
