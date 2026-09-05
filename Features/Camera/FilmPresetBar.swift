import SwiftUI

struct FilmPresetBar: View {
    @State private var selectedPresetId: String = "1"
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TAROSpacing.md) {
                ForEach(MockData.filmPresets) { preset in
                    FilmPresetThumbnail(
                        preset: preset,
                        isSelected: selectedPresetId == preset.id
                    ) {
                        selectedPresetId = preset.id
                    }
                }
            }
            .padding(.horizontal, TAROSpacing.md)
            .padding(.vertical, TAROSpacing.sm)
        }
    }
}

struct FilmPresetThumbnail: View {
    let preset: FilmPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: TAROSpacing.xs) {
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? TAROColors.strongPink : Color.clear, lineWidth: 3)
                    )
                
                Text(preset.name)
                    .font(TAROTypography.caption)
                    .foregroundColor(isSelected ? TAROColors.strongPink : .white)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FilmPresetBar()
    }
}
