import SwiftUI

public struct TAROSectionHeader: View {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
    
    public var body: some View {
        HStack {
            Text(title)
                .font(TAROTypography.heading2)
                .foregroundColor(TAROColors.text)
            Spacer()
        }
        .padding(.vertical, TAROSpacing.sm)
    }
}

#Preview {
    TAROSectionHeader(title: "My Gallery")
        .padding()
}
