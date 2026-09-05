import SwiftUI

public struct TAROBackgroundItem: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let color: Color
    
    public init(id: String, name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

public enum TAROBackgroundCatalog {
    public static let backgrounds: [TAROBackgroundItem] = [
        TAROBackgroundItem(id: "cream", name: "Cream", color: TAROColors.cream),
        TAROBackgroundItem(id: "white", name: "White", color: Color.white),
        TAROBackgroundItem(id: "blush", name: "Blush", color: TAROColors.softBlush),
        TAROBackgroundItem(id: "warmGray", name: "Warm Gray", color: Color(hex: "D8D4CD")),
        TAROBackgroundItem(id: "charcoal", name: "Charcoal", color: Color(hex: "2E2A2D")),
        TAROBackgroundItem(id: "black", name: "Black", color: Color(hex: "181617"))
    ]
    
    public static func color(for id: String?) -> Color {
        guard let id = id?.lowercased() else { return TAROColors.cream }
        return backgrounds.first { $0.id.lowercased() == id }?.color ?? TAROColors.cream
    }
}
