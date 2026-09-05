import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: TAROSpacing.md) {
                Spacer()
                
                Text("TAROBOOTH")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(TAROColors.text)
                
                Text("Capture your little moments.")
                    .font(TAROTypography.subtitle)
                    .foregroundColor(TAROColors.text.opacity(0.8))
                
                Image(systemName: TAROIcons.heart)
                    .font(.title2)
                    .foregroundColor(TAROColors.primaryPink)
                    .padding(.top, TAROSpacing.lg)
                
                Spacer()
            }
        }
    }
}

#Preview {
    SplashView()
}
