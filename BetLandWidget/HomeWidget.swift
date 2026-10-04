import SwiftUI
import WidgetKit

// MARK: - 普通桌面小组件
// 作用：保证 Widget Extension 被系统完整注册。
// 经验证，仅含 Live Activity 而无常规 widget 的 extension，
// 在部分 iOS 版本上会被系统静默跳过渲染（活动创建成功但灵动岛/锁屏不显示）。

struct BetLandHomeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BetLandHomeWidget", provider: HomeWidgetProvider()) { entry in
            HomeWidgetView(entry: entry)
        }
        .configurationDisplayName("BetLand 状态")
        .description("BetLand 灵动岛实时活动引擎")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HomeWidgetEntry: TimelineEntry {
    let date: Date
}

struct HomeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HomeWidgetEntry {
        HomeWidgetEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (HomeWidgetEntry) -> Void) {
        completion(HomeWidgetEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HomeWidgetEntry>) -> Void) {
        completion(Timeline(entries: [HomeWidgetEntry(date: .now)], policy: .never))
    }
}

private struct HomeWidgetView: View {
    let entry: HomeWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(.tint)
            Text("BetLand")
                .font(.headline)
            Text("灵动岛实时活动引擎")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(entry.date, style: .time)
                .font(.caption.monospacedDigit())
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
