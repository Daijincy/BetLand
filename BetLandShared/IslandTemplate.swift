import SwiftUI
import Foundation

// MARK: - 展开面板模板分类

enum IslandCategory: String, CaseIterable, Identifiable {
    case efficiency = "效率工具"
    case fun = "趣味玩法"
    case service = "出行与服务"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .efficiency: "timer"
        case .fun: "face.smiling"
        case .service: "car.fill"
        }
    }
}

// MARK: - 展开面板模板（iScreen 式"島"体系，随 ContentState 传递）

enum IslandTemplate: String, Codable, CaseIterable, Identifiable {
    case none = "默认"
    case leftImage = "左图中右字"
    case character = "动图人偶"
    case delivery = "外卖配送"
    case ride = "打车行程"
    case appShortcut = "应用跳转"
    case timer = "计时岛"
    case calendar = "日历岛"
    case weather = "天气岛"
    case pet = "宠物岛"
    case plant = "植物岛"
    case album = "相簿岛"
    case signature = "签名岛"

    var id: String { rawValue }

    var category: IslandCategory {
        switch self {
        case .leftImage, .timer, .calendar, .weather: .efficiency
        case .character, .pet, .plant, .album, .signature: .fun
        case .delivery, .ride, .appShortcut: .service
        case .none: .efficiency
        }
    }

    var systemImage: String {
        switch self {
        case .none: "square.grid.2x2"
        case .leftImage: "photo.on.rectangle"
        case .character: "figure.walk"
        case .delivery: "takeoutbag.and.cup.and.straw.fill"
        case .ride: "car.fill"
        case .appShortcut: "app.badge"
        case .timer: "timer"
        case .calendar: "calendar"
        case .weather: "cloud.sun.fill"
        case .pet: "pawprint.fill"
        case .plant: "leaf.fill"
        case .album: "photo.on.rectangle.angled"
        case .signature: "signature"
        }
    }

