import SwiftUI

struct CropPhotoView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            TAROColors.cameraBackground
                .ignoresSafeArea()
            
            VStack {
                // Top Bar
                HStack {
                    TAROIconButton(icon: TAROIcons.close, color: .white) {
                        navigationPath.removeLast()
                    }
                    Spacer()
                    Button("Done") {
                        navigationPath.append(AppRoute.review)
                    }
                    .font(TAROTypography.button)
                    .foregroundColor(TAROColors.primaryPink)
                }
                .padding()
                
                Spacer()
                
                // Crop Area Placeholder
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .padding()
                
                Spacer()
                
                // Action Buttons (Rotate, Fit, Fill, Reset)
                HStack(spacing: TAROSpacing.xl) {
                    VStack {
                        TAROIconButton(icon: TAROIcons.rotate, color: .white, action: {})
                        Text("Rotate").font(TAROTypography.caption).foregroundColor(.white)
                    }
                    VStack {
                        TAROIconButton(icon: "arrow.up.left.and.arrow.down.right", color: .white, action: {})
                        Text("Fit").font(TAROTypography.caption).foregroundColor(.white)
                    }
                    VStack {
                        TAROIconButton(icon: "arrow.up.backward.and.arrow.down.forward", color: .white, action: {})
                        Text("Fill").font(TAROTypography.caption).foregroundColor(.white)
                    }
                    VStack {
                        TAROIconButton(icon: "arrow.counterclockwise", color: .white, action: {})
                        Text("Reset").font(TAROTypography.caption).foregroundColor(.white)
                    }
                }
                .padding(.bottom, TAROSpacing.xl)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    CropPhotoView(navigationPath: .constant(NavigationPath()))
}
