import SwiftUI

struct PhotoReviewView: View {
    @Binding var navigationPath: NavigationPath
    let isFromCamera = true // Mock state
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: TAROSpacing.md) {
                Text("Review Photos")
                    .font(TAROTypography.heading1)
                    .foregroundColor(TAROColors.text)
                    .padding(.top, TAROSpacing.md)
                
                // 2x2 Grid Placeholder for 4 Cut
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TAROSpacing.sm) {
                    ForEach(0..<4) { index in
                        ReviewPhotoCell(isFromCamera: isFromCamera) {
                            // Retake or replace action
                            if !isFromCamera {
                                navigationPath.append(AppRoute.library)
                            } else {
                                navigationPath.append(AppRoute.camera)
                            }
                        }
                    }
                }
                .padding(TAROSpacing.md)
                
                Spacer()
                
                TAROPrimaryButton(title: "Continue") {
                    navigationPath.append(AppRoute.editor)
                }
                .padding(.horizontal, TAROSpacing.lg)
                .padding(.bottom, TAROSpacing.xl)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReviewPhotoCell: View {
    let isFromCamera: Bool
    let action: () -> Void
    
    var body: some View {
        Rectangle()
            .fill(TAROColors.gray.opacity(0.3))
            .aspectRatio(3/4, contentMode: .fit)
            .cornerRadius(TARORadius.md)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: action) {
                            Image(systemName: isFromCamera ? TAROIcons.retake : TAROIcons.replace)
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(8)
                    }
                }
            )
    }
}

#Preview {
    PhotoReviewView(navigationPath: .constant(NavigationPath()))
}
