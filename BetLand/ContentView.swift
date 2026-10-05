import SwiftUI

// MARK: - 根视图：Liquid Glass 全局容器

struct ContentView: View {
    var body: some View {
        GlassEffectContainer {
            TabView {
                HomeView()
                    .tabItem { Label("動態島", systemImage: "sparkles") }
                SettingsView()
                    .tabItem { Label("设置", systemImage: "gearshape") }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(IslandConfig())
}
