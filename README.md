# DeskMagnet

[English](README.en.md) | 简体中文

DeskMagnet 是一个 macOS Finder 桌面图标吸附工具。应用对外显示为“桌面清理大师”：点击清理后，它不删除、不重命名、不移动文件路径，只临时修改 Finder 桌面图标坐标，把桌面图标收纳到窗口投影内；关闭或恢复时再把图标和 Finder 桌面设置还原。

![桌面清理大师主界面](docs/screenshots/desk-cleaner-home.jpg)

当前项目只支持 macOS。核心能力依赖 Finder AppleScript、macOS 桌面坐标系和 `.app` bundle，不支持 Windows 或 Linux。

## 当前能力

- 读取 Finder 桌面项目与原始坐标。
- 临时关闭 Finder 桌面自动排列，确保图标可被移动。
- 按窗口位置计算隐藏投影区，把图标收纳到窗口背后。
- 拖动窗口时按图标数量分级同步，图标过多时降低实时频率并在松手后全量同步。
- 退出、关闭窗口或检测到未完成状态时恢复桌面。
- 本地和 GitHub Actions 都使用同一个 `Scripts/build-app.sh` 打包入口。

## 安全边界

DeskMagnet 只改 Finder 的桌面图标显示坐标和临时 Finder 桌面布局设置。它不会删除文件、不会重命名文件、不会移动文件系统路径。

首次运行真实清理流程时，macOS 会要求允许 DeskMagnet 控制 Finder。拒绝该权限时，应用会显示自动化权限错误；允许后可在“系统设置 -> 隐私与安全性 -> 自动化”里管理。

## 菜单与语言

应用默认跟随系统语言，也可以在 macOS 菜单栏的“语言”菜单里切换：简体中文、繁體中文、English、日本語、한국어。

“一键清理”在菜单栏中是独立菜单，主应用菜单保留“还原桌面”和“退出”。如果清理后焦点被 Finder 抢走，应用会在流程结束后重新激活主窗口。

## 本地开发

```bash
swift build --product DeskMagnetApp
swift test
Scripts/build-app.sh
```

构建完成后，App 位于：

```text
build/桌面清理大师.app
```

`Scripts/build-app.sh` 会执行 release 构建、组装 `.app`、写入 `Info.plist`、复制 `.icns`，然后用 ad-hoc 签名验证 bundle。它是本地和 CI 的唯一 App 打包入口。

## 本地运行

```bash
open "build/桌面清理大师.app"
```

如果从浏览器或 GitHub artifact 下载后 macOS 添加了 quarantine 标记，可先清除：

```bash
xattr -dr com.apple.quarantine "build/桌面清理大师.app"
open "build/桌面清理大师.app"
```

当前产物是 ad-hoc signed `.app`，不是 Apple Developer ID signed，也没有 notarization。公开分发时，用户首次打开可能仍需清除 quarantine。要进入正式分发，需要补 Developer ID 证书、hardened runtime、notarytool 上传与 stapler 验证。

## GitHub Runner 打包

GitHub Actions 使用 `.github/workflows/build.yml`。普通 push 和 PR 只执行 `swift build --product DeskMagnetApp` 与 `swift test`。

只有两种情况会打包 `.app.zip`：

- 手动运行 `workflow_dispatch`。
- 推送 `v*` tag，例如 `v1.0.0`。

打包产物会上传为 `桌面清理大师-macOS` artifact，内部文件是 `桌面清理大师.app.zip`。CI 和本地共用 `Scripts/build-app.sh`，因此本地能打包通过，Runner 上的行为应当一致。

## 已知限制

- 当前只支持 macOS。
- 产物是 ad-hoc signed，没有 Developer ID 签名，也没有 notarization。
- 首次真实清理需要用户授予 Finder 自动化权限。
- 桌面图标很多时，窗口拖动同步会降频，松手后再做最终同步。

## 项目结构

```text
Assets/                  App 图标资产
Scripts/                 本地与 CI 共用构建脚本
Sources/DeskMagnetApp/   macOS App 外壳、窗口与 SwiftUI UI
Sources/DeskMagnetCore/  Finder 自动化、坐标转换、布局、恢复状态
Sources/DeskMagnetCLI/   命令行验证入口
Tests/                   DeskMagnetCore 测试
docs/                    产品规格与参考资料
```

## 创意来源

`docs/win版桌面清理大师参考.mp4` 是这个产品形态的创意参考视频。当前不知道原作者是谁；如果有人知道来源，欢迎提供线索或提交 PR 补充署名。

## License

DeskMagnet 使用 [MIT License](LICENSE)。
