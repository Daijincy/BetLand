import SwiftUI

// MARK: - 布局编辑器（液态玻璃画布）

struct EditorView: View {
    @Environment(IslandConfig.self) private var config
    @State private var selectedItemID: UUID?

    var body: some View {
        GlassEffectContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // 画布说明
                    Text("画布模拟灵动岛展开面板（iOS 系统上限：宽 371pt × 高 160pt），拖拽组件调整位置。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 2)

                    // 画布
                    IslandCanvas(selectedItemID: $selectedItemID)
                        .frame(height: 240)

                    // 组件库
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("组件库", systemImage: "plus.circle")
                                .font(.headline)
                            HStack(spacing: 10) {
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
                                        .glassEffect(.clear, in: .rect(cornerRadius: 14))
                                        .interactive()
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
                            Label("胶囊视觉（容器由系统锁定，此处为内部视觉）", systemImage: "capsule")
                                .font(.headline)

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
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Label("组件：\(config.items[idx].type.rawValue)", systemImage: "paintbrush")
                                    .font(.headline)

                                if config.items[idx].type == .text {
                                    TextField("文字内容", text: Bindable(config).items[idx].text)
                                        .textFieldStyle(.roundedBorder)
                                }
                                if config.items[idx].type == .icon {
                                    TextField("SF Symbol 名称", text: Bindable(config).items[idx].icon)
                                        .textFieldStyle(.roundedBorder)
                                }
                                if config.items[idx].type == .progress {
                                    GlassSlider(
                                        title: "进度",
                                        value: Bindable(config).items[idx].progress,
                                        range: 0...1,
                                        format: "%.0f%%"
                                    )
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

                                Button(role: .destructive) {
                                    config.items.remove(at: idx)
                                    selectedItemID = nil
                                } label: {
                                    Label("删除组件", systemImage: "trash")
                                        .font(.footnote.weight(.semibold))
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("布局编辑器")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addItem(_ type: IslandItemType) {
        let defaults: [IslandItemType: IslandItem] = [
            .text: IslandItem(type: .text, text: "新文字"),
            .icon: IslandItem(type: .icon, icon: "star.fill"),
            .progress: IslandItem(type: .progress, progress: 0.5),
            .timer: IslandItem(type: .text, text: "00:00"),
            .image: IslandItem(type: .icon, icon: "photo.fill")
        ]
        var item = defaults[type] ?? IslandItem(type: type)
        item.x = 0
        item.y = 0
        config.items.append(item)
        selectedItemID = item.id
    }
}

// MARK: - 画布

struct IslandCanvas: View {
    @Environment(IslandConfig.self) private var config
    @Binding var selectedItemID: UUID?
    @State private var dragOffset: CGSize = .zero

    private let canvasWidth: CGFloat = 371
    private let canvasHeight: CGFloat = 160

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
                    itemView(item)
                        .position(x: canvasWidth / 2 + item.x, y: canvasHeight / 2 + item.y)
                        .scaleEffect(item.scale)
                        .opacity(item.opacity)
                        .overlay(alignment: .topTrailing) {
                            if selectedItemID == item.id {
                                Image(systemName: "scope")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .padding(4)
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    config.items[idx].x = (canvasWidth / 2 + item.x + value.translation.width - canvasWidth / 2)
                                    config.items[idx].y = (canvasHeight / 2 + item.y + value.translation.height - canvasHeight / 2)
                                }
                                .onEnded { _ in
                                    selectedItemID = item.id
                                }
                        )
                        .onTapGesture {
                            selectedItemID = item.id
                        }
                }
            }
        }
        .frame(width: canvasWidth + 24, height: 220)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func itemView(_ item: IslandItem) -> some View {
        Group {
            switch item.type {
            case .text:
                Text(item.text.isEmpty ? "文字" : item.text)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            case .icon:
                Image(systemName: item.icon.isEmpty ? "star.fill" : item.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(Color(hex: item.tintHex))
            case .progress:
                ProgressView(value: item.progress)
                    .progressViewStyle(.linear)
                    .tint(Color(hex: item.tintHex))
                    .frame(width: 120)
            case .timer, .image:
                Label(item.text.isEmpty ? "00:00" : item.text, systemImage: "timer")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.white)
            }
        }
        .padding(10)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
