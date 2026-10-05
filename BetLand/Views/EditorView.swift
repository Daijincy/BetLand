import SwiftUI
import SwiftData

// MARK: - 布局编辑器（液态玻璃画布 + 预设持久化）

struct EditorView: View {
    @Environment(IslandConfig.self) private var config
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LayoutPreset.createdAt) private var presets: [LayoutPreset]
    @State private var selectedItemID: UUID?

    private let palette: [String] = [
        "#FFFFFF", "#0A84FF", "#30D158", "#FF9F0A",
        "#FF453A", "#FFD60A", "#BF5AF2", "#64D2FF"
    ]

    var body: some View {
        GlassEffectContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // 预设管理
                    presetBar

                    // 模板库（iScreen 式小入口）
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("模板库", systemImage: "square.grid.2x2")
                                .font(.headline)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(IslandTemplate.allCases.filter { $0 != .none }) { kind in
                                    NavigationLink {
                                        TemplateDetailView(kind: kind)
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: kind.systemImage)
                                                .font(.title3)
                                                .foregroundStyle(config.accentColor())
                                            Text(kind.rawValue)
                                                .font(.caption2)
                                            Text("单独预览")
                                                .font(.system(size: 8))
                                                .foregroundStyle(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 14))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // 画布说明
                    Text("画布模拟灵动岛展开面板。真机宽度/高度由 iOS 系统决定（高度上限 160pt），此处滑块仅预览模拟。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 2)

                    // 画布
                    IslandCanvas(selectedItemID: $selectedItemID)

                    // 画布实时尺寸
                    Text("当前画布：\(Int(config.expandedWidth)) × \(Int(config.expandedHeight)) pt · 组件 \(config.items.count) 个")
                        .font(.caption2.monospaced())
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)

                    // 组件库
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("组件库", systemImage: "plus.circle")
                                .font(.headline)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(IslandItemType.allCases) { type in
                                    Button {
                                        addItem(type)
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: type.systemImage)
                                                .font(.title3)
                                            Text(type.rawValue)
                                                .font(.caption2)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 14))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // 展开面板参数
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("展开面板", systemImage: "rectangle.3.group")
                                .font(.headline)

                            GlassSlider(
                                title: "展开宽度（预览）",
                                value: Bindable(config).expandedWidth,
                                range: 200...450,
                                format: "%.0f pt"
                            )
                            GlassSlider(
                                title: "展开高度",
                                value: Bindable(config).expandedHeight,
                                range: 84...160,
                                format: "%.0f pt"
                            )
                            GlassSlider(
                                title: "圆角",
                                value: Bindable(config).expandedCornerRadius,
                                range: 0...60,
                                format: "%.0f pt"
                            )
                        }
                    }

                    // 胶囊视觉
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("胶囊（容器由系统锁定，此处为内部视觉）", systemImage: "capsule")
                                .font(.headline)

                            TextField("胶囊左侧文字", text: Bindable(config).capsuleLeadingText)
                                .textFieldStyle(.roundedBorder)
                            TextField("胶囊右侧文字", text: Bindable(config).capsuleTrailingText)
                                .textFieldStyle(.roundedBorder)

                            GlassSlider(
                                title: "视觉宽度倍数",
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

                    // 选中组件参数
                    if let id = selectedItemID,
                       let idx = config.items.firstIndex(where: { $0.id == id }) {
                        selectedItemPanel(idx)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("布局编辑器")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 预设管理

    private var presetBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("预设", systemImage: "square.stack.3d.up")
                    .font(.headline)
                Spacer()
                Text("保存后启动实时活动即上岛生效")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presets) { p in
                        Button {
                            loadPreset(p)
                        } label: {
                            Text(p.name)
                                .font(.footnote.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    config.presetID == p.id
                                        ? config.accentColor().opacity(0.35)
                                        : Color.white.opacity(0.1)
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        newPreset()
                    } label: {
                        Label("新建", systemImage: "plus")
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        savePreset()
                    } label: {
                        Label("保存", systemImage: "square.and.arrow.down")
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(config.accentColor().opacity(0.4))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    if let p = presets.first(where: { $0.id == config.presetID }) {
                        Button(role: .destructive) {
                            deletePreset(p)
                        } label: {
                            Label("删除", systemImage: "trash")
                                .font(.footnote.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func newPreset() {
        let name = "新预设 \(presets.count + 1)"
        let layout = IslandLayout.sample(name: name)
        layout.apply(to: config)
        let preset = LayoutPreset(name: name, layout: layout, isActive: true)
        modelContext.insert(preset)
        try? modelContext.save()
        LiveActivitySync.shared.sync(config: config)
    }

    private func savePreset() {
        let layout = IslandLayout.from(config: config)
        if let existing = presets.first(where: { $0.id == layout.id }) {
            existing.name = layout.name
            existing.layoutJSON = IslandStore.encode(layout)
            existing.updatedAt = Date()
            existing.isActive = true
        } else {
            let preset = LayoutPreset(name: layout.name, layout: layout, isActive: true)
            modelContext.insert(preset)
        }
        for p in presets where p.id != layout.id {
            p.isActive = false
        }
        try? modelContext.save()
        // 保存后即时同步到运行中的活动
        LiveActivitySync.shared.sync(config: config)
    }

    private func loadPreset(_ preset: LayoutPreset) {
        guard let layout = preset.decodeLayout() else { return }
        layout.apply(to: config)
        // 切换预设即时同步
        LiveActivitySync.shared.sync(config: config)
    }

    private func deletePreset(_ preset: LayoutPreset) {
        modelContext.delete(preset)
        try? modelContext.save()
        if config.presetID == preset.id {
            config.presetID = UUID()
            config.presetName = "未命名"
        }
    }

    // MARK: - 组件操作

    private func addItem(_ type: IslandItemType) {
        var item = IslandItem(type: type)
        switch type {
        case .text:
            item.text = "新文字"
        case .icon:
            item.icon = "star.fill"
        case .progress:
            item.progress = 0.5
        case .timer:
            item.targetDate = Date().addingTimeInterval(3600)
        case .clock:
            item.fontSize = 14
        case .date:
            item.targetDate = Date().addingTimeInterval(86400)
        }
        item.x = 0
        item.y = 0
        config.items.append(item)
        selectedItemID = item.id
    }

    // MARK: - 属性面板

    private func selectedItemPanel(_ idx: Int) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("组件：\(config.items[idx].type.rawValue)", systemImage: "paintbrush")
                        .font(.headline)
                    Spacer()
                    Button {
                        let copy = config.items[idx]
                        var dup = copy
                        dup.id = UUID()
                        dup.x += 12
                        dup.y += 12
                        config.items.append(dup)
                        selectedItemID = dup.id
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(config.accentColor())

                    Button(role: .destructive) {
                        config.items.remove(at: idx)
                        selectedItemID = nil
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                }

                switch config.items[idx].type {
                case .text:
                    TextField("文字内容", text: Bindable(config).items[idx].text)
                        .textFieldStyle(.roundedBorder)
                    alignmentPicker(idx)
                case .icon:
                    TextField("SF Symbol 名称", text: Bindable(config).items[idx].icon)
                        .textFieldStyle(.roundedBorder)
                case .progress:
                    GlassSlider(
                        title: "进度",
                        value: Bindable(config).items[idx].progress,
                        range: 0...1,
                        format: "%.0f%%"
                    )
                case .timer:
                    DatePicker(
                        "倒计时目标",
                        selection: Bindable(config).items[idx].targetDate,
                        in: Date()...
                    )
                case .clock:
                    EmptyView()
                case .date:
                    DatePicker(
                        "目标日期",
                        selection: Bindable(config).items[idx].targetDate
                    )
                }

                GlassSlider(
                    title: "字号",
                    value: Bindable(config).items[idx].fontSize,
                    range: 8...40,
                    format: "%.0f pt"
                )

                Toggle("粗体", isOn: Bindable(config).items[idx].bold)

                // 颜色色板
                VStack(alignment: .leading, spacing: 8) {
                    Text("颜色")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 10) {
                        ForEach(palette, id: \.self) { hex in
                            Button {
                                config.items[idx].tintHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 26, height: 26)
                                    .overlay(
                                        Circle().stroke(
                                            config.items[idx].tintHex == hex ? Color.white : Color.clear,
                                            lineWidth: 2
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                GlassSlider(
                    title: "缩放",
                    value: Bindable(config).items[idx].scale,
                    range: 0.5...3.0,
                    format: "%.1f×"
                )
                GlassSlider(
                    title: "不透明度",
                    value: Bindable(config).items[idx].opacity,
                    range: 0.1...1.0,
                    format: "%.2f"
                )
            }
        }
    }

    private func alignmentPicker(_ idx: Int) -> some View {
        Picker("对齐", selection: Bindable(config).items[idx].alignment) {
            ForEach(IslandItem.AlignmentKey.allCases) { a in
                Text(a.title).tag(a)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - 画布

struct IslandCanvas: View {
    @Environment(IslandConfig.self) private var config
    @Binding var selectedItemID: UUID?

    /// 拖拽起始状态：记录按下瞬间组件位置，防止视图重建导致的位移叠加
    private struct DragStart {
        let id: UUID
        let x: Double
        let y: Double
    }
    @State private var dragStart: DragStart?

    private var canvasWidth: CGFloat { CGFloat(config.expandedWidth) }
    private var canvasHeight: CGFloat { CGFloat(config.expandedHeight) }

    var body: some View {
        ZStack {
            // 画布底框
            RoundedRectangle(cornerRadius: config.expandedCornerRadius, style: .continuous)
                .fill(.black.opacity(config.expandedBackgroundOpacity))
                .frame(width: canvasWidth, height: canvasHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: config.expandedCornerRadius, style: .continuous)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 12, y: 6)

            // 组件
            ForEach(config.items) { item in
                if let idx = config.items.firstIndex(where: { $0.id == item.id }) {
                    islandItemView(item, live: false)
                        .position(x: canvasWidth / 2 + item.x, y: canvasHeight / 2 + item.y)
                        .scaleEffect(item.scale)
                        .opacity(item.opacity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    selectedItemID == item.id ? config.accentColor() : .white.opacity(0.12),
                                    lineWidth: selectedItemID == item.id ? 2 : 1
                                )
                        )
                        .padding(2)
                        .overlay(alignment: .topTrailing) {
                            if selectedItemID == item.id {
                                Image(systemName: "scope")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .padding(3)
                                    .background(config.accentColor().opacity(0.8))
                                    .clipShape(Circle())
                            }
                        }
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 1)
                                .onChanged { value in
                                    if dragStart == nil || dragStart?.id != item.id {
                                        dragStart = DragStart(id: item.id, x: item.x, y: item.y)
                                    }
                                    guard let start = dragStart, start.id == item.id,
                                          let i = config.items.firstIndex(where: { $0.id == item.id }) else { return }
                                    config.items[i].x = start.x + Double(value.translation.width)
                                    config.items[i].y = start.y + Double(value.translation.height)
                                }
                                .onEnded { _ in
                                    dragStart = nil
                                    selectedItemID = item.id
                                }
                        )
                        .onTapGesture {
                            selectedItemID = item.id
                        }
                }
            }
        }
        .frame(width: canvasWidth, height: canvasHeight)
        .frame(maxWidth: .infinity)
    }
}
