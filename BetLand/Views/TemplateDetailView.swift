import SwiftUI
import SwiftData

// MARK: - 模板详情页（胶囊编辑预览 + 展开编辑 + 保存 + 立即上岛）

struct TemplateDetailView: View {
    @Environment(IslandConfig.self) private var config
    @Environment(\.modelContext) private var modelContext
    @Query private var presets: [LayoutPreset]
    let kind: IslandTemplate

    @State private var islandStatus = ""
    @State private var savedTip = ""
    @State private var showPreview = false

    var body: some View {
        GlassEffectContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // 预览区：胶囊 + 展开（均与岛上渲染同源）
                    VStack(spacing: 8) {
                        CapsulePreview(config: config)
                        Text("胶囊 · 紧凑态（左/右 + 图标）")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    TemplatePreview(template: config.template)
                        .overlay(alignment: .bottomTrailing) {
                            Text("展开态预览")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .padding(10)
                        }

                    // 提示与全屏预览
                    HStack {
                        Text("僅在鎖定畫面通知顯示")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            showPreview = true
                        } label: {
                            Text("預覽")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(config.accentColor())
                        }
                        .buttonStyle(.plain)
                    }

                    // 胶囊编辑（详情页内直接改 + 即时预览 + 即时同步）
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("膠囊設置", systemImage: "capsule")
                                .font(.headline)
                            TextField("胶囊左侧文字", text: Bindable(config).capsuleLeadingText)
                                .textFieldStyle(.roundedBorder)
                            TextField("胶囊右侧文字", text: Bindable(config).capsuleTrailingText)
                                .textFieldStyle(.roundedBorder)
                            TextField("胶囊图标（SF Symbol）", text: Bindable(config).capsuleIcon)
                                .textFieldStyle(.roundedBorder)
                            GlassSlider(
                                title: "视觉宽度",
                                value: Bindable(config).capsuleVisualWidth,
                                range: 0.6...2.0,
                                format: "%.1f×"
                            )
                            GlassSlider(
                                title: "胶囊圆角",
                                value: Bindable(config).capsuleCornerRadius,
                                range: 0...40,
                                format: "%.0f pt"
                            )
                        }
                    }

                    // 展开面板编辑入口
                    NavigationLink {
                        TemplateEditView(kind: kind)
                    } label: {
                        HStack {
                            Label("編輯動態島面板", systemImage: "slider.horizontal.3")
                                .font(.body.weight(.semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(14)
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    // 保存
                    HStack(spacing: 12) {
                        GlassButton(
                            title: "保存配置",
                            systemImage: "checkmark.circle.fill",
                            tint: .green
                        ) { savePreset() }
                    }
                    if !savedTip.isEmpty {
                        Text(savedTip)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    // 运行状态
                    Text(islandStatus.isEmpty
                         ? (LiveActivitySync.shared.isRunning ? "实时活动运行中 · 改动自动同步" : "未启动实时活动")
                         : islandStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 12)
                }
                .padding(16)
            }
        }
        .navigationTitle(kind.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            config.template.kind = kind
        }
        .onChange(of: config.template) { _, _ in
            LiveActivitySync.shared.sync(config: config)
        }
        .onChange(of: config.capsuleLeadingText) { _, _ in
            LiveActivitySync.shared.sync(config: config)
        }
        .onChange(of: config.capsuleTrailingText) { _, _ in
            LiveActivitySync.shared.sync(config: config)
        }
        .onChange(of: config.capsuleIcon) { _, _ in
            LiveActivitySync.shared.sync(config: config)
        }
        .onChange(of: config.capsuleVisualWidth) { _, _ in
            LiveActivitySync.shared.sync(config: config)
        }
        .onChange(of: config.capsuleCornerRadius) { _, _ in
            LiveActivitySync.shared.sync(config: config)
        }
        .sheet(isPresented: $showPreview) {
            TemplatePreviewSheet(template: config.template, config: config)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                startIsland()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("立即上島")
                        .font(.body.weight(.heavy))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#0A84FF"), Color(hex: "#64D2FF")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - 保存当前模板 + 胶囊配置（SwiftData 持久化）

    private func savePreset() {
        config.template.kind = kind
        let name = kind.rawValue
        let snapshot = ConfigSnapshot.from(config: config)
        if let existing = presets.first(where: { $0.name == name }) {
            existing.configJSON = ConfigSnapshot.encode(snapshot)
            existing.updatedAt = Date()
            existing.isActive = true
            for p in presets where p.name != name { p.isActive = false }
        } else {
            let layout = IslandLayout.sample(name: name)
            let preset = LayoutPreset(
                name: name,
                layout: layout,
                isActive: true,
                configJSON: ConfigSnapshot.encode(snapshot)
            )
            modelContext.insert(preset)
            for p in presets { p.isActive = false }
        }
        try? modelContext.save()
        savedTip = "已保存「\(name)」· 下次打开自动恢复"
    }

    private func startIsland() {
        config.template.kind = kind
        do {
            let activity = try LiveActivityManager.start(config: config)
            LiveActivitySync.shared.register(activity)
            islandStatus = "已上島 · 在灵动岛或锁屏查看"
        } catch {
            islandStatus = "启动失败：\(error.localizedDescription)"
        }
    }
}

// MARK: - 胶囊预览（模拟紧凑态，宽度随设置缩放）

struct CapsulePreview: View {
    let config: IslandConfig

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: config.capsuleIcon.isEmpty ? "sparkles" : config.capsuleIcon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: config.accentHex))
            Text(config.capsuleLeadingText)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
            Spacer(minLength: 8)
            Text(config.capsuleTrailingText)
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .frame(width: 230 * config.capsuleVisualWidth, height: 36)
        .background(.black.opacity(0.95))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 1))
        .animation(.spring(duration: 0.25), value: config.capsuleVisualWidth)
    }
}

// MARK: - 全屏预览

struct TemplatePreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let template: IslandTemplateConfig
    let config: IslandConfig

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("島 · 预览")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                CapsulePreview(config: config)
                TemplatePreview(template: template)
                    .padding(.horizontal, 16)
                Button {
                    dismiss()
                } label: {
                    Text("关闭")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - 模板实时预览（模拟展开面板，渲染与岛上同源）

struct TemplatePreview: View {
    let template: IslandTemplateConfig

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .fill(.black.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 44, style: .continuous)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 12, y: 6)

            VStack(spacing: 10) {
                HStack(alignment: .top) {
                    templateLeadingView(template)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    templateTrailingView(template)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                Spacer(minLength: 4)
                templateBottomView(template)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
    }
}
