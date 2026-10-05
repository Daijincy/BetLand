import SwiftUI
import ActivityKit
import SwiftData
import Darwin

// MARK: - 首页（iScreen 式模板库主页）

struct HomeView: View {
    @Environment(IslandConfig.self) private var config
    @Environment(\.modelContext) private var modelContext
    @Query private var presets: [LayoutPreset]
    @State private var activeActivity: Activity<BetLandAttributes>?
    @State private var didRestore = false
    @State private var statusText = "未启动实时活动"
    @State private var diagnostics = ""
    @State private var liveEnabled = ActivityAuthorizationInfo().areActivitiesEnabled

    var body: some View {
        NavigationStack {
            GlassEffectContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {

                        // 顶部：动态岛 + 开放灵动岛开关
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("BetLand")
                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                                Text("動態島 · 全自定义灵动岛")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(liveEnabled ? "已開啟" : "已關閉")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(liveEnabled ? Color.green : Color.red)
                                Toggle("", isOn: Binding(
                                    get: { liveEnabled },
                                    set: { on in
                                        // 系统授权只能在系统设置中开启
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                ))
                                .labelsHidden()
                                .tint(Color(hex: "#0A84FF"))
                            }
                        }
                        .padding(.top, 6)

                        // 分类模板板块
                        ForEach(IslandCategory.allCases) { cat in
                            categorySection(cat)
                        }

                        // 实时活动控制
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

                        // 运行诊断
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label("运行诊断", systemImage: "stethoscope")
                                        .font(.headline)
                                    Spacer()
                                    Button {
                                        refreshDiagnostics()
                                    } label: {
                                        Label("刷新", systemImage: "arrow.clockwise")
                                            .font(.caption.weight(.semibold))
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundStyle(config.accentColor())
                                }
                                Text(diagnostics.isEmpty ? "点「刷新」查看运行状态" : diagnostics)
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                liveEnabled = ActivityAuthorizationInfo().areActivitiesEnabled
                LiveActivitySync.shared.register(LiveActivityManager.allActivities().first)
                restoreSavedConfigOnce()
            }
        }
    }

    // MARK: - 分类板块（标题 + 两列模板入口）

    private func categorySection(_ cat: IslandCategory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(cat.rawValue, systemImage: cat.systemImage)
                    .font(.headline)
                Spacer()
                Button {
                    // 查看更多：滚动到下一板块（暂为占位）
                } label: {
                    Text("查看更多 >")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            let templates = IslandTemplate.allCases.filter { $0.category == cat && $0 != .none }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(templates) { t in
                    NavigationLink {
                        TemplateDetailView(kind: t)
                    } label: {
                        templateCard(t)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func templateCard(_ t: IslandTemplate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#0A84FF").opacity(0.35), Color(hex: "#64D2FF").opacity(0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: t.systemImage)
                    .font(.system(size: 34))
                    .foregroundStyle(Color(hex: "#64D2FF"))
            }
            .frame(height: 84)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )

            Text(t.rawValue)
                .font(.footnote.weight(.bold))
            Text(t.summary)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    // MARK: - 启动时恢复上次保存的模板 + 胶囊配置（仅一次）

    private func restoreSavedConfigOnce() {
        guard !didRestore else { return }
        didRestore = true
        let active = presets.first(where: { $0.isActive }) ?? presets.first
        guard let snap = active?.decodeConfig() else { return }
        snap.apply(to: config)
        config.presetName = active?.name ?? config.presetName
    }

    // MARK: - 实时活动操作

    private func startActivity() {
        do {
            let activity = try LiveActivityManager.start(config: config)
            activeActivity = activity
            LiveActivitySync.shared.register(activity)
            statusText = "已启动「\(config.presetName)」· 改动即时同步"
        } catch {
            statusText = "启动失败：\(error.localizedDescription)"
        }
    }

    private func endActivity() {
        Task {
            await LiveActivityManager.endAll()
            activeActivity = nil
            LiveActivitySync.shared.register(nil)
            statusText = "已结束全部实时活动"
        }
    }

    // MARK: - 运行诊断

    private func refreshDiagnostics() {
        var lines: [String] = []
        lines.append("Live Activities 授权：\(ActivityAuthorizationInfo().areActivitiesEnabled ? "已开启" : "已关闭")")
        lines.append("当前活动数：\(LiveActivityManager.allActivities().count)")
        lines.append("设备型号：\(deviceModelName())")
        lines.append("灵动岛硬件：\(hasDynamicIsland ? "支持" : "不支持")")
        lines.append("系统版本：iOS \(UIDevice.current.systemVersion)")
        lines.append("App 版本：\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")")
        diagnostics = lines.joined(separator: "\n")
    }

    private var hasDynamicIsland: Bool {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            return window.safeAreaInsets.top >= 59
        }
        return false
    }

    private func deviceModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce("") { id, element in
            guard let value = element.value as? Int8, value != 0 else { return id }
            return id + String(UnicodeScalar(UInt8(value)))
        }
    }
}

#Preview {
    HomeView()
        .environment(IslandConfig())
}
