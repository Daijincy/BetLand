import Foundation

// MARK: - 完整布局快照（App 编辑 → 序列化 → ContentState → Widget 渲染）

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
            items: config.items
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

// MARK: - 布局 JSON 编解码（ContentState 传递）

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
