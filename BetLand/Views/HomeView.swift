import SwiftUI
import ActivityKit

// MARK: - 首页

struct HomeView: View {
    @Environment(IslandConfig.self) private var config
    @State private var activeActivity: Activity<BetLandAttributes>?
    @State private var statusText = "未启动实时活动"

    var body: some View {
        NavigationStack {
            GlassEffectContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // 顶部品牌区
                        VStack(alignment: .leading, spacing: 6) {
                            Text("BetLand")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                            Text("全自定义灵动岛 · iOS 26 Liquid Glass")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 8)

                        // 实时活动控制卡
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Label("实时活动控制", systemImage: "livephoto")
                                    .font(.headline)

                                HStack(spacing: 12) {
                                    GlassButton(
                                        title: "启动",
                                        systemImage: "play.fill",
                                        tint: .green
                                    ) { startActivity() }

                                    GlassButton(
                                        title: activeActivity == nil ? "结束" : "结束全部",
                                        systemImage: "stop.fill",
                                        tint: .red,
                                        prominent: false
                                    ) { endActivity() }
                                }

                                Text(statusText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .monospaced()
                            }
                        }

                        // 功能入口
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Label("功能入口", systemImage: "square.grid.2x2")
                                    .font(.headline)

                                NavigationLink { EditorView() } label: {
                                    entryRow("布局编辑器", "slider.horizontal.3", "自由摆放展开面板控件")
                                }
                                .buttonStyle(.plain)

                                NavigationLink { SettingsView() } label: {
                                    entryRow("设置", "gearshape.fill", "保活 / 频繁更新 / 配色")
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // 参数速览
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("当前参数", systemImage: "slider.horizontal.3")
                                    .font(.headline)
                                paramRow("展开高度", "\(Int(config.expandedHeight)) pt")
                                paramRow("胶囊视觉宽度", String(format: "%.1f×", config.capsuleVisualWidth))
                                paramRow("实时活动", config.autoRefresh ? "前台高频刷新" : "手动更新")
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("BetLand")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func entryRow(_ title: String, _ icon: String, _ sub: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(config.accentColor())
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.weight(.medium))
                Text(sub).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private func paramRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.footnote)
            Spacer()
            Text(value).font(.footnote.monospacedDigit()).foregroundStyle(.secondary)
        }
    }

    // MARK: - 实时活动操作

    private func startActivity() {
        do {
            let activity = try LiveActivityManager.start(config: config)
            activeActivity = activity
            statusText = "已启动 · 灵动岛最长 8h / 锁屏 12h"
        } catch {
            statusText = "启动失败：\(error.localizedDescription)"
        }
    }

    private func endActivity() {
        Task {
            await LiveActivityManager.endAll()
            activeActivity = nil
            statusText = "已结束全部实时活动"
        }
    }
}

#Preview {
    HomeView()
        .environment(IslandConfig())
}
