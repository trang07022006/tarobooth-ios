import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: TAROSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(TAROColors.softBlush)
            
            VStack(spacing: TAROSpacing.sm) {
                Text(title)
                    .font(TAROTypography.heading2)
                    .foregroundColor(TAROColors.text)
                
                Text(message)
                    .font(TAROTypography.body)
                    .foregroundColor(TAROColors.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TAROSpacing.xl)
            }
            
            if let actionTitle = actionTitle, let action = action {
                TAROSecondaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, TAROSpacing.xl)
                    .padding(.top, TAROSpacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TAROColors.background)
    }
}

#Preview {
    EmptyStateView(
        icon: TAROIcons.photo,
        title: "No Photos Yet",
        message: "Your saved photobooth sessions will appear here.",
        actionTitle: "Start Photobooth",
        action: {}
    )
}
