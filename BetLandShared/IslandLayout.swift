import Foundation

// MARK: - 完整布局快照（App 编辑 → 序列化 → 预设持久化；模板随 ContentState 上岛）

struct IslandLayout: Codable, Equatable {
    var id: UUID
    var name: String
    var expandedWidth: Double
    var expandedHeight: Double
    var expandedCornerRadius: Double
    var expandedBackgroundOpacity: Double
    var capsuleLeadingText: String
    var capsuleTrailingText: String
    var capsuleIcon: String
    var capsuleVisualWidth: Double
    var capsuleCornerRadius: Double
    var accentHex: String
    var darkMode: Bool
    var autoRefresh: Bool
    var items: [IslandItem]
    var template: IslandTemplateConfig

    init(
        id: UUID, name: String,
        expandedWidth: Double, expandedHeight: Double,
        expandedCornerRadius: Double, expandedBackgroundOpacity: Double,
        capsuleLeadingText: String, capsuleTrailingText: String, capsuleIcon: String,
        capsuleVisualWidth: Double, capsuleCornerRadius: Double,
        accentHex: String, darkMode: Bool, autoRefresh: Bool,
        items: [IslandItem],
        template: IslandTemplateConfig = IslandTemplateConfig()
    ) {
        self.id = id
        self.name = name
        self.expandedWidth = expandedWidth
        self.expandedHeight = expandedHeight
        self.expandedCornerRadius = expandedCornerRadius
        self.expandedBackgroundOpacity = expandedBackgroundOpacity
        self.capsuleLeadingText = capsuleLeadingText
        self.capsuleTrailingText = capsuleTrailingText
        self.capsuleIcon = capsuleIcon
        self.capsuleVisualWidth = capsuleVisualWidth
        self.capsuleCornerRadius = capsuleCornerRadius
        self.accentHex = accentHex
        self.darkMode = darkMode
        self.autoRefresh = autoRefresh
        self.items = items
        self.template = template
    }

    /// 从当前编辑态配置生成快照
    static func from(config: IslandConfig) -> IslandLayout {
        IslandLayout(
            id: config.presetID,
            name: config.presetName,
            expandedWidth: config.expandedWidth,
            expandedHeight: config.expandedHeight,
            expandedCornerRadius: config.expandedCornerRadius,
            expandedBackgroundOpacity: config.expandedBackgroundOpacity,
            capsuleLeadingText: config.capsuleLeadingText,
            capsuleTrailingText: config.capsuleTrailingText,
            capsuleIcon: config.capsuleIcon,
            capsuleVisualWidth: config.capsuleVisualWidth,
            capsuleCornerRadius: config.capsuleCornerRadius,
            accentHex: config.accentHex,
            darkMode: config.darkMode,
            autoRefresh: config.autoRefresh,
            items: config.items,
            template: config.template
        )
    }

    /// 应用到编辑态配置
    func apply(to config: IslandConfig) {
        config.presetID = id
        config.presetName = name
        config.expandedWidth = expandedWidth
        config.expandedHeight = expandedHeight
        config.expandedCornerRadius = expandedCornerRadius
        config.expandedBackgroundOpacity = expandedBackgroundOpacity
        config.capsuleLeadingText = capsuleLeadingText
        config.capsuleTrailingText = capsuleTrailingText
        config.capsuleIcon = capsuleIcon
        config.capsuleVisualWidth = capsuleVisualWidth
        config.capsuleCornerRadius = capsuleCornerRadius
        config.accentHex = accentHex
        config.darkMode = darkMode
        config.autoRefresh = autoRefresh
        config.items = items
        config.template = template
    }

    // 健壮 Codable：旧预设缺 template 字段时使用默认值
    private enum CodingKeys: String, CodingKey {
        case id, name, expandedWidth, expandedHeight, expandedCornerRadius, expandedBackgroundOpacity
        case capsuleLeadingText, capsuleTrailingText, capsuleIcon, capsuleVisualWidth, capsuleCornerRadius
        case accentHex, darkMode, autoRefresh, items, template
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? "默认模板"
        expandedWidth = try c.decodeIfPresent(Double.self, forKey: .expandedWidth) ?? 371
        expandedHeight = try c.decodeIfPresent(Double.self, forKey: .expandedHeight) ?? 160
        expandedCornerRadius = try c.decodeIfPresent(Double.self, forKey: .expandedCornerRadius) ?? 44
        expandedBackgroundOpacity = try c.decodeIfPresent(Double.self, forKey: .expandedBackgroundOpacity) ?? 0.95
        capsuleLeadingText = try c.decodeIfPresent(String.self, forKey: .capsuleLeadingText) ?? "BetLand"
        capsuleTrailingText = try c.decodeIfPresent(String.self, forKey: .capsuleTrailingText) ?? "12:30"
        capsuleIcon = try c.decodeIfPresent(String.self, forKey: .capsuleIcon) ?? "sparkles"
        capsuleVisualWidth = try c.decodeIfPresent(Double.self, forKey: .capsuleVisualWidth) ?? 1.0
        capsuleCornerRadius = try c.decodeIfPresent(Double.self, forKey: .capsuleCornerRadius) ?? 20
        accentHex = try c.decodeIfPresent(String.self, forKey: .accentHex) ?? "#0A84FF"
        darkMode = try c.decodeIfPresent(Bool.self, forKey: .darkMode) ?? true
        autoRefresh = try c.decodeIfPresent(Bool.self, forKey: .autoRefresh) ?? true
        items = try c.decodeIfPresent([IslandItem].self, forKey: .items) ?? []
        template = try c.decodeIfPresent(IslandTemplateConfig.self, forKey: .template) ?? IslandTemplateConfig()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(expandedWidth, forKey: .expandedWidth)
        try c.encode(expandedHeight, forKey: .expandedHeight)
        try c.encode(expandedCornerRadius, forKey: .expandedCornerRadius)
        try c.encode(expandedBackgroundOpacity, forKey: .expandedBackgroundOpacity)
        try c.encode(capsuleLeadingText, forKey: .capsuleLeadingText)
        try c.encode(capsuleTrailingText, forKey: .capsuleTrailingText)
        try c.encode(capsuleIcon, forKey: .capsuleIcon)
        try c.encode(capsuleVisualWidth, forKey: .capsuleVisualWidth)
        try c.encode(capsuleCornerRadius, forKey: .capsuleCornerRadius)
        try c.encode(accentHex, forKey: .accentHex)
        try c.encode(darkMode, forKey: .darkMode)
        try c.encode(autoRefresh, forKey: .autoRefresh)
        try c.encode(items, forKey: .items)
        try c.encode(template, forKey: .template)
    }

    static func sample(name: String = "默认模板") -> IslandLayout {
        IslandLayout(
            id: UUID(),
            name: name,
            expandedWidth: 371,
            expandedHeight: 160,
            expandedCornerRadius: 44,
            expandedBackgroundOpacity: 0.95,
            capsuleLeadingText: "BetLand",
            capsuleTrailingText: "12:30",
            capsuleIcon: "sparkles",
            capsuleVisualWidth: 1.0,
            capsuleCornerRadius: 20,
            accentHex: "#0A84FF",
            darkMode: true,
            autoRefresh: true,
            items: IslandItem.sample()
        )
    }
}

// MARK: - 布局 JSON 编解码（预设持久化用）

enum IslandStore {

    static func encode(_ layout: IslandLayout) -> String {
        guard let data = try? JSONEncoder().encode(layout) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func decode(_ json: String) -> IslandLayout? {
        guard !json.isEmpty, let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(IslandLayout.self, from: data)
    }
}
