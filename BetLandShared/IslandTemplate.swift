import SwiftUI
import Foundation

// MARK: - 展开面板模板（iScreen 式预设模板，随 ContentState 传递）

enum IslandTemplate: String, Codable, CaseIterable, Identifiable {
    case none = "默认"
    case leftImage = "左图中右字"
    case character = "动图人偶"
    case delivery = "外卖配送"
    case ride = "打车行程"
    case appShortcut = "应用跳转"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .none: "square.grid.2x2"
        case .leftImage: "photo.on.rectangle"
        case .character: "figure.walk"
        case .delivery: "takeoutbag.and.cup.and.straw.fill"
        case .ride: "car.fill"
        case .appShortcut: "app.badge"
        }
    }
}

// MARK: - 应用快捷跳转项

struct AppShortcut: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String = "微信"
    var symbol: String = "message.fill"
    var url: String = "weixin://"
    var colorHex: String = "#30D158"

    init(id: UUID = UUID(), name: String, symbol: String, url: String, colorHex: String) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.url = url
        self.colorHex = colorHex
    }
}

// MARK: - 模板配置（全字段带默认值 + decodeIfPresent 兼容）

struct IslandTemplateConfig: Codable, Equatable {
    var kind: IslandTemplate = .none

    // 左图中右字
    var leftSymbol: String = "sparkles"
    var rightTitle: String = "BetLand"
    var rightSubtitle: String = "实时活动自定义"

    // 动图人偶
    var characterSymbol: String = "figure.walk"
    var characterName: String = "Bet"
    var characterSubtitle: String = "常驻陪伴中"
    var characterColorHex: String = "#FFD60A"

    // 外卖配送（美团风格）
    var deliveryStatus: String = "配送中"
    var deliveryProgress: Double = 0.4
    var deliveryETA: String = "约 20 分钟"
    var merchantName: String = "美味餐厅"
    var riderName: String = "骑手小张"
    var deliveryAddress: String = "XX 小区 3 栋"

    // 打车行程（滴滴风格）
    var ridePlate: String = "鄂A·88888"
    var rideDriver: String = "王师傅"
    var rideCar: String = "白色 比亚迪"
    var rideETA: String = "3 分钟"
    var rideProgress: Double = 0.7

    // 应用跳转
    var shortcuts: [AppShortcut] = IslandTemplateConfig.defaultShortcuts()

    init(kind: IslandTemplate = .none) {
        self.kind = kind
    }

    private enum CodingKeys: String, CodingKey {
        case kind, leftSymbol, rightTitle, rightSubtitle
        case characterSymbol, characterName, characterSubtitle, characterColorHex
        case deliveryStatus, deliveryProgress, deliveryETA, merchantName, riderName, deliveryAddress
        case ridePlate, rideDriver, rideCar, rideETA, rideProgress
        case shortcuts
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        kind = try c.decodeIfPresent(IslandTemplate.self, forKey: .kind) ?? .none
        leftSymbol = try c.decodeIfPresent(String.self, forKey: .leftSymbol) ?? "sparkles"
        rightTitle = try c.decodeIfPresent(String.self, forKey: .rightTitle) ?? "BetLand"
        rightSubtitle = try c.decodeIfPresent(String.self, forKey: .rightSubtitle) ?? "实时活动自定义"
        characterSymbol = try c.decodeIfPresent(String.self, forKey: .characterSymbol) ?? "figure.walk"
        characterName = try c.decodeIfPresent(String.self, forKey: .characterName) ?? "Bet"
        characterSubtitle = try c.decodeIfPresent(String.self, forKey: .characterSubtitle) ?? "常驻陪伴中"
        characterColorHex = try c.decodeIfPresent(String.self, forKey: .characterColorHex) ?? "#FFD60A"
        deliveryStatus = try c.decodeIfPresent(String.self, forKey: .deliveryStatus) ?? "配送中"
        deliveryProgress = try c.decodeIfPresent(Double.self, forKey: .deliveryProgress) ?? 0.4
        deliveryETA = try c.decodeIfPresent(String.self, forKey: .deliveryETA) ?? "约 20 分钟"
        merchantName = try c.decodeIfPresent(String.self, forKey: .merchantName) ?? "美味餐厅"
        riderName = try c.decodeIfPresent(String.self, forKey: .riderName) ?? "骑手小张"
        deliveryAddress = try c.decodeIfPresent(String.self, forKey: .deliveryAddress) ?? "XX 小区 3 栋"
        ridePlate = try c.decodeIfPresent(String.self, forKey: .ridePlate) ?? "鄂A·88888"
        rideDriver = try c.decodeIfPresent(String.self, forKey: .rideDriver) ?? "王师傅"
        rideCar = try c.decodeIfPresent(String.self, forKey: .rideCar) ?? "白色 比亚迪"
        rideETA = try c.decodeIfPresent(String.self, forKey: .rideETA) ?? "3 分钟"
        rideProgress = try c.decodeIfPresent(Double.self, forKey: .rideProgress) ?? 0.7
        shortcuts = try c.decodeIfPresent([AppShortcut].self, forKey: .shortcuts) ?? IslandTemplateConfig.defaultShortcuts()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(kind, forKey: .kind)
        try c.encode(leftSymbol, forKey: .leftSymbol)
        try c.encode(rightTitle, forKey: .rightTitle)
        try c.encode(rightSubtitle, forKey: .rightSubtitle)
        try c.encode(characterSymbol, forKey: .characterSymbol)
        try c.encode(characterName, forKey: .characterName)
        try c.encode(characterSubtitle, forKey: .characterSubtitle)
        try c.encode(characterColorHex, forKey: .characterColorHex)
        try c.encode(deliveryStatus, forKey: .deliveryStatus)
        try c.encode(deliveryProgress, forKey: .deliveryProgress)
        try c.encode(deliveryETA, forKey: .deliveryETA)
        try c.encode(merchantName, forKey: .merchantName)
        try c.encode(riderName, forKey: .riderName)
        try c.encode(deliveryAddress, forKey: .deliveryAddress)
        try c.encode(ridePlate, forKey: .ridePlate)
        try c.encode(rideDriver, forKey: .rideDriver)
        try c.encode(rideCar, forKey: .rideCar)
        try c.encode(rideETA, forKey: .rideETA)
        try c.encode(rideProgress, forKey: .rideProgress)
        try c.encode(shortcuts, forKey: .shortcuts)
    }

