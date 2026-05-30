/**
 * [INPUT]: 依赖 SwiftUI 与 DeskMagnetViewModel 的 Phase 状态。
 * [OUTPUT]: 提供 DeskMagnet 主窗口内容视图。
 * [POS]: DeskMagnetApp 的 UI 表层，只渲染状态和动作，不直接操作 Finder。
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: DeskMagnetViewModel

    var body: some View {
        VStack(spacing: 0) {
            TitleSection()
            Divider().background(Color.white.opacity(0.12))
            Spacer(minLength: 18)
            StatusSection(phase: viewModel.phase)
            ProgressSection(phase: viewModel.phase)
            if viewModel.showsPrimaryButton {
                Button(action: viewModel.primaryAction) {
                    Text(viewModel.primaryButtonTitle)
                        .font(.system(size: 26, weight: .bold))
                        .frame(width: 280, height: 56)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isBusy)
            }
            Spacer(minLength: 14)
            if !viewModel.footnote.isEmpty {
                Text(viewModel.footnote)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
        }
        .frame(minWidth: 720, minHeight: 440)
        .background(Color(red: 0.05, green: 0.05, blue: 0.06))
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

private struct TitleSection: View {
    var body: some View {
        Text("桌面清理大师")
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(.cyan)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 44)
            .padding(.vertical, 36)
    }
}

private struct StatusSection: View {
    let phase: DeskMagnetViewModel.Phase

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 24)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 24)
            }
        }
    }

    private var title: String {
        switch phase {
        case .idle:
            "一键清理桌面"
        case let .working(text, _):
            text
        case .attached:
            "桌面已整理完毕！"
        case .restoring:
            "正在恢复桌面..."
        case .failed:
            "清理失败"
        }
    }

    private var subtitle: String {
        switch phase {
        case .idle:
            ""
        case .working:
            ""
        case let .attached(count):
            "已整理 \(count) 个图标"
        case .restoring:
            "图标和 Finder 设置会回到启动前"
        case let .failed(message):
            message
        }
    }

    private var color: Color {
        switch phase {
        case .attached:
            .green
        case .failed:
            .red
        default:
            .white
        }
    }
}

private struct ProgressSection: View {
    let phase: DeskMagnetViewModel.Phase

    var body: some View {
        Group {
            if case let .working(_, progress) = phase {
                ProgressView(value: progress)
                    .tint(.cyan)
                    .frame(width: 190)
            } else if case .restoring = phase {
                ProgressView()
                    .controlSize(.small)
                    .tint(.green)
            }
        }
        .frame(height: 30)
        .padding(.vertical, 8)
    }
}
