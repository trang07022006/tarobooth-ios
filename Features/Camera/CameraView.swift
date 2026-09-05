import SwiftUI

struct CameraView: View {
    @Binding var navigationPath: NavigationPath
    @State private var currentPhotoIndex = 1
    @State private var countdown = 0
    @State private var isCapturing = false
    let totalPhotos = 4
    
    var body: some View {
        ZStack {
            TAROColors.cameraBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    TAROIconButton(icon: TAROIcons.close, color: .white) {
                        navigationPath.removeLast()
                    }
                    Spacer()
                    ShotProgressView(current: currentPhotoIndex, total: totalPhotos)
                    Spacer()
                    TAROIconButton(icon: "bolt.slash.fill", color: .white) {
                        // Toggle flash
                    }
                }
                .padding()
                
                Spacer()
                
                // Camera Preview Placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(
                        CountdownOverlay(count: countdown, isCapturing: isCapturing)
                    )
                
                Spacer()
                
                // Presets & Controls
                VStack(spacing: TAROSpacing.md) {
                    FilmPresetBar()
                    
                    CameraControlsView(onCapture: startCaptureSequence)
                }
                .padding(.bottom, TAROSpacing.xl)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func startCaptureSequence() {
        guard countdown == 0 && !isCapturing else { return }
        
        countdown = 3
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                countdown = 0
                isCapturing = true
                
                // Flash effect
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isCapturing = false
                    
                    // Increment or finish
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if currentPhotoIndex < totalPhotos {
                            currentPhotoIndex += 1
                        } else {
                            navigationPath.append(AppRoute.review)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CameraView(navigationPath: .constant(NavigationPath()))
}