    var summary: String {
        switch self {
        case .none: "自由布局画布"
        case .leftImage: "左侧大图 + 右侧文字"
        case .character: "常驻动画人偶"
        case .delivery: "外卖配送进度"
        case .ride: "打车行程信息"
        case .appShortcut: "应用图标快捷跳转"
        case .timer: "倒计时大数字"
        case .calendar: "本周日历速览"
        case .weather: "天气与温度"
        case .pet: "宠物陪伴常驻"
        case .plant: "植物养成进度"
        case .album: "相簿标题展示"
        case .signature: "个性签名文字"
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

    // 计时岛
    var timerTargetDate: Date = Date().addingTimeInterval(3600)
    var timerNote: String = "距离目标"

    // 日历岛
    var calendarNote: String = "今日安排"

    // 天气岛
    var weatherCity: String = "襄阳市"
    var weatherSymbol: String = "cloud.sun.fill"
    var weatherTemp: String = "13-23°"
    var weatherRange: String = "晴 · 微风"

    // 宠物岛
    var petEmoji: String = "🐱"
    var petName: String = "小咪"
    var petStatus: String = "元气满满"

    // 植物岛
    var plantName: String = "向日葵"
    var plantDays: Int = 5
    var plantProgress: Double = 0.6
    var plantStatus: String = "快来岛上种花吧！"

    // 相簿岛
    var albumTitle: String = "相簿"
    var albumSubtitle: String = "我的收藏"
    var albumSymbol: String = "photo.fill"

    // 签名岛
    var signatureText: String = "公主请加油"
    var signatureSubtext: String = "日有熹微"

    init(kind: IslandTemplate = .none) {
        self.kind = kind
    }

    private enum CodingKeys: String, CodingKey {
        case kind, leftSymbol, rightTitle, rightSubtitle
        case characterSymbol, characterName, characterSubtitle, characterColorHex
        case deliveryStatus, deliveryProgress, deliveryETA, merchantName, riderName, deliveryAddress
        case ridePlate, rideDriver, rideCar, rideETA, rideProgress
        case shortcuts
        case timerTargetDate, timerNote
        case calendarNote
        case weatherCity, weatherSymbol, weatherTemp, weatherRange
        case petEmoji, petName, petStatus
        case plantName, plantDays, plantProgress, plantStatus
        case albumTitle, albumSubtitle, albumSymbol
        case signatureText, signatureSubtext
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
        timerTargetDate = try c.decodeIfPresent(Date.self, forKey: .timerTargetDate) ?? Date().addingTimeInterval(3600)
        timerNote = try c.decodeIfPresent(String.self, forKey: .timerNote) ?? "距离目标"
        calendarNote = try c.decodeIfPresent(String.self, forKey: .calendarNote) ?? "今日安排"
        weatherCity = try c.decodeIfPresent(String.self, forKey: .weatherCity) ?? "襄阳市"
        weatherSymbol = try c.decodeIfPresent(String.self, forKey: .weatherSymbol) ?? "cloud.sun.fill"
        weatherTemp = try c.decodeIfPresent(String.self, forKey: .weatherTemp) ?? "13-23°"
        weatherRange = try c.decodeIfPresent(String.self, forKey: .weatherRange) ?? "晴 · 微风"
        petEmoji = try c.decodeIfPresent(String.self, forKey: .petEmoji) ?? "🐱"
        petName = try c.decodeIfPresent(String.self, forKey: .petName) ?? "小咪"
        petStatus = try c.decodeIfPresent(String.self, forKey: .petStatus) ?? "元气满满"
        plantName = try c.decodeIfPresent(String.self, forKey: .plantName) ?? "向日葵"
        plantDays = try c.decodeIfPresent(Int.self, forKey: .plantDays) ?? 5
        plantProgress = try c.decodeIfPresent(Double.self, forKey: .plantProgress) ?? 0.6
        plantStatus = try c.decodeIfPresent(String.self, forKey: .plantStatus) ?? "快来岛上种花吧！"
        albumTitle = try c.decodeIfPresent(String.self, forKey: .albumTitle) ?? "相簿"
        albumSubtitle = try c.decodeIfPresent(String.self, forKey: .albumSubtitle) ?? "我的收藏"
        albumSymbol = try c.decodeIfPresent(String.self, forKey: .albumSymbol) ?? "photo.fill"
        signatureText = try c.decodeIfPresent(String.self, forKey: .signatureText) ?? "公主请加油"
        signatureSubtext = try c.decodeIfPresent(String.self, forKey: .signatureSubtext) ?? "日有熹微"
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
        try c.encode(timerTargetDate, forKey: .timerTargetDate)
        try c.encode(timerNote, forKey: .timerNote)
        try c.encode(calendarNote, forKey: .calendarNote)
        try c.encode(weatherCity, forKey: .weatherCity)
        try c.encode(weatherSymbol, forKey: .weatherSymbol)
        try c.encode(weatherTemp, forKey: .weatherTemp)
        try c.encode(weatherRange, forKey: .weatherRange)
        try c.encode(petEmoji, forKey: .petEmoji)
        try c.encode(petName, forKey: .petName)
        try c.encode(petStatus, forKey: .petStatus)
        try c.encode(plantName, forKey: .plantName)
        try c.encode(plantDays, forKey: .plantDays)
        try c.encode(plantProgress, forKey: .plantProgress)
        try c.encode(plantStatus, forKey: .plantStatus)
        try c.encode(albumTitle, forKey: .albumTitle)
        try c.encode(albumSubtitle, forKey: .albumSubtitle)
        try c.encode(albumSymbol, forKey: .albumSymbol)
        try c.encode(signatureText, forKey: .signatureText)
        try c.encode(signatureSubtext, forKey: .signatureSubtext)
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
            .symbolEffect(.pulse)
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
    case .timer:
        Text(t.timerNote.isEmpty ? "倒计时" : t.timerNote)
            .font(.system(size: 13, weight: .bold, design: .rounded))
    case .calendar:
        VStack(alignment: .leading, spacing: 0) {
            Text(monthName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(dayNumber)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .monospacedDigit()
        }
    case .weather:
        Image(systemName: t.weatherSymbol.isEmpty ? "cloud.sun.fill" : t.weatherSymbol)
            .font(.system(size: 30))
            .foregroundStyle(Color(hex: t.characterColorHex))
    case .pet:
        Text(t.petEmoji.isEmpty ? "🐱" : t.petEmoji)
            .font(.system(size: 34))
    case .plant:
        Text("🌱")
            .font(.system(size: 32))
    case .album:
        Image(systemName: t.albumSymbol.isEmpty ? "photo.fill" : t.albumSymbol)
            .font(.system(size: 32))
            .foregroundStyle(Color(hex: t.characterColorHex))
    case .signature:
        Image(systemName: "text.quote")
            .font(.system(size: 22))
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
    case .timer:
        Text("⏳")
            .font(.system(size: 16))
    case .calendar:
        Text(t.calendarNote)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
    case .weather:
        VStack(alignment: .trailing, spacing: 2) {
            Text(t.weatherCity)
                .font(.system(size: 13, weight: .bold, design: .rounded))
            Text(t.weatherTemp)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    case .pet:
        VStack(alignment: .trailing, spacing: 2) {
            Text(t.petName)
                .font(.system(size: 13, weight: .bold, design: .rounded))
            Text(t.petStatus)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
        }
    case .plant:
        VStack(alignment: .trailing, spacing: 2) {
            Text(t.plantName)
                .font(.system(size: 13, weight: .bold, design: .rounded))
            Text("第 \(t.plantDays) 天")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
        }
    case .album:
        VStack(alignment: .trailing, spacing: 2) {
            Text(t.albumTitle)
                .font(.system(size: 14, weight: .bold, design: .rounded))
            Text(t.albumSubtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
    case .signature:
        Text(t.signatureSubtext)
            .font(.system(size: 11, weight: .medium))
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
                .symbolEffect(.pulse)
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
    case .timer:
        HStack(spacing: 8) {
            Text("⏳")
                .font(.system(size: 12))
            Text(timerInterval: Date.now...t.timerTargetDate, countsDown: true)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .monospacedDigit()
            Spacer()
            Text(t.timerNote)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
    case .calendar:
        CalendarStripView()
    case .weather:
        HStack {
            Text(t.weatherRange)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text("实时天气")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
        }
    case .pet:
        HStack {
            Text("🐾 陪伴中")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text(t.petStatus)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color(hex: t.characterColorHex))
        }
    case .plant:
        VStack(spacing: 6) {
            ProgressView(value: t.plantProgress)
                .progressViewStyle(.linear)
                .tint(Color(hex: t.characterColorHex))
            HStack {
                Text(t.plantStatus)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(t.plantProgress * 100))%")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
        }
    case .album:
        HStack {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Text(t.albumSubtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
        }
    case .signature:
        Text(t.signatureText.isEmpty ? "签名" : t.signatureText)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(Color(hex: t.characterColorHex))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 日历岛：星期条（自动高亮今天）

private struct CalendarStripView: View {
    private var days: [String] { ["一", "二", "三", "四", "五", "六", "日"] }

    var body: some View {
        let cal = Calendar.current
        let today = cal.component(.day, from: Date())
        let weekday = ((cal.component(.weekday, from: Date()) + 5) % 7) + 1  // 1 = 周一
        let monday = today - weekday + 1

        HStack(spacing: 6) {
            ForEach(1...7, id: \.self) { d in
                let dayNum = monday + d - 1
                VStack(spacing: 3) {
                    Text(days[d - 1])
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                    Text("\(dayNum)")
                        .font(.system(size: 10, weight: d == weekday ? .bold : .regular))
                        .monospacedDigit()
                        .foregroundStyle(d == weekday ? Color.black : .white)
                        .frame(width: 22, height: 22)
                        .background(d == weekday ? Color.orange : Color.clear)
                        .clipShape(Circle())
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 模板辅助计算

private var monthName: String {
    let f = DateFormatter()
    f.locale = Locale(identifier: "zh_CN")
    f.dateFormat = "M月"
    return f.string(from: Date())
}

private var dayNumber: String {
    let f = DateFormatter()
    f.locale = Locale(identifier: "zh_CN")
    f.dateFormat = "dd"
    return f.string(from: Date())
}
