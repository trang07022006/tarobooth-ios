import SwiftUI

struct LoadingView: View {
    var title: String = "Loading..."
    
    var body: some View {
        VStack(spacing: TAROSpacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: TAROColors.primaryPink))
                .scaleEffect(1.5)
            
            Text(title)
                .font(TAROTypography.subtitle)
                .foregroundColor(TAROColors.text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TAROColors.background)
    }
}

#Preview {
    LoadingView()
}
