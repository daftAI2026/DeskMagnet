# DeskMagnet macOS 真实桌面图标移动方案文档

> 文档状态：可执行方案 / 需求规格  
> 目标平台：macOS 26.5 起优先验证  
> 项目目录名：`DeskMagnet`  
> GitHub / 工程名建议：`DeskMagnet`  
> App 对外显示名建议：桌面清理大师  
> 中文副标题建议：桌面磁铁

---

## 1. 项目命名

### 1.1 推荐命名策略

本项目建议采用“双层命名”：

```text
GitHub / 工程目录 / Bundle 内部代号：DeskMagnet
App 展示名 / 窗口标题 / 用户看到的名字：桌面清理大师
中文传播副标题：桌面磁铁
```

也就是说，仓库名不建议叫“桌面清理大师”，而建议叫 **DeskMagnet**；但 App 打开后，窗口标题、按钮文案和恶搞包装都应该伪装成一个正经工具：**桌面清理大师**。

### 1.2 推荐原因

`DeskMagnet` 适合作为 GitHub 名称，因为它：

- 简短；
- 英文环境可读；
- 准确描述“吸附桌面图标”的真实行为；
- 不会让工程仓库显得像普通清理软件；
- 适合后续 README、Bundle Identifier、技术文档使用。

`桌面清理大师` 适合作为 App 对外名称，因为它：

- 伪装成传统 Windows / 国产工具风格；
- 与参考视频里的“桌面整理大师”气质一致；
- 有正经工具外壳和荒诞行为之间的反差；
- 用户点击“清理桌面”后发现图标被吸走，戏谑效果更强。

### 1.3 可选对外名称

如果后续想避开完全照搬“桌面整理大师”，可以选择：

```text
桌面清理大师
桌面整理大师
桌面管家 Pro
桌面清爽助手
桌面优化大师
```

当前推荐：**桌面清理大师**。

### 1.4 命名理由

原目录名 `macOS-Desktop-Cleanup` 更像一个严肃的清理工具，但这个软件的核心行为不是删除垃圾、归类文件或优化系统，而是：

- 把真实 Finder 桌面图标吸附到窗口附近；
- 拖动窗口时，图标像被磁铁吸住一样跟随；
- 软件退出后恢复桌面状态。

因此工程层使用“Magnet / 磁铁”更准确；产品层继续使用“清理大师”更有伪装和戏谑感。

### 1.5 目录名

已将项目目录建议为：

```text
DeskMagnet
```

后续如果创建 Xcode 工程，建议：

```text
Xcode Project: DeskMagnet.xcodeproj
App Target: DeskMagnet
Bundle Display Name: 桌面清理大师
Bundle Identifier: cool.sofxcking.deskmagnet 或 com.<owner>.deskmagnet
```

---

## 2. 产品目标

开发一个 macOS 原生桌面恶搞工具，复刻视频中 Windows 软件的核心行为：

1. 用户打开软件；
2. 点击“清理桌面”；
3. 软件临时接管 Finder 桌面布局；
4. 真实移动 Finder 桌面图标到 App 窗口附近；
5. 用户拖动 App 窗口时，真实桌面图标跟随窗口移动；
6. 用户点击恢复或关闭软件时，桌面图标和 Finder 桌面设置恢复到启动前状态。

本项目必须强调：

- 不删除文件；
- 不移动文件系统路径；
- 不重命名文件；
- 只修改 Finder 桌面图标坐标和临时 Finder 桌面布局设置；
- 必须可恢复。

---

## 3. 参考视频与 UI 方向

### 3.1 参考素材

参考视频已放在：

```text
docs/BugOS技术组的微博视频.mp4
```

已从视频中抽取一帧作为 UI 参考：

```text
docs/reference/bugos-video-ui-reference-frame.png
```

抽帧命令：

```bash
ffmpeg -y -ss 00:00:03.2 \
  -i docs/BugOS技术组的微博视频.mp4 \
  -frames:v 1 \
  docs/reference/bugos-video-ui-reference-frame.png
```

视频信息：

