import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: TAROSpacing.xxl) {
                
                HStack {
                    Spacer()
                    TAROIconButton(icon: TAROIcons.settings, size: 22) {
                        navigationPath.append(AppRoute.settings)
                    }
                }
                .padding(.horizontal, TAROSpacing.md)
                
                Spacer()
                
                VStack(spacing: TAROSpacing.md) {
                    Text("TAROBOOTH")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(TAROColors.text)
                    
                    Text("Capture your little moments.")
                        .font(TAROTypography.heading2)
                        .foregroundColor(TAROColors.text.opacity(0.8))
                }
                
                Spacer()
                
                VStack(spacing: TAROSpacing.md) {
                    TAROPrimaryButton(title: "START PHOTOBOOTH") {
                        navigationPath.append(AppRoute.templates)
                    }
                    
                    TAROSecondaryButton(title: "Gallery") {
                        navigationPath.append(AppRoute.gallery)
                    }
                }
                .padding(.horizontal, TAROSpacing.lg)
                .padding(.bottom, TAROSpacing.xxxl)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    HomeView(navigationPath: .constant(NavigationPath()))
}
