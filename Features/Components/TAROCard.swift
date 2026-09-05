import SwiftUI

public struct TAROCard<Content: View>: View {
    public let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .background(TAROColors.white)
            .cornerRadius(TARORadius.lg)
            .applyTAROShadow(.soft)
    }
}

#Preview {
    TAROCard {
        VStack {
            Text("Sample Card")
                .font(TAROTypography.heading2)
            Text("This is some content inside.")
                .font(TAROTypography.body)
        }
        .padding(TAROSpacing.lg)
    }
    .padding()
}
