import SwiftUI

// MARK: - 模板详情页（独立预览 + 参数编辑 + 即时应用）

struct TemplateDetailView: View {
    @Environment(IslandConfig.self) private var config
    let kind: IslandTemplate

    // 应用跳转自定义添加
    @State private var newShortcutName = ""
    @State private var newShortcutSymbol = "app.fill"
    @State private var newShortcutURL = "weixin://"

    private let palette: [String] = [
        "#FFFFFF", "#0A84FF", "#30D158", "#FF9F0A",
        "#FF453A", "#FFD60A", "#BF5AF2", "#64D2FF"
    ]

    var body: some View {
        GlassEffectContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // 实时预览（与岛上渲染同源，所见即所得）
                    TemplatePreview(template: config.template)
                        .padding(.top, 8)

                    // 应用状态与按钮
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(LiveActivitySync.shared.isRunning
                                 ? "实时活动运行中 · 改动自动同步"
                                 : "未启动实时活动 · 改动保存后启动即生效")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            GlassButton(
                                title: "应用到实时活动",
                                systemImage: "arrow.triangle.2.circlepath",
                                tint: .green
                            ) {
                                LiveActivitySync.shared.applyNow(config: config)
                            }
                        }
                    }

                    // 参数编辑
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("\(kind.rawValue)参数", systemImage: "slider.horizontal.3")
                                .font(.headline)
                            paramsSection
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle(kind.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: config.template) { _, _ in
            // 每次更改自动同步到运行中的活动
            LiveActivitySync.shared.sync(config: config)
        }
    }

    // MARK: - 参数表单（按模板类型）

    @ViewBuilder
    private var paramsSection: some View {
        switch kind {
        case .none:
            EmptyView()
        case .leftImage:
            TextField("左侧图标（SF Symbol）", text: Bindable(config).template.leftSymbol)
                .textFieldStyle(.roundedBorder)
            TextField("右侧标题", text: Bindable(config).template.rightTitle)
                .textFieldStyle(.roundedBorder)
            TextField("右侧副标题", text: Bindable(config).template.rightSubtitle)
                .textFieldStyle(.roundedBorder)
            tintPalette(hex: Bindable(config).template.characterColorHex)

        case .character:
            TextField("人偶符号（SF Symbol）", text: Bindable(config).template.characterSymbol)
                .textFieldStyle(.roundedBorder)
            TextField("人偶名字", text: Bindable(config).template.characterName)
                .textFieldStyle(.roundedBorder)
            TextField("副标题", text: Bindable(config).template.characterSubtitle)
                .textFieldStyle(.roundedBorder)
            tintPalette(hex: Bindable(config).template.characterColorHex)

        case .delivery:
            TextField("商家名称", text: Bindable(config).template.merchantName)
                .textFieldStyle(.roundedBorder)
            TextField("配送状态", text: Bindable(config).template.deliveryStatus)
                .textFieldStyle(.roundedBorder)
            TextField("预计送达", text: Bindable(config).template.deliveryETA)
                .textFieldStyle(.roundedBorder)
            TextField("骑手", text: Bindable(config).template.riderName)
                .textFieldStyle(.roundedBorder)
            TextField("收货地址", text: Bindable(config).template.deliveryAddress)
                .textFieldStyle(.roundedBorder)
            GlassSlider(
                title: "配送进度",
                value: Bindable(config).template.deliveryProgress,
                range: 0...1,
                format: "%.0f%%"
            )
            tintPalette(hex: Bindable(config).template.characterColorHex)

        case .ride:
            TextField("车牌号", text: Bindable(config).template.ridePlate)
                .textFieldStyle(.roundedBorder)
            TextField("司机", text: Bindable(config).template.rideDriver)
                .textFieldStyle(.roundedBorder)
            TextField("车型", text: Bindable(config).template.rideCar)
                .textFieldStyle(.roundedBorder)
            TextField("预计到达", text: Bindable(config).template.rideETA)
                .textFieldStyle(.roundedBorder)
            GlassSlider(
                title: "行程进度",
                value: Bindable(config).template.rideProgress,
                range: 0...1,
                format: "%.0f%%"
            )
            tintPalette(hex: Bindable(config).template.characterColorHex)

        case .appShortcut:
            VStack(alignment: .leading, spacing: 10) {
                Text("岛上最多显示 6 个应用，点击直达（需目标 App 支持 URL Scheme）")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(config.template.shortcuts) { s in
                    HStack(spacing: 10) {
                        Image(systemName: s.symbol)
                            .font(.title3)
                            .foregroundStyle(Color(hex: s.colorHex))
                            .frame(width: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.name).font(.footnote.weight(.medium))
                            Text(s.url).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            config.template.shortcuts.removeAll { $0.id == s.id }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("添加应用（名称 / SF Symbol / URL Scheme / 颜色）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        TextField("名称", text: $newShortcutName)
                            .textFieldStyle(.roundedBorder)
                        TextField("符号", text: $newShortcutSymbol)
                            .textFieldStyle(.roundedBorder)
                    }
                    TextField("URL Scheme", text: $newShortcutURL)
                        .textFieldStyle(.roundedBorder)
                    HStack {
                        Button {
                            addShortcut()
                        } label: {
                            Label("添加", systemImage: "plus.circle.fill")
                                .font(.footnote.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(config.accentColor().opacity(0.35))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            config.template.shortcuts = IslandTemplateConfig.defaultShortcuts()
                        } label: {
                            Text("恢复预置")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func tintPalette(hex: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("强调色")
                .font(.footnote)
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                ForEach(palette, id: \.self) { h in
                    Button {
                        hex.wrappedValue = h
                    } label: {
                        Circle()
                            .fill(Color(hex: h))
                            .frame(width: 26, height: 26)
                            .overlay(
                                Circle().stroke(hex.wrappedValue == h ? Color.white : Color.clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func addShortcut() {
        let name = newShortcutName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !newShortcutURL.isEmpty else { return }
        let symbol = newShortcutSymbol.trimmingCharacters(in: .whitespaces)
        config.template.shortcuts.append(
            AppShortcut(
                name: name,
                symbol: symbol.isEmpty ? "app.fill" : symbol,
                url: newShortcutURL,
                colorHex: config.accentHex
            )
        )
        newShortcutName = ""
        newShortcutSymbol = "app.fill"
        newShortcutURL = ""
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
