import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - 灵动岛 / 锁屏实时活动视图

struct BetLandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BetLandAttributes.self) { context in
            // 锁屏视图
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // 展开态：有模板渲染模板视图，否则默认视图
                DynamicIslandExpandedRegion(.leading) {
                    leadingRegion(context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    trailingRegion(context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    bottomRegion(context)
                }
            } compactLeading: {
                compactLeading(context)
            } compactTrailing: {
                compactTrailing(context)
            } minimal: {
                minimal(context)
            }
        }
    }

    // MARK: - 模板解析（带默认渲染回退）

    private func template(from context: ActivityViewContext<BetLandAttributes>) -> IslandTemplateConfig? {
        guard let t = IslandTemplateConfig.decode(context.state.templateJSON), t.kind != .none else {
            return nil
        }
        return t
    }

    @ViewBuilder
    private func leadingRegion(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        if let t = template(from: context) {
            templateLeadingView(t)
        } else {
            leadingExpanded(context)
        }
    }

    @ViewBuilder
    private func trailingRegion(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        if let t = template(from: context) {
            templateTrailingView(t)
        } else {
            trailingExpanded(context)
        }
    }

    @ViewBuilder
    private func bottomRegion(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        if let t = template(from: context) {
            templateBottomView(t)
        } else {
            bottomExpanded(context)
        }
    }

    // MARK: - 展开态（默认）

    private func leadingExpanded(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color(hex: context.state.accentHex))
                Text(context.state.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            Text("实时活动 · 自定义布局")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    private func trailingExpanded(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(context.state.subtitle)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .monospacedDigit()
            Text("BetLand")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func bottomExpanded(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        VStack(spacing: 8) {
            ProgressView(value: context.state.progress)
                .progressViewStyle(.linear)
                .tint(Color(hex: context.state.accentHex))
            HStack {
                Text("展开面板 · 高 \(Int(context.state.progress * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("8h 上限")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - 紧凑态

    private func compactLeading(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        HStack(spacing: 4) {
            Image(systemName: context.state.capsuleIcon.isEmpty ? "sparkles" : context.state.capsuleIcon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: context.state.accentHex))
            Text(context.state.title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .foregroundStyle(.white)
    }

    private func compactTrailing(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        Text(context.state.subtitle)
            .font(.caption2.weight(.bold))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.35)
            .foregroundStyle(.white)
    }

    // MARK: - 迷你态

    private func minimal(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        Image(systemName: context.state.capsuleIcon.isEmpty ? "sparkles" : context.state.capsuleIcon)
            .font(.caption.weight(.bold))
            .foregroundStyle(Color(hex: context.state.accentHex))
    }
}

// MARK: - 锁屏视图

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<BetLandAttributes>

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(Color(hex: context.state.accentHex))
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.title)
                    .font(.headline)
                Text(context.state.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ProgressView(value: context.state.progress)
                    .tint(Color(hex: context.state.accentHex))
            }
            Spacer()
        }
        .padding(14)
    }
}
