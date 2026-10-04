import Foundation
import Observation
import SwiftUI

// MARK: - 灵动岛组件类型

enum IslandItemType: String, Codable, CaseIterable, Identifiable {
    case text = "文字"
    case icon = "图标"
    case progress = "进度条"
    case timer = "计时器"
    case image = "图片"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .text: "textformat"
        case .icon: "star.fill"
        case .progress: "chart.bar.fill"
        case .timer: "timer"
        case .image: "photo.fill"
        }
    }
}

// MARK: - 单个可摆放组件

struct IslandItem: Identifiable, Codable, Hashable {
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

    static func sample() -> [IslandItem] {
        [
            IslandItem(type: .icon, x: -60, y: 0, icon: "sparkles", tintHex: "#FFD60A"),
            IslandItem(type: .text, x: 0, y: 0, text: "BetLand 实时活动"),
            IslandItem(type: .progress, x: 0, y: 34, progress: 0.6, tintHex: "#0A84FF")
        ]
    }
}

// MARK: - 全局配置（@Observable，注入 Environment）

@Observable
final class IslandConfig {

    // 展开面板（系统上限内可调；真机宽度由系统决定，预览为模拟）
    var expandedWidth: Double = 371      // 预览画布宽度
    var expandedHeight: Double = 160      // 官方最大 160pt
    var expandedCornerRadius: Double = 44
    var expandedBackgroundOpacity: Double = 0.95

    // 胶囊（视觉调节，物理容器由系统锁定）
    var capsuleLeadingText: String = "BetLand"
    var capsuleTrailingText: String = "12:30"
    var capsuleIcon: String = "sparkles"
    var capsuleVisualWidth: Double = 1.0  // 视觉宽度倍数 0.6 ~ 2.0（背景模拟）
    var capsuleCornerRadius: Double = 20

    // 配色
    var accentHex: String = "#0A84FF"
    var darkMode: Bool = true

    // 实时活动
    var autoRefresh: Bool = true          // 前台高频刷新
    var frequentUpdates: Bool = true      // NSSupportsLiveActivitiesFrequentUpdates
    var pushEnabled: Bool = true          // APNs 离线更新（自用需自建推送服务）

    // 编辑器画布上的组件
    var items: [IslandItem] = IslandItem.sample()

    // 快捷方法：16 进制 -> Color
    func accentColor() -> Color {
        Color(hex: accentHex)
    }
}
