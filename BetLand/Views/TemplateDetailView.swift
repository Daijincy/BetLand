import SwiftUI

// MARK: - 模板详情页（iScreen 式：大预览 + 编辑入口 + 立即上岛）

struct TemplateDetailView: View {
    @Environment(IslandConfig.self) private var config
    let kind: IslandTemplate

    @State private var islandStatus = ""
    @State private var showPreview = false

    var body: some View {
        GlassEffectContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // 大预览（黑色圆角卡，与岛上渲染同源）
                    TemplatePreview(template: config.template)
                        .padding(.top, 8)

                    // 提示与预览按钮
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

                    // 编辑动态岛面板入口
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

                    // 运行状态
                    Text(islandStatus.isEmpty
                         ? (LiveActivitySync.shared.isRunning ? "实时活动运行中 · 改动自动同步" : "未启动实时活动")
                         : islandStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(16)
                .padding(.bottom, 12)
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
        .sheet(isPresented: $showPreview) {
            TemplatePreviewSheet(template: config.template)
        }
        .safeAreaInset(edge: .bottom) {
            // 立即上岛（底部固定大按钮）
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

// MARK: - 全屏预览

struct TemplatePreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let template: IslandTemplateConfig

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("島 · 预览")
                    .font(.headline)
                    .foregroundStyle(.secondary)
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
