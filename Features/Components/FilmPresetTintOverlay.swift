import SwiftUI

/// Shared lightweight SwiftUI film preview effect for live camera and review thumbnails.
/// Applies comprehensive styling (saturation, brightness, contrast, grayscale, and overlay) based on stable FilmPreset.id.
/// Preserves the Original Photo Principle — no pixels or raw images are modified.
public struct FilmPresetPreviewModifier: ViewModifier {
    public let presetID: String?
    
    public init(presetID: String?) {
        self.presetID = presetID
    }
    
    public func body(content: Content) -> some View {
        let id = (presetID ?? "original").lowercased()
        
        content
            .grayscale(grayscaleValue(for: id))
            .saturation(saturationValue(for: id))
            .contrast(contrastValue(for: id))
            .brightness(brightnessValue(for: id))
            .overlay(
                tintOverlay(for: id)
            )
    }
    
    private func grayscaleValue(for id: String) -> Double {
        return id == "mono" ? 1.0 : 0.0
    }
    
    private func saturationValue(for id: String) -> Double {
        switch id {
        case "mono": return 0.0
        case "warm": return 1.15
        case "retro": return 1.20
        case "disposable": return 1.25
        case "vintage": return 0.85
        case "cool": return 0.95
        default: return 1.0
        }
    }
    
    private func contrastValue(for id: String) -> Double {
        switch id {
        case "mono": return 1.25
        case "disposable": return 1.20
        case "retro": return 1.15
        case "vintage": return 1.10
        case "warm", "cool": return 1.05
        default: return 1.0
        }
    }
    
    private func brightnessValue(for id: String) -> Double {
        switch id {
        case "cream": return 0.02
        case "vintage": return -0.02
        case "disposable": return 0.02
        default: return 0.0
        }
    }
    
    @ViewBuilder
    private func tintOverlay(for id: String) -> some View {
        switch id {
        case "cream":
            Color(hex: "FFF8F0").opacity(0.18)
                .blendMode(.screen)
        case "warm":
            Color(hex: "FFAA55").opacity(0.16)
                .blendMode(.colorBurn)
        case "vintage":
            Color(hex: "C49A6C").opacity(0.22)
                .blendMode(.multiply)
        case "retro":
            Color(hex: "E8B878").opacity(0.18)
                .blendMode(.overlay)
        case "disposable":
            Color(hex: "2A9D8F").opacity(0.10)
                .blendMode(.hardLight)
        case "mono":
            Color.black.opacity(0.15)
                .blendMode(.multiply)
        case "cool":
            Color(hex: "66B2FF").opacity(0.15)
                .blendMode(.screen)
        default:
            Color.clear
        }
    }
}

public struct FilmPresetPreviewEffect: View {
    public let presetID: String?
    
    public init(presetID: String?) {
        self.presetID = presetID
    }
    
    public var body: some View {
        Color.clear
            .modifier(FilmPresetPreviewModifier(presetID: presetID))
    }
}

// Backward compatibility typealias and extensions
public typealias FilmPresetTintOverlay = FilmPresetPreviewEffect

public extension View {
    /// Comprehensive film preset effect modifying grayscale, saturation, contrast, brightness, and tint
    func applyFilmPresetEffect(_ presetID: String?) -> some View {
        self.modifier(FilmPresetPreviewModifier(presetID: presetID))
    }
    
    /// Backward-compatible overlay extension
    func applyFilmPresetOverlay(_ presetID: String?) -> some View {
        self.applyFilmPresetEffect(presetID)
    }
}

#Preview {
    ZStack {
        Color.gray
        Text("Sample Preview")
            .font(.title)
            .foregroundColor(.white)
    }
    .applyFilmPresetEffect("warm")
    .frame(width: 200, height: 250)
}
