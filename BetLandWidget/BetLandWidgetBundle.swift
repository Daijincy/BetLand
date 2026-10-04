import WidgetKit
import SwiftUI

// MARK: - Widget Bundle 入口（仅承载实时活动）

@main
struct BetLandWidgetBundle: WidgetBundle {
    var body: some Widget {
        BetLandLiveActivity()
    }
}