```text
尺寸：480 × 640
时长：约 9.97 秒
```

### 3.2 参考帧里的 UI 特征

参考帧展示的是一个极简、低成本、带一点恶搞软件质感的窗口：

- 深色背景；
- 矩形窗口；
- 顶部标题“桌面整理大师”；
- 标题颜色偏青色/天蓝色；
- 标题下方有一条较暗的分割线；
- 中间大面积留白；
- 状态文字居中；
- 完成态文字为亮绿色；
- 底部有一行很小的说明文字；
- 整体不像精致生产力工具，更像“正经但可疑”的小工具。

### 3.3 macOS 版本 UI 方向

macOS 版本不应做成现代精致 SaaS 风，也不应过度拟物。推荐风格：

```text
原生 macOS 小工具窗口
+ 黑色/深灰内容区
+ 青色标题
+ 绿色状态提示
+ 简单按钮/进度条
+ 轻微复古/恶搞工具感
```

窗口标题栏使用 macOS 原生标题栏和红黄绿窗口按钮，内容区用 SwiftUI 自绘。

### 3.4 MVP 窗口布局

建议窗口尺寸：

```text
宽：360 - 420 pt
高：220 - 280 pt
```

初始态：

```text
╭──────────────────────────╮
│ 桌面清理大师              │
├──────────────────────────┤
│                          │
│        一键清理桌面        │
│                          │
│      [ 清理桌面 ]          │
│                          │
│  不删除文件，只整理图标     │
╰──────────────────────────╯
```

清理中：

```text
╭──────────────────────────╮
│ 桌面清理大师              │
├──────────────────────────┤
│                          │
│       正在清理桌面...      │
│      ███████░░░ 70%       │
│                          │
│    正在优化桌面布局        │
╰──────────────────────────╯
```

完成态：

```text
╭──────────────────────────╮
│ 桌面清理大师              │
├──────────────────────────┤
│                          │
│     桌面已整理完毕！       │
│                          │
│      [ 恢复桌面 ]          │
│                          │
│    拖动窗口试试看          │
╰──────────────────────────╯
```

### 3.5 SwiftUI UI 实现建议

UI 使用 SwiftUI，窗口控制与 Finder 自动化使用 AppKit/系统 API。

SwiftUI 视图建议：

```text
ContentView
 ├─ TitleSection
 ├─ Divider
 ├─ StatusSection
 ├─ ProgressSection
 ├─ PrimaryActionButton
 └─ FootnoteSection
```

视觉参数建议：

```text
背景：Color.black 或 Color(red: 0.05, green: 0.05, blue: 0.06)
标题：cyan / teal，system 18-20 bold
状态成功：green，system 20-22 semibold
普通说明：gray，system 11-12
按钮：原生 Button 样式或轻微自定义蓝色按钮
进度条：SwiftUI ProgressView，tint cyan/green
```

### 3.6 不要在 UI 层做的事

MVP 不需要：

- 复杂动画；
- 大量品牌设计；
- 多窗口设置页；
- 菜单栏常驻；
- 视觉模拟假图标；
- 自绘桌面图标。

核心卖点是真实移动 Finder 桌面图标，UI 只需要像一个“看起来正经的清理工具”。

---

## 4. 已完成的 macOS 26.5 实测结论

以下测试均在当前机器上完成。

### 4.1 系统版本

命令：

```bash
sw_vers
uname -a
```

结果：

```text
ProductName:        macOS
ProductVersion:     26.5
BuildVersion:       25F71
Darwin Kernel:      25.5.0
Architecture:       arm64
```

结论：后续判断基于 **macOS 26.5**，不是旧 macOS 经验推断。

---

### 4.2 Finder 能读取桌面项目数量

命令：

```bash
osascript -e 'tell application "Finder" to count every item of desktop'
```

结果：

```text
47
```

结论：Finder AppleScript 在 macOS 26.5 上仍能访问桌面项目。

---

### 4.3 默认状态下读取已有桌面图标坐标失败

命令：

```applescript
tell application "Finder"
    get {name, desktop position} of every item of desktop
end tell
```

