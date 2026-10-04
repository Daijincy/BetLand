import SwiftUI

@main
struct BetLandApp: App {
    @State private var config = IslandConfig()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(config)
                .preferredColorScheme(config.darkMode ? .dark : .light)
        }
    }
}
