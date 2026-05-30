# DeskMagnet

DeskMagnet 是一个 macOS Finder 桌面图标吸附工具。应用对外显示为“桌面清理大师”：点击清理后，它不删除、不重命名、不移动文件路径，只临时修改 Finder 桌面图标坐标，把桌面图标收纳到窗口投影内；关闭或恢复时再把图标和 Finder 桌面设置还原。

![桌面清理大师主界面](docs/screenshots/desk-cleaner-home.png)

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

## 本地开发

```bash
swift build --product DeskMagnetApp
swift test
Scripts/build-app.sh
```

构建完成后，App 位于：

```text
build/DeskMagnet.app
```

`Scripts/build-app.sh` 会执行 release 构建、组装 `.app`、写入 `Info.plist`、复制 `.icns`，然后用 ad-hoc 签名验证 bundle。它是本地和 CI 的唯一 App 打包入口。

## 本地运行

```bash
open build/DeskMagnet.app
```

如果从浏览器或 GitHub artifact 下载后 macOS 添加了 quarantine 标记，可先清除：

```bash
xattr -dr com.apple.quarantine build/DeskMagnet.app
open build/DeskMagnet.app
```

当前产物是 ad-hoc signed `.app`，不是 Apple Developer ID signed，也没有 notarization。公开分发时，用户首次打开可能仍需清除 quarantine。要进入正式分发，需要补 Developer ID 证书、hardened runtime、notarytool 上传与 stapler 验证。

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
