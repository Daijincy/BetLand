import SwiftUI

// MARK: - 设置

struct SettingsView: View {
    @Environment(IslandConfig.self) private var config

    var body: some View {
        GlassEffectContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("实时活动保活", systemImage: "bolt.heart.fill")
                                .font(.headline)

                            GlassToggle(
                                title: "前台高频刷新",
                                subtitle: "App 在前台时定时调用 activity.update()",
                                isOn: Bindable(config).autoRefresh
                            )
                            GlassToggle(
                                title: "频繁更新模式",
                                subtitle: "NSSupportsLiveActivitiesFrequentUpdates（计时类场景）",
                                isOn: Bindable(config).frequentUpdates
                            )
                            GlassToggle(
                                title: "APNs 离线更新",
                                subtitle: "App 被杀后经推送服务更新（需自建推送后端）",
                                isOn: Bindable(config).pushEnabled
                            )
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("外观", systemImage: "paintpalette.fill")
                                .font(.headline)

                            GlassSlider(
                                title: "胶囊视觉宽度",
                                value: Bindable(config).capsuleVisualWidth,
                                range: 0.6...2.0,
                                format: "%.1f×"
                            )

                            HStack {
                                Text("强调色")
                                    .font(.footnote.weight(.medium))
                                Spacer()
                                TextField("#0A84FF", text: Bindable(config).accentHex)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 110)
                                    .font(.footnote.monospaced())
                            }
                            .padding(.vertical, 2)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("官方硬限制（自用也绕不开）", systemImage: "info.circle.fill")
                                .font(.headline)

                            limitRow("灵动岛展示上限", "8 小时，系统强制销毁")
                            limitRow("锁屏展示上限", "12 小时，之后停止更新")
                            limitRow("状态数据载荷", "≤ 4KB / 次更新")
                            limitRow("单 App 活动数", "系统级总数上限，超出启动失败")
                        }
                    }

                    Text("Build 0.1.0 · iOS 26 · ActivityKit + Liquid Glass")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func limitRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.footnote)
            Spacer()
            Text(value).font(.footnote.monospaced()).foregroundStyle(.secondary)
        }
    }
}
