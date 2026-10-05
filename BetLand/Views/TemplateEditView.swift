import SwiftUI

// MARK: - 模板参数编辑页（每类独立页面，改动即时同步）

struct TemplateEditView: View {
    @Environment(IslandConfig.self) private var config
    let kind: IslandTemplate

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

                    // 同源小预览（改动即时反馈）
                    TemplatePreview(template: config.template)
                        .padding(.top, 8)

                    Text("改动会自动同步到运行中的灵动岛")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)

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
        .navigationTitle("編輯 \(kind.rawValue)")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: config.template) { _, _ in
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

        case .timer:
            DatePicker("目标时间", selection: Bindable(config).template.timerTargetDate)
                .datePickerStyle(.compact)
            TextField("备注文字", text: Bindable(config).template.timerNote)
                .textFieldStyle(.roundedBorder)

        case .calendar:
            TextField("备注文字", text: Bindable(config).template.calendarNote)
                .textFieldStyle(.roundedBorder)
            Text("日历岛自动显示本周日期并高亮今天")
                .font(.caption)
                .foregroundStyle(.secondary)

        case .weather:
            TextField("城市", text: Bindable(config).template.weatherCity)
                .textFieldStyle(.roundedBorder)
            TextField("天气符号（SF Symbol）", text: Bindable(config).template.weatherSymbol)
                .textFieldStyle(.roundedBorder)
            TextField("温度", text: Bindable(config).template.weatherTemp)
                .textFieldStyle(.roundedBorder)
            TextField("天气描述", text: Bindable(config).template.weatherRange)
                .textFieldStyle(.roundedBorder)
            tintPalette(hex: Bindable(config).template.characterColorHex)

        case .pet:
            TextField("宠物表情（emoji）", text: Bindable(config).template.petEmoji)
                .textFieldStyle(.roundedBorder)
            TextField("宠物名字", text: Bindable(config).template.petName)
                .textFieldStyle(.roundedBorder)
            TextField("状态文字", text: Bindable(config).template.petStatus)
                .textFieldStyle(.roundedBorder)
            tintPalette(hex: Bindable(config).template.characterColorHex)

        case .plant:
            TextField("植物名字", text: Bindable(config).template.plantName)
                .textFieldStyle(.roundedBorder)
            HStack {
                Text("第几天")
                Spacer()
                Stepper(value: Bindable(config).template.plantDays, in: 0...999) {
                    Text("\(config.template.plantDays) 天")
                        .monospacedDigit()
                }
            }
            GlassSlider(
                title: "生长进度",
                value: Bindable(config).template.plantProgress,
                range: 0...1,
                format: "%.0f%%"
            )
            TextField("状态文字", text: Bindable(config).template.plantStatus)
                .textFieldStyle(.roundedBorder)
            tintPalette(hex: Bindable(config).template.characterColorHex)

        case .album:
            TextField("相簿标题", text: Bindable(config).template.albumTitle)
                .textFieldStyle(.roundedBorder)
            TextField("副标题", text: Bindable(config).template.albumSubtitle)
                .textFieldStyle(.roundedBorder)
            TextField("图标（SF Symbol）", text: Bindable(config).template.albumSymbol)
                .textFieldStyle(.roundedBorder)
            tintPalette(hex: Bindable(config).template.characterColorHex)

        case .signature:
            TextField("签名文字", text: Bindable(config).template.signatureText)
                .textFieldStyle(.roundedBorder)
            TextField("副文字", text: Bindable(config).template.signatureSubtext)
                .textFieldStyle(.roundedBorder)
            tintPalette(hex: Bindable(config).template.characterColorHex)
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
