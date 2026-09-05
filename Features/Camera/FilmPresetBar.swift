import SwiftUI

public struct FilmPresetCarousel: View {
    @Binding var selectedPreset: FilmPreset
    
    public init(selectedPreset: Binding<FilmPreset>) {
        self._selectedPreset = selectedPreset
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TAROSpacing.md) {
                ForEach(MockData.filmPresets) { preset in
                    FilmPresetThumbnail(
                        preset: preset,
                        isSelected: selectedPreset.id == preset.id
                    ) {
                        selectedPreset = preset
                    }
                }
            }
            .padding(.horizontal, TAROSpacing.lg)
            .padding(.vertical, TAROSpacing.xs)
        }
    }
}

public struct FilmPresetThumbnail: View {
    public let preset: FilmPreset
    public let isSelected: Bool
    public let action: () -> Void
    
    public init(preset: FilmPreset, isSelected: Bool, action: @escaping () -> Void) {
        self.preset = preset
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: TAROSpacing.xs) {
                // Visual swatch preview
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(swatchGradient(for: preset.id))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? TAROColors.strongPink : Color.white.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                        )
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
                    
                    // Selected accent indicator dot
                    if isSelected {
                        Circle()
                            .fill(TAROColors.strongPink)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1.5)
                            )
                            .offset(x: 2, y: -2)
                    }
                }
                
                // Name
                Text(preset.displayName)
                    .font(TAROTypography.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : Color.white.opacity(0.65))
            }
            .frame(width: 58)
        }
        .buttonStyle(.plain)
    }
    
    private func swatchGradient(for id: String) -> LinearGradient {
        switch id.lowercased() {
        case "cream":
            return LinearGradient(colors: [Color(hex: "FFF8F0"), Color(hex: "F2E6D8")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "warm":
            return LinearGradient(colors: [Color(hex: "FFDFC4"), Color(hex: "F4A261")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "vintage":
            return LinearGradient(colors: [Color(hex: "DDB892"), Color(hex: "7F5539")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "retro":
            return LinearGradient(colors: [Color(hex: "E76F51"), Color(hex: "E9C46A")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "disposable":
            return LinearGradient(colors: [Color(hex: "2A9D8F"), Color(hex: "E76F51")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "mono":
            return LinearGradient(colors: [Color(hex: "2B2528"), Color(hex: "888888")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "cool":
            return LinearGradient(colors: [Color(hex: "C5E3F6"), Color(hex: "457B9D")], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            // "original"
            return LinearGradient(colors: [Color(hex: "E5E5E5"), Color(hex: "A3A3A3")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// Typealias for backward compatibility
public typealias FilmPresetBar = FilmPresetCarousel

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FilmPresetCarousel(selectedPreset: .constant(MockData.filmPresets[0]))
    }
}
