import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - 灵动岛 / 锁屏实时活动视图
// 布局数据随 ContentState.layoutJSON 传递；无布局时回退默认渲染

struct BetLandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BetLandAttributes.self) { context in
            // 锁屏视图
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // 展开态：按画布坐标分区自由摆放
                if let layout = IslandStore.decode(context.state.layoutJSON) {
                    let regions = ExpandedRegions.split(layout)
                    DynamicIslandExpandedRegion(.leading) {
                        regionView(regions.leading, canvas: layout, yRange: -layout.expandedHeight / 2 ... layout.expandedHeight * 0.45)
                    }
                    DynamicIslandExpandedRegion(.trailing) {
                        regionView(regions.trailing, canvas: layout, yRange: -layout.expandedHeight / 2 ... layout.expandedHeight * 0.45)
                    }
                    DynamicIslandExpandedRegion(.bottom) {
                        regionView(regions.bottom, canvas: layout, yRange: layout.expandedHeight * 0.45 ... layout.expandedHeight / 2)
                    }
                } else {
                    DynamicIslandExpandedRegion(.leading) {
                        leadingExpanded(context)
                    }
                    DynamicIslandExpandedRegion(.trailing) {
                        trailingExpanded(context)
                    }
                    DynamicIslandExpandedRegion(.bottom) {
                        bottomExpanded(context)
                    }
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

    // MARK: - 按坐标分区

    private struct ExpandedRegions {
        let leading: [IslandItem]
        let trailing: [IslandItem]
        let bottom: [IslandItem]

        static func split(_ layout: IslandLayout) -> ExpandedRegions {
            let topY = layout.expandedHeight * 0.45
            var leading: [IslandItem] = []
            var trailing: [IslandItem] = []
            var bottom: [IslandItem] = []
            for item in layout.items {
                if item.y < topY {
                    if item.x < 0 {
                        leading.append(item)
                    } else {
                        trailing.append(item)
                    }
                } else {
                    bottom.append(item)
                }
            }
            return ExpandedRegions(
                leading: leading.sorted { $0.x < $1.x },
                trailing: trailing.sorted { $0.x > $1.x },
                bottom: bottom.sorted { $0.y < $1.y }
            )
        }
    }

    /// 区域内按相对画布坐标自由定位
    private func regionView(
        _ items: [IslandItem],
        canvas: IslandLayout,
        yRange: ClosedRange<Double>
    ) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(items) { item in
                    islandItemView(item, live: true)
                        .scaleEffect(item.scale)
                        .opacity(item.opacity)
                        .position(
                            x: geo.size.width * item.normalizedX(canvasWidth: canvas.expandedWidth),
                            y: geo.size.height * item.normalizedY(in: yRange, canvasHeight: canvas.expandedHeight)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - 展开态（默认回退）

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
            Image(systemName: "sparkles")
                .font(.caption.weight(.bold))
            Text(context.state.title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(.white)
    }

    private func compactTrailing(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        Text(context.state.subtitle)
            .font(.caption.weight(.bold))
            .monospacedDigit()
            .lineLimit(1)
            .foregroundStyle(.white)
    }

    // MARK: - 迷你态

    private func minimal(_ context: ActivityViewContext<BetLandAttributes>) -> some View {
        Image(systemName: "sparkles")
            .font(.caption.weight(.bold))
            .foregroundStyle(Color(hex: context.state.accentHex))
    }
}

// MARK: - 锁屏视图

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<BetLandAttributes>

    var body: some View {
        if let layout = IslandStore.decode(context.state.layoutJSON) {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    ForEach(layout.items) { item in
                        islandItemView(item, live: true)
                            .scaleEffect(item.scale)
                            .opacity(item.opacity)
                            .position(
                                x: geo.size.width * item.normalizedX(canvasWidth: layout.expandedWidth),
                                y: geo.size.height * item.normalizedY(
                                    in: -layout.expandedHeight / 2 ... layout.expandedHeight / 2,
                                    canvasHeight: layout.expandedHeight
                                )
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .containerBackground(for: .activity) {
                Color.black.opacity(0.8)
            }
        } else {
            // 默认锁屏视图
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
            .containerBackground(for: .activity) {
                Color.black.opacity(0.8)
            }
        }
    }
}
