import Foundation
import Observation
import SwiftUI

// MARK: - 全局配置（@Observable，注入 Environment；App 与 Widget 共享定义）

@Observable
final class IslandConfig {

    // 预设标识（SwiftData LayoutPreset 关联）
    var presetID: UUID = UUID()
    var presetName: String = "默认模板"

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

    // 展开面板模板（iScreen 式预设）
    var template: IslandTemplateConfig = IslandTemplateConfig()

    // 快捷方法：16 进制 -> Color
    func accentColor() -> Color {
        Color(hex: accentHex)
    }
}
