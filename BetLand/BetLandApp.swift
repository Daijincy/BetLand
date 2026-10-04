import SwiftUI
import SwiftData

@main
struct BetLandApp: App {
    @State private var config = IslandConfig()

    let container: ModelContainer = {
        do {
            return try ModelContainer(for: LayoutPreset.self)
        } catch {
            fatalError("ModelContainer 初始化失败: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(config)
                .modelContainer(container)
                .preferredColorScheme(config.darkMode ? .dark : .light)
        }
    }
}
