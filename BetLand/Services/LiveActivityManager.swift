import ActivityKit
import Foundation

// MARK: - 实时活动管理（ActivityKit）

enum LiveActivityManager {

    /// 启动一个实时活动（自用环境使用 pushType: nil，无推送令牌依赖）
    /// 展开模板随 templateJSON 传递；kind 为默认时不携带（Widget 走默认渲染）
    static func start(config: IslandConfig) throws -> Activity<BetLandAttributes> {
        let attributes = BetLandAttributes(name: "BetLand")
        let state = BetLandAttributes.ContentState(
            title: config.capsuleLeadingText,
            subtitle: config.capsuleTrailingText,
            progress: 0.0,
            accentHex: config.accentHex,
            templateJSON: config.template.kind == .none
                ? ""
                : IslandTemplateConfig.encode(config.template)
        )
        let content = ActivityContent(state: state, staleDate: nil)
        return try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
    }

    /// 前台更新（App 存活时调用；布局/模板改动后刷新到已运行的活动）
    static func update(
        _ activity: Activity<BetLandAttributes>,
        config: IslandConfig,
        progress: Double = 0.0
    ) async {
        let state = BetLandAttributes.ContentState(
            title: config.capsuleLeadingText,
            subtitle: config.capsuleTrailingText,
            progress: progress,
            accentHex: config.accentHex,
            templateJSON: config.template.kind == .none
                ? ""
                : IslandTemplateConfig.encode(config.template)
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
