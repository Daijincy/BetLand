import ActivityKit
import Foundation

// MARK: - 实时活动属性（App 与 Widget 共享）
// templateJSON 带默认值与 decodeIfPresent：旧活动（无该字段）升级后仍可正常渲染

struct BetLandAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String = "BetLand"
        var subtitle: String = "12:30"
        var progress: Double = 0.0
        var accentHex: String = "#0A84FF"
        var templateJSON: String = ""
        var capsuleIcon: String = "sparkles"

        init() {}

        init(title: String, subtitle: String, progress: Double, accentHex: String, templateJSON: String = "", capsuleIcon: String = "sparkles") {
            self.title = title
            self.subtitle = subtitle
            self.progress = progress
            self.accentHex = accentHex
            self.templateJSON = templateJSON
            self.capsuleIcon = capsuleIcon
        }

        private enum CodingKeys: String, CodingKey {
            case title, subtitle, progress, accentHex, templateJSON, capsuleIcon
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            title = try c.decodeIfPresent(String.self, forKey: .title) ?? "BetLand"
            subtitle = try c.decodeIfPresent(String.self, forKey: .subtitle) ?? "12:30"
            progress = try c.decodeIfPresent(Double.self, forKey: .progress) ?? 0.0
            accentHex = try c.decodeIfPresent(String.self, forKey: .accentHex) ?? "#0A84FF"
            templateJSON = try c.decodeIfPresent(String.self, forKey: .templateJSON) ?? ""
            capsuleIcon = try c.decodeIfPresent(String.self, forKey: .capsuleIcon) ?? "sparkles"
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(title, forKey: .title)
            try c.encode(subtitle, forKey: .subtitle)
            try c.encode(progress, forKey: .progress)
            try c.encode(accentHex, forKey: .accentHex)
            try c.encode(templateJSON, forKey: .templateJSON)
            try c.encode(capsuleIcon, forKey: .capsuleIcon)
        }
    }

    var name: String = "BetLand"
}
