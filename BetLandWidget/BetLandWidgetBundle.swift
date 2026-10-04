import WidgetKit
import SwiftUI

// MARK: - Widget Bundle 入口

@main
struct BetLandWidgetBundle: WidgetBundle {
    var body: some Widget {
        // 普通桌面小组件：保证 extension 被系统完整注册（Live Activity 渲染的前提）
        BetLandHomeWidget()
        // 灵动岛 / 锁屏实时活动
        BetLandLiveActivity()
    }
}