结果特征：

```text
多数项目位置返回 -1, -1
```

同时读取 Finder 桌面设置：

```bash
defaults read com.apple.finder DesktopViewSettings
```

结果：

```text
DesktopViewSettings = {
    GroupBy = Kind;
    IconViewSettings = {
        arrangeBy = dateAdded;
        gridSpacing = 54;
        iconSize = 48;
        labelOnBottom = 1;
        showIconPreview = 1;
        showItemInfo = 0;
        textSize = 10;
    };
}
```

结论：当前桌面启用了分组/自动排列相关状态，Finder 不暴露每个已有图标的有效自由坐标。

---

### 4.4 `desktop position` 写入能力仍然存在

测试方式：创建临时桌面文件 `AmpPositionTest.tmp`，设置其桌面坐标，然后读取。

关键 AppleScript：

```applescript
tell application "Finder"
    update desktop
    delay 0.5
    set testItem to item "AmpPositionTest.tmp" of desktop
    set beforeDesktopPosition to desktop position of testItem
    set desktop position of testItem to {180, 180}
    delay 0.5
    set afterDesktopPosition to desktop position of testItem
    return {beforeDesktopPosition, afterDesktopPosition}
end tell
```

实测结果：

```text
before: {-1, -1}
after:  {180, 180}
```

结论：macOS 26.5 上 Finder 仍允许通过 AppleScript 真实设置桌面图标坐标。

---

### 4.5 直接 `defaults write` + `killall Finder` 不稳定

第一次测试流程：

1. 备份 Finder 设置；
2. 运行 `defaults write` 修改 `DesktopViewSettings`；
3. `killall Finder`；
4. 读取修改结果；
5. 恢复备份。

期望：

```text
GroupBy = None
arrangeBy = none
```

实际：Finder 重启后自动变成类似：

```text
GroupBy = Kind
arrangeBy = name
```

结论：**不能在 Finder 正运行时直接改偏好再 killall**。Finder 可能覆盖或重建设置。

---

### 4.6 正确流程：先退出 Finder，再写设置，再启动 Finder

第二次测试流程：

```bash
defaults export com.apple.finder /tmp/amp-finder-before.plist
osascript -e 'tell application "Finder" to quit'
sleep 2
defaults write com.apple.finder DesktopViewSettings -dict GroupBy None
open -a Finder
sleep 2
osascript -e 'tell application "Finder" to tell icon view options of window of desktop to set arrangement to not arranged'
```

验证结果：

```text
DesktopViewSettings = {
    GroupBy = None;
}

arrangement = not arranged
```

恢复流程：

```bash
osascript -e 'tell application "Finder" to quit'
defaults import com.apple.finder /tmp/amp-finder-before.plist
open -a Finder
```

恢复验证：

```text
DesktopViewSettings restored equal: True
```

结论：**保存 → 退出 Finder → 写入兼容模式 → 启动 Finder → 恢复备份** 这条链路可行。

---

### 4.7 进入兼容模式后，已有图标坐标可读

兼容模式：

```text
GroupBy = None
arrangement = not arranged
```

读取前 10 个桌面图标坐标，实测结果：

```text
D-1                                  1854, 70
1-2006291R951133.jpg                 1854, 518
1-2006291R9511R.jpg                  1854, 294
1-2006291R9514E.jpg                  1854, 406
1-2006291R951A3.jpg                  1854, 182
20071217041629.jpg                   1854, 966
2026 年个人执行规划（v1.0）            1854, 630
322765161_...jpg                     1854, 854
72595ef95698939b7ab98d0f5a07f078.jpg 1854, 742
AI 技巧.ai                            1730, 70
```

结论：在 macOS 26.5 上，只要先把 Finder 桌面切到无分组/自由排列模式，Finder 就可以返回真实桌面图标坐标。

---

## 5. 最终技术结论

DeskMagnet 可以实现真实移动桌面图标，但必须采用“Finder 兼容模式”流程：

