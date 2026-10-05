import ActivityKit
import Foundation

// MARK: - 实时活动属性（App 与 Widget 共享）

struct BetLandAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String = "BetLand"
        var subtitle: String = "12:30"
        var progress: Double = 0.0
        var accentHex: String = "#0A84FF"
    }

    var name: String = "BetLand"
}
