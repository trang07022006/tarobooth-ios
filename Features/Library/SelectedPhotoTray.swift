import SwiftUI

struct SelectedPhotoTray: View {
    let selectedCount: Int
    let requiredCount: Int
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: TAROSpacing.md) {
            HStack(spacing: TAROSpacing.sm) {
                ForEach(0..<requiredCount, id: \.self) { index in
                    Rectangle()
                        .fill(index < selectedCount ? TAROColors.primaryPink.opacity(0.8) : TAROColors.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(TARORadius.sm)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, TAROSpacing.lg)
            
            TAROPrimaryButton(title: "Continue") {
                onContinue()
            }
            .opacity(selectedCount == requiredCount ? 1.0 : 0.5)
            .disabled(selectedCount != requiredCount)
            .padding(.horizontal, TAROSpacing.lg)
        }
        .padding(.vertical, TAROSpacing.md)
        .background(TAROColors.white)
        .applyTAROShadow(.medium)
    }
}

#Preview {
    SelectedPhotoTray(selectedCount: 2, requiredCount: 4, onContinue: {})
        .background(TAROColors.background)
}