```text
保存 Finder 原始设置
→ 正常退出 Finder
→ 写入兼容模式 GroupBy=None
→ 启动 Finder
→ 设置 arrangement=not arranged
→ 读取图标坐标
→ 真实移动图标
→ 拖动窗口时低频同步图标坐标
→ 恢复图标位置
→ 恢复 Finder 原始设置
```

不能依赖：

```text
直接读取默认桌面状态下每个图标的 desktop position
```

因为在分组/自动排列状态下可能返回：

```text
{-1, -1}
```

---

## 6. 核心用户体验

### 6.1 初始态

窗口显示：

```text
桌面磁铁

把桌面图标吸到窗口上。
不会删除、移动或重命名任何文件。

[吸附桌面]
```

### 6.2 首次清理提示

用户点击“吸附桌面”后显示确认：

```text
为了真实移动桌面图标，DeskMagnet 需要临时关闭 Finder 的桌面分组/自动排序。

应用会保存当前 Finder 桌面设置，并在恢复或退出时还原。
不会删除、移动或重命名任何文件。

[继续] [取消]
```

### 6.3 吸附完成态

```text
桌面已被吸住。
拖动这个窗口试试。

[恢复桌面]
```

### 6.4 退出提示

如果图标仍处于吸附状态，用户关闭窗口时提示：

```text
桌面图标仍处于吸附状态。
是否恢复桌面后退出？

[恢复并退出] [保持现状] [取消]
```

默认按钮：`恢复并退出`。

---

## 7. 功能需求

### 7.1 Finder 设置快照

清理前必须保存完整 Finder 偏好，最低限度保存：

```json
{
  "DesktopViewSettings": {
    "GroupBy": "Kind",
    "IconViewSettings": {
      "arrangeBy": "dateAdded",
      "iconSize": 48,
      "gridSpacing": 54,
      "labelOnBottom": true,
      "showIconPreview": true,
      "showItemInfo": false,
      "textSize": 10
    }
  }
}
```

推荐保存完整：

```bash
defaults export com.apple.finder <snapshot-path>.plist
```

原因：完整导出比手动保存几个 key 更容易做到准确恢复。

---

### 7.2 进入 Finder 兼容模式

必须按此顺序执行：

1. 保存 Finder 偏好快照；
2. 正常退出 Finder；
3. 等待 Finder 退出完成；
4. 写入 `DesktopViewSettings.GroupBy = None`；
5. 启动 Finder；
6. 设置桌面 arrangement 为 `not arranged`；
7. 等待 Finder 桌面稳定；
8. 读取图标坐标。

参考命令：

```bash
defaults export com.apple.finder "$SNAPSHOT"
osascript -e 'tell application "Finder" to quit'
sleep 2
defaults write com.apple.finder DesktopViewSettings -dict GroupBy None
open -a Finder
sleep 2
osascript -e 'tell application "Finder" to tell icon view options of window of desktop to set arrangement to not arranged'
```

生产代码中不要硬编码 `sleep`，应使用轮询或超时检测 Finder 状态。

---

### 7.3 读取桌面图标坐标

AppleScript：

```applescript
tell application "Finder"
    set out to {}
    repeat with anItem in every item of desktop
        set end of out to {name of anItem, desktop position of anItem}
    end repeat
    return out
end tell
```

有效性判断：

```text
如果大部分图标坐标不是 {-1, -1}，则进入可移动状态。
如果多数仍是 {-1, -1}，则阻塞清理流程，执行恢复，并提示失败。
```

---

### 7.4 保存图标位置快照

每个桌面项目保存：

```json
{
  "name": "example.txt",
  "originalPosition": { "x": 1854, "y": 70 },
  "attachedOffset": { "dx": 20, "dy": 180 },
  "lastKnownPosition": { "x": 1854, "y": 70 }
}
```

建议额外保存：

- POSIX path；
- Finder alias；
- item kind；
- 是否为磁盘图标；
- 快照时间；
- 屏幕信息。

---

### 7.5 移动桌面图标到窗口附近

单个项目移动：

```applescript
tell application "Finder"
    set desktop position of item "example.txt" of desktop to {500, 300}
end tell
```

