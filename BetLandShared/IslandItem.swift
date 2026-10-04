import SwiftUI
import Foundation

// MARK: - 灵动岛组件类型（App 与 Widget 共享）

enum IslandItemType: String, Codable, CaseIterable, Identifiable {
    case text = "文字"
    case icon = "图标"
    case progress = "进度条"
    case timer = "倒计时"
    case clock = "时钟"
    case date = "日期"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .text: "textformat"
        case .icon: "star.fill"
        case .progress: "chart.bar.fill"
        case .timer: "timer"
        case .clock: "clock.fill"
        case .date: "calendar"
        }
    }

    var defaultText: String {
        switch self {
        case .text: "新文字"
        case .timer: "12:00:00"
        case .clock: "12:34"
        case .date: "10月5日"
        default: ""
        }
    }
}

// MARK: - 单个可摆放组件（Codable，兼容旧数据缺字段）

struct IslandItem: Identifiable, Codable, Hashable {

    enum AlignmentKey: String, Codable, CaseIterable, Identifiable {
        case leading, center, trailing
        var id: String { rawValue }
        var title: String {
            switch self {
            case .leading: "左对齐"
            case .center: "居中"
            case .trailing: "右对齐"
            }
        }
        var swiftUI: Alignment {
            switch self {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            }
        }
        var textAlignment: TextAlignment {
            switch self {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            }
        }
    }

    var id: UUID = UUID()
    var type: IslandItemType = .text
    var x: Double = 0        // 相对画布中心的偏移（pt）
    var y: Double = 0
    var scale: Double = 1.0
    var opacity: Double = 1.0
    var text: String = ""
    var icon: String = "star.fill"
    var progress: Double = 0.6
    var tintHex: String = "#0A84FF"

    // 新增：样式与实时数据
    var fontSize: Double = 15
    var bold: Bool = true
    var alignment: AlignmentKey = .center
    var targetDate: Date = Date().addingTimeInterval(3600)

    init(
        id: UUID = UUID(),
        type: IslandItemType = .text,
        x: Double = 0,
        y: Double = 0,
        scale: Double = 1.0,
        opacity: Double = 1.0,
        text: String = "",
        icon: String = "star.fill",
        progress: Double = 0.6,
        tintHex: String = "#0A84FF",
        fontSize: Double = 15,
        bold: Bool = true,
        alignment: AlignmentKey = .center,
        targetDate: Date = Date().addingTimeInterval(3600)
    ) {
        self.id = id
        self.type = type
        self.x = x
        self.y = y
        self.scale = scale
        self.opacity = opacity
        self.text = text
        self.icon = icon
        self.progress = progress
        self.tintHex = tintHex
        self.fontSize = fontSize
        self.bold = bold
        self.alignment = alignment
        self.targetDate = targetDate
    }

    private enum CodingKeys: String, CodingKey {
        case id, type, x, y, scale, opacity, text, icon, progress, tintHex
        case fontSize, bold, alignment, targetDate
    }

