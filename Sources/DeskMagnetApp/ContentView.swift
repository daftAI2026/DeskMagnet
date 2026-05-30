/**
 * [INPUT]: 依赖 SwiftUI 与 DeskMagnetViewModel 的 Phase 状态。
 * [OUTPUT]: 提供亮色 DeskMagnet 主窗口内容视图。
 * [POS]: DeskMagnetApp 的 UI 表层，以层级和节奏统一状态与动作入口，不直接操作 Finder。
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
            ContentPanel(
                phase: viewModel.phase,
                primaryButtonTitle: viewModel.primaryButtonTitle,
                showsPrimaryButton: viewModel.showsPrimaryButton,
                footnote: viewModel.footnote,
                isBusy: isBusy,
                primaryAction: viewModel.primaryAction
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, DeskMagnetRhythm.section)
            .padding(.vertical, DeskMagnetRhythm.lg)
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

private struct ContentPanel: View {
    let phase: DeskMagnetViewModel.Phase
    let primaryButtonTitle: String
    let showsPrimaryButton: Bool
    let footnote: String
    let isBusy: Bool
    let primaryAction: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(DeskMagnetPalette.panel)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(DeskMagnetPalette.panelBorder, lineWidth: 1)
                }
                .shadow(color: DeskMagnetPalette.whisperShadow, radius: 24, x: 0, y: 4)

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                StatusSection(phase: phase)
                    .frame(maxWidth: .infinity, alignment: .center)
                if showsActionSection {
                    ActionSection(
                        primaryButtonTitle: primaryButtonTitle,
                        showsPrimaryButton: showsPrimaryButton,
                        isBusy: isBusy,
                        phase: phase,
                        primaryAction: primaryAction
                    )
                    .frame(maxWidth: .infinity, minHeight: 82, idealHeight: 82, maxHeight: 82, alignment: .center)
                    .padding(.top, DeskMagnetRhythm.md)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, DeskMagnetRhythm.section)
            .padding(.vertical, DeskMagnetRhythm.xl)

            if !footnote.isEmpty {
                FootnoteSection(text: footnote)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, DeskMagnetRhythm.section)
                    .padding(.bottom, DeskMagnetRhythm.xl)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }

    private var showsActionSection: Bool {
        switch phase {
        case .attached:
            false
        default:
            showsPrimaryButton || hasProgress
        }
    }

    private var hasProgress: Bool {
        switch phase {
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
    static let whisperShadow = Color.black.opacity(0.06)
    static let window = Color(red: 0.95, green: 0.96, blue: 0.97)
}

private enum DeskMagnetRhythm {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let section: CGFloat = 48
}

private struct TitleSection: View {
    var body: some View {
        HStack(spacing: DeskMagnetRhythm.md) {
            Text("桌面清理大师")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            StatusBadge()
        }
        .padding(.horizontal, DeskMagnetRhythm.xl)
        .padding(.vertical, DeskMagnetRhythm.lg)
    }
}

private struct StatusBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 13, weight: .semibold))
            Text("专业桌面整理解决方案")
                .font(.system(size: 13, weight: .medium))
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
        VStack(spacing: DeskMagnetRhythm.md) {
            Image(systemName: presentation.symbolName)
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(presentation.color)
                .frame(width: 56, height: 56)
            Text(presentation.title)
                .font(.system(size: 33, weight: .medium))
                .foregroundStyle(presentation.color)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .lineSpacing(2)
                .padding(.horizontal, DeskMagnetRhythm.lg)
            if !presentation.subtitle.isEmpty {
                Text(presentation.subtitle)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .lineSpacing(6)
                    .padding(.horizontal, DeskMagnetRhythm.xl)
            }
        }
    }

    private var presentation: PhasePresentation {
        switch phase {
        case .idle:
            PhasePresentation(
                title: "一键清理，还你整洁桌面",
                subtitle: "",
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

private struct ActionSection: View {
    let primaryButtonTitle: String
    let showsPrimaryButton: Bool
    let isBusy: Bool
    let phase: DeskMagnetViewModel.Phase
    let primaryAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ProgressSection(phase: phase)
            if showsPrimaryButton {
                Button(action: primaryAction) {
                    Text(primaryButtonTitle)
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 224, height: 46)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(DeskMagnetPalette.action)
                .disabled(isBusy)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
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
        Text(text.isEmpty ? " " : text)
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(.secondary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, DeskMagnetRhythm.lg)
            .padding(.vertical, 10)
            .frame(maxWidth: 520, minHeight: 40, alignment: .center)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(text.isEmpty ? .clear : Color.black.opacity(0.035))
            }
    }
}
