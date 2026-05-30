# .github/
> L2 | 父级: /Users/luo/Desktop/ClaudeCode/web/DeskMagnet/CLAUDE.md

成员清单
workflows/: GitHub Actions 工作流目录，负责远端构建、测试和 macOS app artifact 打包

模块边界:
.github 只编排仓库自动化；真实构建入口必须复用 Scripts/，不能在 workflow 中复制业务打包逻辑。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
