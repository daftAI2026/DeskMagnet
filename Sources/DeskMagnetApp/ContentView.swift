/**
 * [INPUT]: 依赖 SwiftUI、DeskMagnetViewModel 的 Phase 状态和 AppLocalization 文案。
 * [OUTPUT]: 提供亮色 DeskMagnet 主窗口内容视图，恢复态以逆时针旋转图标承载等待反馈。
 * [POS]: DeskMagnetApp 的 UI 表层，以层级和节奏统一状态与动作入口，不直接操作 Finder。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: DeskMagnetViewModel
    @ObservedObject var languageStore: AppLanguageStore

    var body: some View {
        VStack(spacing: 0) {
            TitleSection(strings: languageStore.strings)
            Divider()
                .overlay(DeskMagnetPalette.divider)
            ContentPanel(
                phase: viewModel.phase,
                strings: languageStore.strings,
                primaryButtonTitle: viewModel.primaryButtonTitle,
                showsPrimaryButton: viewModel.showsPrimaryButton,
                footnote: viewModel.footnote,
                isBusy: isBusy,
                primaryAction: viewModel.primaryAction
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, DeskMagnetRhythm.canvasInset)
            .padding(.vertical, DeskMagnetRhythm.bodyInset)
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
    let strings: AppStrings
    let primaryButtonTitle: String
    let showsPrimaryButton: Bool
    let footnote: String
    let isBusy: Bool
    let primaryAction: () -> Void

    var body: some View {
        BodyActionGroup(
            phase: phase,
            strings: strings,
            primaryButtonTitle: primaryButtonTitle,
            showsPrimaryButton: showsPrimaryButton,
            footnote: footnote,
            isBusy: isBusy,
            primaryAction: primaryAction
        )
        .padding(.horizontal, DeskMagnetRhythm.section)
        .padding(.vertical, DeskMagnetRhythm.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private enum DeskMagnetPalette {
    static let primary = Color(red: 0.08, green: 0.82, blue: 0.39)
    static let danger = Color(red: 0.76, green: 0.15, blue: 0.16)
    static let divider = Color.black.opacity(0.08)
    static let window = Color(red: 0.95, green: 0.96, blue: 0.97)
}

private enum DeskMagnetRhythm {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let section: CGFloat = 48
    static let canvasInset: CGFloat = 48
    static let headerInset: CGFloat = 36
    static let bodyInset: CGFloat = 24
    static let buttonGap: CGFloat = 36
    static let contentGap: CGFloat = 10
    static let titleHeight: CGFloat = 104
}

private struct TitleSection: View {
    let strings: AppStrings

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: DeskMagnetRhythm.md) {
                Text(strings.appName)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .layoutPriority(1)
                Spacer()
                StatusBadge(text: strings.badge)
            }
            .padding(.horizontal, DeskMagnetRhythm.headerInset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .offset(y: -proxy.safeAreaInsets.top / 2)
        }
        .frame(height: DeskMagnetRhythm.titleHeight)
        .background(DeskMagnetPalette.primary)
    }
}

private struct StatusBadge: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 13, weight: .semibold))
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.white.opacity(0.18))
        }
    }
}

private struct StatusSection: View {
    let phase: DeskMagnetViewModel.Phase
    let strings: AppStrings

    var body: some View {
        VStack(spacing: DeskMagnetRhythm.sm) {
            StatusSymbol(presentation: presentation)
                .id(presentation.symbolName)
            Text(presentation.title)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(presentation.color)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.62)
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
                title: strings.idleTitle,
                subtitle: "",
                symbolName: "rectangle.stack.badge.plus",
                color: DeskMagnetPalette.primary
            )
        case .working:
            PhasePresentation(
                title: strings.cleaningTitle,
                subtitle: "",
                symbolName: "wand.and.stars",
                color: DeskMagnetPalette.primary
            )
        case let .attached(count):
            PhasePresentation(
                title: strings.attachedTitle(iconCount: count),
                subtitle: "",
                symbolName: "checkmark.circle.fill",
                color: DeskMagnetPalette.primary
            )
        case .restoring:
            PhasePresentation(
                title: strings.restoringTitle,
                subtitle: "",
                symbolName: "arrow.counterclockwise.circle",
                color: DeskMagnetPalette.primary
            )
        case let .failed(message):
            PhasePresentation(
                title: strings.failedTitle,
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

    var rotatesCounterclockwise: Bool {
        symbolName == "arrow.counterclockwise.circle"
    }
}

private struct StatusSymbol: View {
    let presentation: PhasePresentation
    @State private var rotation = 0.0

    var body: some View {
        Image(systemName: presentation.symbolName)
            .font(.system(size: 40, weight: .light))
            .foregroundStyle(presentation.color)
            .rotationEffect(.degrees(presentation.rotatesCounterclockwise ? rotation : 0))
            .frame(width: 56, height: 56)
            .onAppear {
                guard presentation.rotatesCounterclockwise else { return }
                rotation = 0
                withAnimation(.linear(duration: 1.45).repeatForever(autoreverses: false)) {
                    rotation = -360
                }
            }
    }
}

private struct BodyActionGroup: View {
    let phase: DeskMagnetViewModel.Phase
    let strings: AppStrings
    let primaryButtonTitle: String
    let showsPrimaryButton: Bool
    let footnote: String
    let isBusy: Bool
    let primaryAction: () -> Void

    var body: some View {
        VStack(spacing: DeskMagnetRhythm.buttonGap) {
            StatusSection(phase: phase, strings: strings)
            if showsActionSection {
                ActionSection(
                    primaryButtonTitle: primaryButtonTitle,
                    showsPrimaryButton: showsPrimaryButton,
                    footnote: footnote,
                    isBusy: isBusy,
                    phase: phase,
                    primaryAction: primaryAction
                )
            }
        }
    }

    private var showsActionSection: Bool {
        switch phase {
        case .attached:
            !footnote.isEmpty
        case .working:
            true
        case .restoring:
            false
        default:
            showsPrimaryButton || !footnote.isEmpty
        }
    }
}

private struct ActionSection: View {
    let primaryButtonTitle: String
    let showsPrimaryButton: Bool
    let footnote: String
    let isBusy: Bool
    let phase: DeskMagnetViewModel.Phase
    let primaryAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if showsProgress {
                ProgressSection(phase: phase)
            }
            if showsPrimaryButton {
                Button(action: primaryAction) {
                    Text(primaryButtonTitle)
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(.white)
                        .frame(width: 252, height: 52)
                        .background {
                            Capsule(style: .continuous)
                                .fill(DeskMagnetPalette.primary)
                                .shadow(color: DeskMagnetPalette.primary.opacity(0.24), radius: 24, x: 0, y: 10)
                        }
                }
                .buttonStyle(.plain)
                .contentShape(Capsule(style: .continuous))
                .disabled(isBusy)
            }
            if !footnote.isEmpty {
                FootnoteSection(text: footnote)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var showsProgress: Bool {
        switch phase {
        case .working:
            true
        default:
            false
        }
    }
}

private struct ProgressSection: View {
    let phase: DeskMagnetViewModel.Phase

    var body: some View {
        Group {
            if case let .working(progress) = phase {
                ProgressView(value: progress)
                    .tint(DeskMagnetPalette.primary)
                    .frame(width: 210)
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