批量移动应合并为一段 AppleScript：

```applescript
tell application "Finder"
    set desktop position of item "A.txt" of desktop to {500, 300}
    set desktop position of item "B.txt" of desktop to {580, 300}
    set desktop position of item "C.txt" of desktop to {660, 300}
end tell
```

不要每个图标单独调用一次 `osascript`，否则性能会很差。

---

### 7.6 吸附布局

推荐第一版布局：窗口下方堆叠。

```text
╭────────────────────╮
│     桌面磁铁        │
│   桌面已被吸住      │
╰────────────────────╯
   📄  📁  🖼  📦
      📄  📁  📄
         📦  🖼
```

坐标计算：

```text
iconX = windowX + dx
iconY = windowY + dy
```

吸附偏移生成：

```text
dx = 20 + column * 88 + random(-8, 8)
dy = windowHeight + 24 + row * 88 + random(-6, 6)
```

---

### 7.7 窗口拖动跟随

真实 Finder 图标不是图层动画，不能承诺 60fps。

要求：

- 监听主窗口移动；
- 以节流方式批量更新图标坐标；
- 拖动结束后执行 final sync。

建议频率：

```text
1 - 30 个图标：80ms - 120ms 更新一次
31 - 100 个图标：150ms - 250ms 更新一次
100+ 个图标：拖动中抽样更新，拖动结束全量更新
```

窗口移动事件来源：

- `NSWindow.didMoveNotification`；
- `windowDidMove(_:)`；
- 定时器采样窗口 frame；
- 拖动停止 debounce。

---

### 7.8 恢复桌面

恢复顺序建议：

1. 停止窗口移动监听；
2. 将所有可匹配桌面项目恢复到原坐标；
3. 正常退出 Finder；
4. 导入 Finder 原始偏好快照；
5. 启动 Finder；
6. 清除 DeskMagnet 状态文件。

参考命令：

```bash
osascript -e 'tell application "Finder" to quit'
defaults import com.apple.finder "$SNAPSHOT"
open -a Finder
```

如果恢复图标坐标失败，也必须恢复 Finder 原始设置。

---

## 8. 状态文件设计

保存位置建议：

```text
~/Library/Application Support/DeskMagnet/state.json
~/Library/Application Support/DeskMagnet/finder-before.plist
```

`state.json` 示例：

```json
{
  "schemaVersion": 1,
  "status": "attached",
  "createdAt": "2026-05-29T00:00:00Z",
  "finderSnapshotPath": "~/Library/Application Support/DeskMagnet/finder-before.plist",
  "items": [
    {
      "name": "example.txt",
      "path": "/Users/d/Desktop/example.txt",
      "originalPosition": { "x": 1854, "y": 70 },
      "attachedOffset": { "dx": 20, "dy": 220 },
      "lastKnownPosition": { "x": 500, "y": 300 }
    }
  ]
}
```

启动时如果发现 `status=attached`，必须提示：

```text
检测到上次桌面未恢复，是否现在恢复？

[立即恢复] [稍后]
```

---

## 9. 权限需求

### 9.1 自动化权限

必须允许 App 控制 Finder。

用途：

- 读取桌面项目；
- 读取桌面图标坐标；
- 设置桌面图标坐标；
- 设置 Finder 桌面 view options；
- 退出/启动 Finder。

用户拒绝权限时，核心功能不可用。

---

### 9.2 文件访问权限

如果 App 直接读写：

```text
~/Library/Preferences/com.apple.finder.plist
~/Library/Application Support/DeskMagnet
```

可能涉及沙盒限制。

建议 MVP 使用非 Mac App Store 分发，不启用 App Sandbox，降低权限复杂度。

---

### 9.3 屏幕录制和辅助功能权限

MVP 不依赖。

只有当后续要做“视觉识别当前图标位置”时才需要：

- 屏幕录制；
- 辅助功能。

当前已验证：通过 Finder 兼容模式可以读取图标坐标，因此 MVP 暂不需要视觉识别。

---

