/**
 * [INPUT]: 依赖 SwiftUI 与 DeskMagnetViewModel 的 Phase 状态。
 * [OUTPUT]: 提供亮色 DeskMagnet 主窗口内容视图。
 * [POS]: DeskMagnetApp 的 UI 表层，统一视觉状态和动作入口，不直接操作 Finder。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: DeskMagnetViewModel

    var body: some View {
        VStack(spacing: 0) {
            TitleSection()
            Divider()
                .overlay(DeskMagnetPalette.divider)
            VStack(spacing: 22) {
                StatusSection(phase: viewModel.phase)
                ProgressSection(phase: viewModel.phase)
                if viewModel.showsPrimaryButton {
                    Button(action: viewModel.primaryAction) {
                        Text(viewModel.primaryButtonTitle)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 224, height: 46)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(DeskMagnetPalette.action)
                    .disabled(isBusy)
                }
                FootnoteSection(text: viewModel.footnote)
                    .frame(height: 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 48)
            .padding(.vertical, 30)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DeskMagnetPalette.panel)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(DeskMagnetPalette.panelBorder, lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 8)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 24)
            }
        }
        .frame(minWidth: 720, minHeight: 440)
        .background(DeskMagnetPalette.window)
        .preferredColorScheme(.light)
    }

    private var isBusy: Bool {
        switch viewModel.phase {
        case .working, .restoring:
            true
        default:
            false
        }
    }
}

private enum DeskMagnetPalette {
    static let action = Color(red: 0.08, green: 0.36, blue: 0.92)
    static let attention = Color(red: 0.00, green: 0.48, blue: 0.50)
    static let danger = Color(red: 0.76, green: 0.15, blue: 0.16)
    static let divider = Color.black.opacity(0.08)
    static let panel = Color(nsColor: .textBackgroundColor)
    static let panelBorder = Color.black.opacity(0.07)
    static let success = Color(red: 0.13, green: 0.48, blue: 0.28)
    static let window = Color(red: 0.95, green: 0.96, blue: 0.97)
}

private struct TitleSection: View {
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DeskMagnetPalette.action.opacity(0.10))
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(DeskMagnetPalette.action)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text("桌面清理大师")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                Text("整理完成后，移动这个窗口即可保持遮挡位置")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            StatusBadge()
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 24)
    }
}

private struct StatusBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 13, weight: .semibold))
            Text("不改动文件")
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(DeskMagnetPalette.success)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(DeskMagnetPalette.success.opacity(0.10))
        }
    }
}

private struct StatusSection: View {
    let phase: DeskMagnetViewModel.Phase

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: presentation.symbolName)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(presentation.color)
                .frame(height: 52)
            Text(presentation.title)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(presentation.color)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 24)
            if !presentation.subtitle.isEmpty {
                Text(presentation.subtitle)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 34)
            }
        }
    }

    private var presentation: PhasePresentation {
        switch phase {
        case .idle:
            PhasePresentation(
                title: "一键清理桌面",
                subtitle: "窗口保持在桌面前方，图标会被收纳到窗口背后。",
                symbolName: "rectangle.stack.badge.plus",
                color: DeskMagnetPalette.action
            )
        case let .working(text, _):
            PhasePresentation(
                title: text,
                subtitle: "",
                symbolName: "wand.and.stars",
                color: DeskMagnetPalette.action
            )
        case let .attached(count):
            PhasePresentation(
                title: "桌面已整理完毕",
                subtitle: "已整理 \(count) 个图标",
                symbolName: "checkmark.circle.fill",
                color: DeskMagnetPalette.success
            )
        case .restoring:
            PhasePresentation(
                title: "正在恢复桌面",
                subtitle: "图标和 Finder 设置会回到启动前",
                symbolName: "arrow.counterclockwise.circle",
                color: DeskMagnetPalette.attention
            )
        case let .failed(message):
            PhasePresentation(
                title: "清理失败",
                subtitle: message,
                symbolName: "exclamationmark.triangle.fill",
                color: DeskMagnetPalette.danger
            )
        }
    }
}

private struct PhasePresentation {
    let title: String
    let subtitle: String
    let symbolName: String
    let color: Color
}

private struct ProgressSection: View {
    let phase: DeskMagnetViewModel.Phase

    var body: some View {
        Group {
            if case let .working(_, progress) = phase {
                ProgressView(value: progress)
                    .tint(DeskMagnetPalette.action)
                    .frame(width: 210)
            } else if case .restoring = phase {
                ProgressView()
                    .controlSize(.small)
                    .tint(DeskMagnetPalette.attention)
            }
        }
        .frame(height: 28)
    }
}

private struct FootnoteSection: View {
    let text: String

    var body: some View {
        Group {
            if text.isEmpty {
                Color.clear
            } else {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.black.opacity(0.035))
                    }
            }
        }
    }
}