    // 健壮解码：旧数据缺新增字段时使用默认值
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        type = try c.decodeIfPresent(IslandItemType.self, forKey: .type) ?? .text
        x = try c.decodeIfPresent(Double.self, forKey: .x) ?? 0
        y = try c.decodeIfPresent(Double.self, forKey: .y) ?? 0
        scale = try c.decodeIfPresent(Double.self, forKey: .scale) ?? 1.0
        opacity = try c.decodeIfPresent(Double.self, forKey: .opacity) ?? 1.0
        text = try c.decodeIfPresent(String.self, forKey: .text) ?? ""
        icon = try c.decodeIfPresent(String.self, forKey: .icon) ?? "star.fill"
        progress = try c.decodeIfPresent(Double.self, forKey: .progress) ?? 0.6
        tintHex = try c.decodeIfPresent(String.self, forKey: .tintHex) ?? "#0A84FF"
        fontSize = try c.decodeIfPresent(Double.self, forKey: .fontSize) ?? 15
        bold = try c.decodeIfPresent(Bool.self, forKey: .bold) ?? true
        alignment = try c.decodeIfPresent(AlignmentKey.self, forKey: .alignment) ?? .center
        targetDate = try c.decodeIfPresent(Date.self, forKey: .targetDate) ?? Date().addingTimeInterval(3600)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(type, forKey: .type)
        try c.encode(x, forKey: .x)
        try c.encode(y, forKey: .y)
        try c.encode(scale, forKey: .scale)
        try c.encode(opacity, forKey: .opacity)
        try c.encode(text, forKey: .text)
        try c.encode(icon, forKey: .icon)
        try c.encode(progress, forKey: .progress)
        try c.encode(tintHex, forKey: .tintHex)
        try c.encode(fontSize, forKey: .fontSize)
        try c.encode(bold, forKey: .bold)
        try c.encode(alignment, forKey: .alignment)
        try c.encode(targetDate, forKey: .targetDate)
    }

    // 画布上的相对坐标（0~1），供灵动岛分区渲染映射
    func normalizedX(canvasWidth: Double) -> Double {
        guard canvasWidth > 0 else { return 0.5 }
        return min(max((x + canvasWidth / 2) / canvasWidth, 0), 1)
    }

    func normalizedY(in range: ClosedRange<Double>, canvasHeight: Double) -> Double {
        let span = range.upperBound - range.lowerBound
        guard canvasHeight > 0, span > 0 else { return 0.5 }
        return min(max((y - range.lowerBound) / span, 0), 1)
    }

    static func sample() -> [IslandItem] {
        [
            IslandItem(type: .icon, x: -140, y: -30, icon: "sparkles", tintHex: "#FFD60A", fontSize: 20),
            IslandItem(type: .text, x: -20, y: -30, text: "BetLand", fontSize: 18),
            IslandItem(type: .progress, x: 0, y: 30, progress: 0.6, tintHex: "#0A84FF", fontSize: 14),
            IslandItem(type: .timer, x: 120, y: 30, tintHex: "#30D158", fontSize: 14, targetDate: Date().addingTimeInterval(7200))
        ]
    }
}

// MARK: - 组件渲染（App 编辑器与 Widget 实时活动共用）

@ViewBuilder
func islandItemView(_ item: IslandItem, live: Bool = false) -> some View {
    let font = Font.system(size: item.fontSize, weight: item.bold ? .semibold : .regular, design: .rounded)
    let tint = Color(hex: item.tintHex)
    switch item.type {
    case .text:
        Text(item.text.isEmpty ? "文字" : item.text)
            .font(font)
            .multilineTextAlignment(item.alignment.textAlignment)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, alignment: item.alignment.swiftUI)
    case .icon:
        Image(systemName: item.icon.isEmpty ? "star.fill" : item.icon)
            .font(.system(size: item.fontSize))
            .foregroundStyle(tint)
    case .progress:
        ProgressView(value: item.progress)
            .progressViewStyle(.linear)
            .tint(tint)
            .frame(width: max(48, item.fontSize * 9))
    case .timer:
        if live {
            // Live Activity 内自动每秒刷新
            Text(timerInterval: Date.now...item.targetDate, countsDown: true)
                .font(font.monospacedDigit())
                .foregroundStyle(tint)
        } else {
            Text("12:34:56")
                .font(font.monospacedDigit())
                .foregroundStyle(tint)
        }
    case .clock:
        if live {
            // Live Activity 内时钟自动更新
            Text(Date.now, style: .time)
                .font(font.monospacedDigit())
                .foregroundStyle(tint)
        } else {
            Text("12:34")
                .font(font.monospacedDigit())
                .foregroundStyle(tint)
        }
    case .date:
        Text(item.targetDate, style: .date)
            .font(font)
            .foregroundStyle(tint)
    }
}
