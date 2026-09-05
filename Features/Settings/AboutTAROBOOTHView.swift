import SwiftUI

struct AboutTAROBOOTHView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: TAROSpacing.lg) {
                Spacer()
                
                Image(systemName: TAROIcons.camera)
                    .font(.system(size: 64))
                    .foregroundColor(TAROColors.primaryPink)
                
                Text("TAROBOOTH")
                    .font(TAROTypography.brandTitle)
                    .foregroundColor(TAROColors.text)
                
                Text("Capture your little moments.")
                    .font(TAROTypography.subtitle)
                    .foregroundColor(TAROColors.text.opacity(0.6))
                
                Text("Version 1.0.0")
                    .font(TAROTypography.caption)
                    .foregroundColor(TAROColors.gray)
                    .padding(.top, TAROSpacing.sm)
                
                Spacer()
                
                TAROCard {
                    VStack(spacing: TAROSpacing.md) {
                        Text("Developed by")
                            .font(TAROTypography.caption)
                            .foregroundColor(TAROColors.gray)
                        
                        Text("Lê Minh Trang\nDương Văn Vương\nNguyễn Quốc Thanh")
                            .font(TAROTypography.body)
                            .foregroundColor(TAROColors.text)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(TAROSpacing.lg)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, TAROSpacing.lg)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("TAROBOOTH Team")
                        .font(TAROTypography.caption)
                    Text("Made with ♡")
                        .font(TAROTypography.caption)
                    Text("Swift + SwiftUI")
                        .font(TAROTypography.caption)
                    Text("© 2026 TAROBOOTH")
                        .font(TAROTypography.caption)
                }
                .foregroundColor(TAROColors.gray)
                .padding(.bottom, TAROSpacing.xl)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AboutTAROBOOTHView(navigationPath: .constant(NavigationPath()))
}
