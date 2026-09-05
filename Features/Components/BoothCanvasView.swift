import SwiftUI

public struct BoothCanvasView: View {
    let templateName: String
    let frameColor: Color
    
    // Config
    let cornerRadius: CGFloat = 8
    
    public init(templateName: String, frameColor: Color) {
        self.templateName = templateName
        self.frameColor = frameColor
    }
    
    public var body: some View {
        VStack(spacing: TAROSpacing.sm) {
            // Mock Grid Based on Template
            if templateName == "4 Cut" {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TAROSpacing.sm) {
                    ForEach(0..<4) { _ in
                        Rectangle()
                            .fill(TAROColors.cameraBackground.opacity(0.8))
                            .aspectRatio(3/4, contentMode: .fit)
                            .cornerRadius(cornerRadius)
                    }
                }
            } else if templateName == "3 Cut" {
                VStack(spacing: TAROSpacing.sm) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(TAROColors.cameraBackground.opacity(0.8))
                            .aspectRatio(4/3, contentMode: .fit)
                            .cornerRadius(cornerRadius)
                    }
                }
            } else if templateName == "Film Strip" {
                VStack(spacing: TAROSpacing.sm) {
                    ForEach(0..<4) { _ in
                        Rectangle()
                            .fill(TAROColors.cameraBackground.opacity(0.8))
                            .aspectRatio(3/2, contentMode: .fit)
                            .cornerRadius(cornerRadius)
                    }
                }
            } else {
                // Default 2x2
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TAROSpacing.sm) {
                    ForEach(0..<4) { _ in
                        Rectangle()
                            .fill(TAROColors.cameraBackground.opacity(0.8))
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(cornerRadius)
                    }
                }
            }
            
            // Branding Footer
            HStack {
                Text("TAROBOOTH")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(frameColor == .black ? .white : TAROColors.text)
                Spacer()
                Text("2026.09.05")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(frameColor == .black ? .white.opacity(0.8) : TAROColors.text.opacity(0.6))
            }
            .padding(.top, TAROSpacing.xs)
            .padding(.horizontal, TAROSpacing.xs)
        }
        .padding(TAROSpacing.md)
        .background(frameColor)
        .cornerRadius(TARORadius.lg)
        .applyTAROShadow(.medium)
    }
}

#Preview {
    ZStack {
        TAROColors.background.ignoresSafeArea()
        BoothCanvasView(templateName: "4 Cut", frameColor: TAROColors.softBlush)
            .padding(40)
    }
}