    /// 预置应用快捷跳转列表（URL Scheme 打开对应 App；符号来自系统 SF Symbols）
    static func defaultShortcuts() -> [AppShortcut] {
        [
            AppShortcut(name: "微信", symbol: "message.fill", url: "weixin://", colorHex: "#30D158"),
            AppShortcut(name: "支付宝", symbol: "creditcard.fill", url: "alipay://", colorHex: "#0A84FF"),
            AppShortcut(name: "淘宝", symbol: "bag.fill", url: "taobao://", colorHex: "#FF9F0A"),
            AppShortcut(name: "抖音", symbol: "play.rectangle.fill", url: "snssdk1128://", colorHex: "#FF453A"),
            AppShortcut(name: "美团", symbol: "takeoutbag.and.cup.and.straw.fill", url: "imeituan://", colorHex: "#FFD60A"),
            AppShortcut(name: "高德地图", symbol: "map.fill", url: "iosamap://", colorHex: "#64D2FF")
        ]
    }

    static func encode(_ t: IslandTemplateConfig) -> String {
        guard let data = try? JSONEncoder().encode(t) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func decode(_ json: String) -> IslandTemplateConfig? {
        guard !json.isEmpty, let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(IslandTemplateConfig.self, from: data)
    }
}

// MARK: - 模板渲染（简单布局，与成功版同款风格；供 Widget 使用）

@ViewBuilder
func templateLeadingView(_ t: IslandTemplateConfig) -> some View {
    switch t.kind {
    case .none:
        EmptyView()
    case .leftImage:
        Image(systemName: t.leftSymbol.isEmpty ? "sparkles" : t.leftSymbol)
            .font(.system(size: 34))
            .foregroundStyle(Color(hex: t.characterColorHex))
    case .character:
        Image(systemName: t.characterSymbol.isEmpty ? "figure.walk" : t.characterSymbol)
            .font(.system(size: 26))
            .foregroundStyle(Color(hex: t.characterColorHex))
            .symbolEffect(.breathe)
    case .delivery:
        HStack(spacing: 6) {
            Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                .foregroundStyle(Color(hex: t.characterColorHex))
            Text(t.merchantName)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .lineLimit(1)
        }
    case .ride:
        VStack(alignment: .leading, spacing: 2) {
            Text(t.ridePlate)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .monospacedDigit()
            Text(t.rideDriver)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
    case .appShortcut:
        Image(systemName: "app.badge")
            .font(.system(size: 18))
            .foregroundStyle(Color(hex: t.characterColorHex))
    }
}

@ViewBuilder
func templateTrailingView(_ t: IslandTemplateConfig) -> some View {
    switch t.kind {
    case .none:
        EmptyView()
    case .leftImage:
        VStack(alignment: .trailing, spacing: 2) {
            Text(t.rightTitle.isEmpty ? "BetLand" : t.rightTitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
            Text(t.rightSubtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
    case .character:
        VStack(alignment: .trailing, spacing: 2) {
            Text(t.characterName)
                .font(.system(size: 13, weight: .bold, design: .rounded))
            Text(t.characterSubtitle)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
        }
    case .delivery:
        Text(t.deliveryStatus)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(Color(hex: t.characterColorHex))
    case .ride:
        VStack(alignment: .trailing, spacing: 2) {
            Text(t.rideETA)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .monospacedDigit()
            Text(t.rideCar)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    case .appShortcut:
        Text("\(t.shortcuts.count) 个应用")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

@ViewBuilder
func templateBottomView(_ t: IslandTemplateConfig) -> some View {
    switch t.kind {
    case .none:
        EmptyView()
    case .leftImage:
        HStack {
            Text(t.rightSubtitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
        }
    case .character:
        HStack(spacing: 8) {
            Image(systemName: t.characterSymbol.isEmpty ? "figure.walk" : t.characterSymbol)
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: t.characterColorHex))
                .symbolEffect(.breathe)
            Text("\(t.characterName) · \(t.characterSubtitle)")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
        }
    case .delivery:
        VStack(spacing: 6) {
            ProgressView(value: t.deliveryProgress)
                .progressViewStyle(.linear)
                .tint(Color(hex: t.characterColorHex))
            HStack {
                Text("\(t.riderName) · \(t.deliveryAddress)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Text(t.deliveryETA)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
        }
    case .ride:
        VStack(spacing: 6) {
            ProgressView(value: t.rideProgress)
                .progressViewStyle(.linear)
                .tint(Color(hex: t.characterColorHex))
            HStack {
                Text("\(t.rideDriver) · \(t.rideCar)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Text(t.rideETA)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
        }
    case .appShortcut:
        HStack(spacing: 14) {
            ForEach(Array(t.shortcuts.prefix(6))) { s in
                Link(destination: URL(string: s.url) ?? URL(string: "betland://")!) {
                    VStack(spacing: 3) {
                        Image(systemName: s.symbol)
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: s.colorHex))
                        Text(s.name)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .frame(width: 36)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
