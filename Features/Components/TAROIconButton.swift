import SwiftUI

public struct TAROIconButton: View {
    public let icon: String
    public let action: () -> Void
    public var size: CGFloat = 24
    public var color: Color = TAROColors.text
    
    public init(icon: String, size: CGFloat = 24, color: Color = TAROColors.text, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(color)
                .padding(TAROSpacing.sm)
                .background(Circle().fill(TAROColors.white).opacity(0.8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TAROIconButton(icon: TAROIcons.camera, action: {})
        .padding()
        .background(Color.gray)
}
