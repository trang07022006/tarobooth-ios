import SwiftUI

// MARK: - Font Style

public enum TAROFontStyle: String, Hashable, CaseIterable {
    case system
    case rounded
    case serif
    case mono
    case handwritten
    case bold
    
    public var displayName: String {
        switch self {
        case .system: return "System"
        case .rounded: return "Rounded"
        case .serif: return "Serif"
        case .mono: return "Mono"
        case .handwritten: return "Handwritten"
        case .bold: return "Bold"
        }
    }
    
    public func font(baseSize: CGFloat = 20) -> Font {
        switch self {
        case .system:
            return .system(size: baseSize, weight: .regular, design: .default)
        case .rounded:
            return .system(size: baseSize, weight: .medium, design: .rounded)
        case .serif:
            return .system(size: baseSize, weight: .regular, design: .serif)
        case .mono:
            return .system(size: baseSize, weight: .medium, design: .monospaced)
        case .handwritten:
            // Stylized safe approximation using medium rounded italic
            return .system(size: baseSize, weight: .medium, design: .rounded).italic()
        case .bold:
            return .system(size: baseSize, weight: .bold, design: .default)
        }
    }
}

// MARK: - Text Alignment

public enum TAROTextAlignment: String, Hashable, CaseIterable {
    case left
    case center
    case right
    
    public var displayName: String {
        switch self {
        case .left: return "Left"
        case .center: return "Center"
        case .right: return "Right"
        }
    }
    
    public var textAlignment: TextAlignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }
    
    public var frameAlignment: Alignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }
}

// MARK: - Text Style

public enum TAROTextStyle: String, Hashable, CaseIterable {
    case normal
    case shadow
    case outline
    
    public var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .shadow: return "Shadow"
        case .outline: return "Outline"
        }
    }
}

// MARK: - Text Color Palette

public struct TAROTextColorItem: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let color: Color
    
    public init(id: String, name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

public enum TAROTextColorPalette {
    public static let palette: [TAROTextColorItem] = [
        TAROTextColorItem(id: "white", name: "White", color: Color.white),
        TAROTextColorItem(id: "black", name: "Black", color: Color(hex: "1A1819")),
        TAROTextColorItem(id: "cream", name: "Cream", color: TAROColors.cream),
        TAROTextColorItem(id: "pink", name: "Pink", color: TAROColors.softBlush),
        TAROTextColorItem(id: "red", name: "Red", color: TAROColors.strongPink),
        TAROTextColorItem(id: "brown", name: "Brown", color: Color(hex: "7F5539"))
    ]
    
    public static func color(for id: String) -> Color {
        palette.first { $0.id == id.lowercased() }?.color ?? Color.white
    }
}

// MARK: - TextLayer Model

public struct TextLayer: Identifiable, Hashable {
    public var id: String
    public var text: String
    public var fontStyle: TAROFontStyle
    public var colorID: String
    public var alignment: TAROTextAlignment
    
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
    
    /// Scale factor (0.5 ... 3.0)
    public var scale: Double {
        didSet {
            scale = min(max(0.5, scale), 3.0)
        }
    }
    
    /// Rotation in degrees (0.0 ..< 360.0)
    public var rotationDegrees: Double {
        didSet {
            let normalized = rotationDegrees.truncatingRemainder(dividingBy: 360.0)
            rotationDegrees = normalized < 0 ? normalized + 360.0 : normalized
        }
    }
    
    public var style: TAROTextStyle
    
    public init(
        id: String = UUID().uuidString,
        text: String,
        fontStyle: TAROFontStyle = .rounded,
        colorID: String = "white",
        alignment: TAROTextAlignment = .center,
        positionX: Double = 0.5,
        positionY: Double = 0.5,
        scale: Double = 1.0,
        rotationDegrees: Double = 0.0,
        style: TAROTextStyle = .normal
    ) {
        self.id = id
        self.text = text
        self.fontStyle = fontStyle
        self.colorID = colorID
        self.alignment = alignment
        self.positionX = min(max(0.05, positionX), 0.95)
        self.positionY = min(max(0.05, positionY), 0.95)
        self.scale = min(max(0.5, scale), 3.0)
        let normalized = rotationDegrees.truncatingRemainder(dividingBy: 360.0)
        self.rotationDegrees = normalized < 0 ? normalized + 360.0 : normalized
        self.style = style
    }
}