## 10. 阻塞项与处理策略

### 阻塞 1：无法获得 Finder 自动化权限

表现：AppleScript 报权限错误。

处理：

- 停止清理流程；
- 不修改 Finder 设置；
- 展示授权指引。

提示文案：

```text
需要允许 DeskMagnet 控制 Finder，才能移动桌面图标。
请前往：系统设置 → 隐私与安全性 → 自动化。
```

---

### 阻塞 2：进入兼容模式后仍读不到有效坐标

表现：大部分图标仍返回：

```text
{-1, -1}
```

处理：

- 立即恢复 Finder 原设置；
- 不进入吸附状态；
- 展示失败原因。

---

### 阻塞 3：Finder 退出或启动超时

处理：

- 设置超时时间，例如 10 秒；
- 超时后尝试恢复备份；
- 提示用户手动重启 Finder 或重新打开 App。

---

### 阻塞 4：Finder 设置恢复失败

处理：

- 保留 `finder-before.plist`；
- 提供“再次尝试恢复”按钮；
- 文案展示快照路径；
- 不删除状态文件。

---

### 阻塞 5：清理期间用户新增/删除/重命名桌面文件

处理：

- 恢复时按 path/name 匹配；
- 找不到的项目跳过；
- 新增项目保持 Finder 当前状态或按 Finder 自动排列；
- 恢复结果中提示跳过数量。

---

### 阻塞 6：桌面图标数量过多导致 Finder 卡顿

处理：

- 100 个以上显示性能提示；
- 300 个以上建议不启用实时跟随；
- 拖动中抽样更新，拖动停止后全量同步。

---

## 11. 推荐技术栈

首选：

- Swift；
- AppKit；
- SwiftUI 仅用于简单 UI；
- NSAppleScript 或 Apple Event 调用 Finder；
- Codable 保存状态。

不推荐 Electron 作为 MVP：

- Finder 自动化和 macOS 生命周期控制更绕；
- 原生窗口移动监听更直接；
- 权限与恢复流程更适合 AppKit。

---

## 12. 模块划分

### 12.1 AppCoordinator

职责：

- 管理状态机；
- 串联清理、吸附、恢复；
- 处理启动时未恢复状态。

---

### 12.2 FinderSettingsManager

职责：

- 导出 Finder 偏好快照；
- 退出 Finder；
- 写入兼容模式；
- 启动 Finder；
- 恢复 Finder 偏好。

关键接口：

```swift
func snapshotFinderSettings() throws -> URL
func enterCompatibilityMode(snapshotURL: URL) throws
func restoreFinderSettings(snapshotURL: URL) throws
```

---

### 12.3 FinderIconController

职责：

- 读取桌面 item；
- 读取 `desktop position`；
- 批量设置图标位置；
- 校验坐标有效性。

关键接口：

```swift
func readDesktopItems() throws -> [DesktopItem]
func moveItems(_ moves: [IconMove]) throws
func validatePositions(_ items: [DesktopItem]) -> Bool
```

---

### 12.4 LayoutEngine

职责：

- 根据窗口 frame 计算吸附布局；
- 生成每个图标相对窗口的 offset；
- 防止图标全部堆在同一点；
- 处理屏幕边界。

---

### 12.5 WindowFollowController

职责：

- 监听窗口移动；
- 节流更新；
- 拖动结束后 final sync。

---

### 12.6 RecoveryStore

职责：

- 写入 `state.json`；
- 写入 Finder 快照路径；
- 启动时检测未恢复状态；
- 恢复成功后清理状态。

---

## 13. 状态机

```text
Idle
  ↓ click attach
RequestingPermission
  ↓ permission granted
SnapshottingFinder
  ↓ snapshot saved
EnteringCompatibilityMode
  ↓ Finder ready
ReadingIconPositions
  ↓ positions valid
Attached
  ↓ window moved
FollowingWindow
  ↓ restore/quit
RestoringIconPositions
  ↓ icons restored
RestoringFinderSettings
  ↓ settings restored
Idle
```

错误状态：

