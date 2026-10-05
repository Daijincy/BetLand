import ActivityKit
import Foundation

// MARK: - 实时活动即时同步（模板/布局改动 → 立即 update 到运行中的活动）

@MainActor
final class LiveActivitySync {
    static let shared = LiveActivitySync()

    private var activity: Activity<BetLandAttributes>?
    private var debounceTask: Task<Void, Never>?

    private init() {}

    /// 首页启动/结束后注册当前活动
    func register(_ activity: Activity<BetLandAttributes>?) {
        self.activity = activity
    }

    var isRunning: Bool { activity != nil }

    /// 立即应用（按钮触发）
    func applyNow(config: IslandConfig) {
        debounceTask?.cancel()
        guard let activity else { return }
        Task {
            await LiveActivityManager.update(activity, config: config)
        }
    }

    /// 防抖同步（参数连续编辑时 500ms 合并一次）
    func sync(config: IslandConfig) {
        debounceTask?.cancel()
        guard let activity else { return }
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard let self, !Task.isCancelled, let activity = self.activity else { return }
            await LiveActivityManager.update(activity, config: config)
        }
    }
}
