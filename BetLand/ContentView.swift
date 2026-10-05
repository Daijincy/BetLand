import SwiftUI

// MARK: - 根视图：Liquid Glass 全局容器

struct ContentView: View {
    var body: some View {
        GlassEffectContainer {
            TabView {
                HomeView()
                    .tabItem { Label("動態島", systemImage: "sparkles") }
                NavigationStack {
                    EditorView()
                }
                .tabItem { Label("编辑器", systemImage: "slider.horizontal.3") }
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
