import ActivityKit
import Foundation

// MARK: - 实时活动管理（ActivityKit）

enum LiveActivityManager {

    /// 启动一个实时活动（自用环境使用 pushType: nil，无推送令牌依赖）
    /// 布局快照随 ContentState 传递，Widget 据此渲染自定义内容
    static func start(config: IslandConfig) throws -> Activity<BetLandAttributes> {
        let layout = IslandLayout.from(config: config)
        let attributes = BetLandAttributes(name: "BetLand")
        let state = BetLandAttributes.ContentState(
            title: layout.capsuleLeadingText,
            subtitle: layout.capsuleTrailingText,
            progress: 0.0,
            accentHex: layout.accentHex,
            layoutJSON: IslandStore.encode(layout)
        )
        let content = ActivityContent(state: state, staleDate: nil)
        return try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
    }

    /// 前台更新（App 存活时调用；布局改动后刷新到已运行的活动）
    static func update(
        _ activity: Activity<BetLandAttributes>,
        config: IslandConfig,
        progress: Double = 0.0
    ) async {
        let layout = IslandLayout.from(config: config)
        let state = BetLandAttributes.ContentState(
            title: layout.capsuleLeadingText,
            subtitle: layout.capsuleTrailingText,
            progress: progress,
            accentHex: layout.accentHex,
            layoutJSON: IslandStore.encode(layout)
        )
        let content = ActivityContent(state: state, staleDate: nil)
        await activity.update(content)
    }

    /// 结束指定活动
    static func end(_ activity: Activity<BetLandAttributes>) async {
        await activity.end(nil, dismissalPolicy: .immediate)
    }

    /// 结束全部活动
    static func endAll() async {
        for activity in Activity<BetLandAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    /// 当前存活的全部活动
    static func allActivities() -> [Activity<BetLandAttributes>] {
        Activity<BetLandAttributes>.activities
    }
}
