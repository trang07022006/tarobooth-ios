import SwiftUI

struct FramePickerView: View {
    let frames = MockData.frames
    @State private var selectedFrame = "Cream"
    @Binding var selectedColor: Color
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TAROSpacing.md) {
                ForEach(frames, id: \.self) { frame in
                    VStack(spacing: TAROSpacing.xs) {
                        Rectangle()
                            .fill(colorForFrame(frame))
                            .frame(width: 50, height: 70)
                            .overlay(
                                Rectangle()
                                    .stroke(selectedFrame == frame ? TAROColors.primaryPink : TAROColors.gray, lineWidth: selectedFrame == frame ? 3 : 1)
                            )
                        
                        Text(frame)
                            .font(TAROTypography.caption)
                            .foregroundColor(selectedFrame == frame ? TAROColors.primaryPink : TAROColors.text)
                    }
                    .onTapGesture {
                        selectedFrame = frame
                        selectedColor = colorForFrame(frame)
                    }
                }
            }
            .padding(.horizontal, TAROSpacing.md)
        }
        .onAppear {
            selectedColor = colorForFrame(selectedFrame)
        }
    }
    
    func colorForFrame(_ name: String) -> Color {
        switch name {
        case "Cream": return TAROColors.cream
        case "White": return TAROColors.white
        case "Black": return Color.black
        case "Pink": return TAROColors.softBlush
        default: return TAROColors.gray.opacity(0.3)
        }
    }
}

#Preview {
    FramePickerView(selectedColor: .constant(.white))
}
