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
            Button(action: viewModel.primaryAction) {
                Text(viewModel.primaryButtonTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(minWidth: 112)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isBusy)
            Spacer(minLength: 14)
            Text(viewModel.footnote)
                .font(.system(size: 11))
                .foregroundStyle(.gray)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .frame(minWidth: 360, minHeight: 220)
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
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.cyan)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.vertical, 15)
    }
}

private struct StatusSection: View {
    let phase: DeskMagnetViewModel.Phase

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 24)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 24)
        }
    }

    private var title: String {
        switch phase {
        case .idle:
            "桌面磁铁"
        case let .working(text, _):
            text
        case .attached:
            "桌面已被吸住。"
        case .restoring:
            "正在恢复桌面..."
        case .failed:
            "清理失败"
        }
    }

    private var subtitle: String {
        switch phase {
        case .idle:
            "把真实 Finder 桌面图标吸到窗口下方。"
        case .working:
            "正在保存 Finder 设置并读取图标坐标"
        case let .attached(count):
            "已吸附 \(count) 个图标"
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
