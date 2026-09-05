import SwiftUI

public struct TAROSecondaryButton: View {
    public let title: String
    public let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(TAROTypography.button)
                .foregroundColor(TAROColors.strongPink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, TAROSpacing.md)
                .background(TAROColors.white)
                .cornerRadius(TARORadius.pill)
                .overlay(
                    RoundedRectangle(cornerRadius: TARORadius.pill)
                        .stroke(TAROColors.strongPink, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TAROSecondaryButton(title: "Choose from Library", action: {})
        .padding()
}
