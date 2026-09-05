import SwiftUI

public struct TAROChip: View {
    public let title: String
    public let isSelected: Bool
    public let action: () -> Void
    
    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(TAROTypography.subtitle)
                .foregroundColor(isSelected ? TAROColors.white : TAROColors.text)
                .padding(.horizontal, TAROSpacing.md)
                .padding(.vertical, TAROSpacing.sm)
                .background(isSelected ? TAROColors.strongPink : TAROColors.white)
                .cornerRadius(TARORadius.pill)
                .overlay(
                    RoundedRectangle(cornerRadius: TARORadius.pill)
                        .stroke(isSelected ? TAROColors.strongPink : TAROColors.gray, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    HStack {
        TAROChip(title: "All", isSelected: true, action: {})
        TAROChip(title: "Classic", isSelected: false, action: {})
    }
    .padding()
}
