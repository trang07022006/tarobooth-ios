import SwiftUI

struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: TAROSpacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(TAROColors.primaryPink)
            
            Text(message)
                .font(TAROTypography.body)
                .foregroundColor(TAROColors.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TAROSpacing.xl)
            
            TAROSecondaryButton(title: "Retry", action: retryAction)
                .padding(.horizontal, TAROSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TAROColors.background)
    }
}

#Preview {
    ErrorStateView(message: "Failed to load photos. Please try again.") {}
}
