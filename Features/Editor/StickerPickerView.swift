import SwiftUI

struct StickerPickerView: View {
    let stickers = [TAROIcons.heart, TAROIcons.sparkles, TAROIcons.flower, "star.fill", "moon.fill", "camera.fill", "rosette"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TAROSpacing.lg) {
                ForEach(stickers, id: \.self) { sticker in
                    Button(action: {
                        // Add sticker to canvas
                    }) {
                        Image(systemName: sticker)
                            .font(.system(size: 32))
                            .foregroundColor(TAROColors.strongPink)
                            .frame(width: 60, height: 60)
                            .background(TAROColors.softBlush.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TAROSpacing.md)
        }
    }
}

#Preview {
    StickerPickerView()
}
