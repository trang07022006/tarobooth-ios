import SwiftUI

public enum TAROFrameStyle: String, Hashable {
    case standard
    case polaroid
    case film
}

public struct TAROFrameItem: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let style: TAROFrameStyle
    public let frameColor: Color
    public let borderWidth: CGFloat
    
    public init(id: String, name: String, style: TAROFrameStyle, frameColor: Color, borderWidth: CGFloat = 0) {
        self.id = id
        self.name = name
        self.style = style
        self.frameColor = frameColor
        self.borderWidth = borderWidth
    }
}

public enum TAROFrameCatalog {
    public static let frames: [TAROFrameItem] = [
        TAROFrameItem(id: "none", name: "None", style: .standard, frameColor: Color.clear, borderWidth: 0),
        TAROFrameItem(id: "cream", name: "Cream", style: .standard, frameColor: TAROColors.cream, borderWidth: 2),
        TAROFrameItem(id: "white", name: "White", style: .standard, frameColor: Color.white, borderWidth: 2),
        TAROFrameItem(id: "pink", name: "Pink", style: .standard, frameColor: TAROColors.softBlush, borderWidth: 2),
        TAROFrameItem(id: "black", name: "Black", style: .standard, frameColor: Color(hex: "181617"), borderWidth: 2),
        TAROFrameItem(id: "polaroid", name: "Polaroid", style: .polaroid, frameColor: Color.white, borderWidth: 3),
        TAROFrameItem(id: "film", name: "Film", style: .film, frameColor: Color(hex: "181617"), borderWidth: 2)
    ]
    
    public static func item(for id: String?) -> TAROFrameItem {
        guard let id = id?.lowercased() else { return frames[1] } // default Cream
        return frames.first { $0.id.lowercased() == id } ?? frames[1]
    }
}