```text
PermissionDenied
CompatibilityFailed
PositionReadFailed
FinderRestoreFailed
PartialIconRestore
```

任何错误发生时，优先恢复 Finder 设置。

---

## 14. 开发里程碑

### P0：技术验证器

必须先做一个命令行或最小 App 验证：

1. 请求 Finder 自动化权限；
2. 保存 Finder 设置；
3. 退出 Finder；
4. 写入兼容模式；
5. 启动 Finder；
6. 读取有效图标坐标；
7. 移动 1 个图标；
8. 恢复该图标；
9. 恢复 Finder 设置。

P0 不做 UI，不做拖动跟随。

验收：

```text
Finder 设置恢复前后 DesktopViewSettings 完全一致。
```

---

### P1：MVP App

实现：

1. 主窗口；
2. 吸附按钮；
3. 恢复按钮；
4. Finder 兼容模式；
5. 读取所有图标坐标；
6. 批量移动到窗口下方；
7. 拖动窗口低频跟随；
8. 退出时恢复；
9. 下次启动恢复未完成状态。

---

### P2：体验优化

实现：

- 更好的堆叠布局；
- 随机偏移；
- 图标数量分级策略；
- 多显示器适配；
- 恢复结果详情；
- 更精致的 UI 和文案。

---

## 15. 验收标准

### 15.1 功能验收

- macOS 26.5 上可以启动 App；
- 点击吸附后 Finder 设置被保存；
- Finder 被切到兼容模式；
- 图标坐标不再是 `{-1,-1}`；
- 桌面真实图标移动到窗口附近；
- 拖动窗口时图标跟随；
- 点击恢复后图标回到原坐标；
- Finder 桌面设置恢复到启动前；
- App 重启后能恢复上次未完成状态。

### 15.2 安全验收

- 不删除桌面文件；
- 不移动文件系统路径；
- 不重命名文件；
- 恢复失败时保留快照；
- 恢复失败时给出明确路径和重试入口。

### 15.3 性能验收

- 30 个以内图标，拖动跟随可接受；
- 100 个以内图标，允许低频延迟；
- 100 个以上显示性能提示；
- Finder 不应持续卡死。

---

## 16. 实现注意事项

1. 不要使用 `killall Finder` 作为首选流程，优先正常退出 Finder；
2. 不要在 Finder 正运行时直接写偏好并假设生效；
3. 不要每个图标单独调用 `osascript`；
4. 任何移动图标前必须先保存恢复状态；
5. 任何失败都优先恢复 Finder 设置；
6. 状态文件写入必须早于真实移动；
7. 恢复成功后才能删除状态文件；
8. 文案必须明确说明会临时改变 Finder 桌面布局设置。

---

## 17. 最小 AppleScript 参考

### 17.1 设置桌面自由排列

```applescript
tell application "Finder"
    tell icon view options of window of desktop
        set arrangement to not arranged
    end tell
end tell
```

### 17.2 读取桌面图标坐标

```applescript
tell application "Finder"
    set out to {}
    repeat with anItem in every item of desktop
        set end of out to {name of anItem, desktop position of anItem}
    end repeat
    return out
end tell
```

### 17.3 批量移动桌面图标

```applescript
tell application "Finder"
    set desktop position of item "A.txt" of desktop to {500, 300}
    set desktop position of item "B.txt" of desktop to {588, 300}
    set desktop position of item "C.txt" of desktop to {676, 300}
end tell
```

---

## 18. 建议给 Agent 的执行入口

如果由后续 Agent 实现，请按此顺序执行：

1. 先实现 P0 技术验证器；
2. P0 通过后再建 App；
3. 优先实现恢复链路，不要先做 UI 动效；
4. 再实现真实移动；
5. 最后实现窗口跟随；
6. 每一步都要在 macOS 26.5 上实测。

第一条开发任务应该是：

```text
实现 FinderSettingsManager + FinderIconController 的最小命令行验证，证明可以保存 Finder 设置、进入兼容模式、读取有效坐标、移动一个图标、恢复图标和 Finder 设置。
```
