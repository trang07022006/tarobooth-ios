import SwiftUI

public struct TAROPrimaryButton: View {
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
                .foregroundColor(TAROColors.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, TAROSpacing.md)
                .background(TAROColors.strongPink)
                .cornerRadius(TARORadius.pill)
        }
        .buttonStyle(.plain)
        .applyTAROShadow(.soft)
    }
}

#Preview {
    TAROPrimaryButton(title: "START PHOTOBOOTH", action: {})
        .padding()
}
