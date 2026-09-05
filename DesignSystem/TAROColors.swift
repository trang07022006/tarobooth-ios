import SwiftUI

public enum TAROColors {
    /// Background (Warm Cream)
    public static let background = Color(hex: "FDFBF7")
    
    /// Surface (Off-white / White)
    public static let white = Color(hex: "FFFFFF")
    public static let cream = Color(hex: "F5F2EB")
    
    /// Text Primary (Charcoal)
    public static let text = Color(hex: "2B2528")
    
    /// Accent (Deep Red)
    public static let primaryPink = Color(hex: "C93A40")
    public static let strongPink = Color(hex: "A32D33") // Darker deep red for states
    
    /// Secondary Accent (Soft Blush Pink)
    public static let softBlush = Color(hex: "FFD8E5")
    
    /// Dark / Camera Background (Near Black)
    public static let cameraBackground = Color(hex: "1A1819")
    
    /// Gray (Placeholder text, borders)
    public static let gray = Color.gray.opacity(0.4)
}

// Extension to support Hex colors easily
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
