import Foundation
import SwiftData

// MARK: - 布局预设（SwiftData 持久化；布局本体存 JSON，编辑器与 Widget 共用解码）

@Model
final class LayoutPreset {
    @Attribute(.unique) var id: UUID
    var name: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    var layoutJSON: String

    init(name: String, layout: IslandLayout, isActive: Bool = false) {
        self.id = layout.id
        self.name = name
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
        self.layoutJSON = IslandStore.encode(layout)
    }

    func decodeLayout() -> IslandLayout? {
        IslandStore.decode(layoutJSON)
    }
}
