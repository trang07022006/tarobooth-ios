import SwiftUI

struct ResultView: View {
    @Binding var navigationPath: NavigationPath
    @State private var showSaveSuccess = false
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: TAROSpacing.md) {
                // Header
                HStack {
                    TAROIconButton(icon: TAROIcons.close) {
                        // Go back to Home
                        navigationPath = NavigationPath()
                    }
                    Spacer()
                }
                .padding()
                
                // Result Image Placeholder
                BoothCanvasView(templateName: "4 Cut", frameColor: TAROColors.cream)
                    .padding(.horizontal, TAROSpacing.xl)
                
                Text(showSaveSuccess ? "Saved to Photos!" : "All done! 🎉")
                    .font(TAROTypography.heading2)
                    .foregroundColor(showSaveSuccess ? TAROColors.primaryPink : TAROColors.text)
                    .padding(.top, TAROSpacing.lg)
                    .animation(.easeInOut, value: showSaveSuccess)
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: TAROSpacing.md) {
                    Button(action: {
                        withAnimation { showSaveSuccess = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { showSaveSuccess = false }
                        }
                    }) {
                        VStack(spacing: TAROSpacing.xs) {
                            Image(systemName: showSaveSuccess ? "checkmark.circle.fill" : TAROIcons.save)
                                .font(.system(size: 24))
                            Text(showSaveSuccess ? "Saved" : "Save")
                                .font(TAROTypography.caption)
                        }
                        .foregroundColor(showSaveSuccess ? TAROColors.white : TAROColors.primaryPink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TAROSpacing.sm)
                        .background(showSaveSuccess ? TAROColors.primaryPink : TAROColors.white)
                        .cornerRadius(TARORadius.lg)
                        .overlay(
                            RoundedRectangle(cornerRadius: TARORadius.lg)
                                .stroke(TAROColors.primaryPink, lineWidth: showSaveSuccess ? 0 : 1)
                        )
                    }
                    
                    Button(action: {}) {
                        VStack(spacing: TAROSpacing.xs) {
                            Image(systemName: TAROIcons.share)
                                .font(.system(size: 24))
                            Text("Share")
                                .font(TAROTypography.caption)
                        }
                        .foregroundColor(TAROColors.primaryPink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TAROSpacing.sm)
                        .background(TAROColors.white)
                        .cornerRadius(TARORadius.lg)
                        .overlay(
                            RoundedRectangle(cornerRadius: TARORadius.lg)
                                .stroke(TAROColors.primaryPink, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, TAROSpacing.lg)
                
                TAROPrimaryButton(title: "Create Another") {
                    navigationPath = NavigationPath()
                    // Alternatively, route to .templates directly:
                    // navigationPath = NavigationPath([AppRoute.templates])
                }
                .padding(.horizontal, TAROSpacing.lg)
                .padding(.bottom, TAROSpacing.xl)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ResultView(navigationPath: .constant(NavigationPath()))
}
