import SwiftUI

// MARK: - Sticker Item

public struct StickerItem: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let symbolName: String
    public let defaultTint: Color
    
    public init(id: String, name: String, symbolName: String, defaultTint: Color) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.defaultTint = defaultTint
    }
}

// MARK: - Sticker Catalog

public enum TAROStickerCatalog {
    public static let stickers: [StickerItem] = [
        StickerItem(id: "heart", name: "Heart", symbolName: "heart.fill", defaultTint: TAROColors.primaryPink),
        StickerItem(id: "star", name: "Star", symbolName: "star.fill", defaultTint: Color(hex: "F4A261")),
        StickerItem(id: "sparkles", name: "Sparkles", symbolName: "sparkles", defaultTint: Color(hex: "E9C46A")),
        StickerItem(id: "camera", name: "Camera", symbolName: "camera.fill", defaultTint: Color.white),
        StickerItem(id: "sun", name: "Sun", symbolName: "sun.max.fill", defaultTint: Color(hex: "F4A261")),
        StickerItem(id: "moon", name: "Moon", symbolName: "moon.stars.fill", defaultTint: Color(hex: "C5E3F6")),
        StickerItem(id: "smile", name: "Smile", symbolName: "face.smiling.fill", defaultTint: Color(hex: "E9C46A"))
    ]
    
    public static func symbol(for id: String) -> String {
        stickers.first { $0.id == id.lowercased() }?.symbolName ?? "star.fill"
    }
    
    public static func tint(for id: String) -> Color {
        stickers.first { $0.id == id.lowercased() }?.defaultTint ?? TAROColors.primaryPink
    }
}

// MARK: - StickerLayer Model

public struct StickerLayer: Identifiable, Hashable {
    public var id: String
    public var stickerID: String
    
    /// Normalized coordinates on canvas (0.0 ... 1.0, where 0.5, 0.5 is center)
    public var positionX: Double {
        didSet {
            positionX = min(max(0.05, positionX), 0.95)
        }
    }
    public var positionY: Double {
        didSet {
            positionY = min(max(0.05, positionY), 0.95)
        }
    }
    
    /// Scale factor (0.4 ... 3.0)
    public var scale: Double {
        didSet {
            scale = min(max(0.4, scale), 3.0)
        }
    }
    
    /// Rotation in degrees (0.0 ..< 360.0)
    public var rotationDegrees: Double {
        didSet {
            let normalized = rotationDegrees.truncatingRemainder(dividingBy: 360.0)
            rotationDegrees = normalized < 0 ? normalized + 360.0 : normalized
        }
    }
    
    public init(
        id: String = UUID().uuidString,
        stickerID: String,
        positionX: Double = 0.5,
        positionY: Double = 0.5,
        scale: Double = 1.0,
        rotationDegrees: Double = 0.0
    ) {
        self.id = id
        self.stickerID = stickerID
        self.positionX = min(max(0.05, positionX), 0.95)
        self.positionY = min(max(0.05, positionY), 0.95)
        self.scale = min(max(0.4, scale), 3.0)
        let normalized = rotationDegrees.truncatingRemainder(dividingBy: 360.0)
        self.rotationDegrees = normalized < 0 ? normalized + 360.0 : normalized
    }
}
