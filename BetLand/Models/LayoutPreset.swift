import Foundation
import SwiftData

// MARK: - 完整配置快照（模板 + 胶囊 + 配色，随预设持久化）

struct ConfigSnapshot: Codable {
    var templateJSON: String = ""
    var capsuleLeadingText: String = "BetLand"
    var capsuleTrailingText: String = "12:30"
    var capsuleIcon: String = "sparkles"
    var capsuleVisualWidth: Double = 1.0
    var capsuleCornerRadius: Double = 20
    var accentHex: String = "#0A84FF"

    static func from(config: IslandConfig) -> ConfigSnapshot {
        ConfigSnapshot(
            templateJSON: config.template.kind == .none
                ? ""
                : IslandTemplateConfig.encode(config.template),
            capsuleLeadingText: config.capsuleLeadingText,
            capsuleTrailingText: config.capsuleTrailingText,
            capsuleIcon: config.capsuleIcon,
            capsuleVisualWidth: config.capsuleVisualWidth,
            capsuleCornerRadius: config.capsuleCornerRadius,
            accentHex: config.accentHex
        )
    }

    func apply(to config: IslandConfig) {
        if let t = IslandTemplateConfig.decode(templateJSON) {
            config.template = t
        }
        config.capsuleLeadingText = capsuleLeadingText
        config.capsuleTrailingText = capsuleTrailingText
        config.capsuleIcon = capsuleIcon
        config.capsuleVisualWidth = capsuleVisualWidth
        config.capsuleCornerRadius = capsuleCornerRadius
        config.accentHex = accentHex
    }

    static func encode(_ s: ConfigSnapshot) -> String {
        guard let data = try? JSONEncoder().encode(s) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func decode(_ json: String) -> ConfigSnapshot? {
        guard !json.isEmpty, let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ConfigSnapshot.self, from: data)
    }
}

// MARK: - 布局预设（SwiftData 持久化；布局本体存 JSON，编辑器与 Widget 共用解码）

@Model
final class LayoutPreset {
    @Attribute(.unique) var id: UUID
    var name: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    var layoutJSON: String
    var configJSON: String

    init(name: String, layout: IslandLayout, isActive: Bool = false, configJSON: String = "") {
        self.id = layout.id
        self.name = name
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
        self.layoutJSON = IslandStore.encode(layout)
        self.configJSON = configJSON
    }

    func decodeLayout() -> IslandLayout? {
        IslandStore.decode(layoutJSON)
    }

    func decodeConfig() -> ConfigSnapshot? {
        ConfigSnapshot.decode(configJSON)
    }
}
