import SwiftUI

struct CropPhotoView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var currentSession: BoothSession
    
    @State private var currentPhotoIndex = 0
    
    init(navigationPath: Binding<NavigationPath>, currentSession: Binding<BoothSession> = .constant(BoothSession())) {
        self._navigationPath = navigationPath
        self._currentSession = currentSession
    }
    
    private var totalPhotos: Int {
        currentSession.photos.count
    }
    
    private var currentPhoto: BoothPhoto? {
        guard currentPhotoIndex >= 0 && currentPhotoIndex < totalPhotos else { return nil }
        return currentSession.photos[currentPhotoIndex]
    }
    
    var body: some View {
        ZStack {
            TAROColors.cameraBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Bar
                topBar
                    .padding(.top, TAROSpacing.xs)
                    .padding(.horizontal, TAROSpacing.lg)
                
                // Photo Counter Indicator
                photoCounterBadge
                    .padding(.top, TAROSpacing.xs)
                
                Spacer(minLength: TAROSpacing.xs)
                
                // Large Interactive Crop Preview
                if let photo = currentPhoto {
                    cropPreview(for: photo)
                        .padding(.horizontal, TAROSpacing.lg)
                } else {
                    emptyFallbackView
                }
                
                Spacer(minLength: TAROSpacing.xs)
                
                // Photo Paging Controls (Previous / Next)
                if totalPhotos > 1 {
                    photoPagingBar
                        .padding(.horizontal, TAROSpacing.xl)
                        .padding(.vertical, TAROSpacing.xs)
                }
                
                // Adjustment Tool Buttons (Fit/Fill, Rotate, Flip, Reset)
                cropToolsBar
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.top, TAROSpacing.xs)
                
                // Bottom Primary CTA: REVIEW PHOTOS
                bottomCTA
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.vertical, TAROSpacing.md)
            }
            .frame(maxWidth: 650)
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button(action: {
                // Back returns to Arrange preserving crop state
                navigationPath.removeLast()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Adjust photo")
                    .font(TAROTypography.heading2)
                    .foregroundColor(.white)
                
                Text("Crop, rotate, and align your photo.")
                    .font(TAROTypography.caption)
                    .foregroundColor(Color.white.opacity(0.6))
            }
            
            Spacer()
            
            // Spacer balance for 44pt tap target
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
    
    // MARK: - Photo Counter Badge
    
    private var photoCounterBadge: some View {
        Text("Photo \(currentPhotoIndex + 1) of \(max(1, totalPhotos))")
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(TAROColors.softBlush)
            .padding(.horizontal, TAROSpacing.md)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.15))
            .cornerRadius(TARORadius.pill)
    }
    
    // MARK: - Crop Preview
    
    private func cropPreview(for photo: BoothPhoto) -> some View {
        ZStack {
            // Viewfinder Frame
            RoundedRectangle(cornerRadius: TARORadius.lg)
                .fill(Color(hex: "232022"))
                .aspectRatio(3/4, contentMode: .fit)
            
            // Photo Content with transformations applied
            TAROPhotoSurfaceView(photo: photo)
            
            // Grid Overlay Markings (rule of thirds crop guide)
            cropGridLines
        }
        .clipShape(RoundedRectangle(cornerRadius: TARORadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: TARORadius.lg)
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
        )
        .applyTAROShadow(.medium)
        .frame(maxHeight: 380)
    }
    
    // Rule-of-thirds grid lines
    private var cropGridLines: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height
                
                // Vertical lines
                path.move(to: CGPoint(x: w / 3, y: 0))
                path.addLine(to: CGPoint(x: w / 3, y: h))
                path.move(to: CGPoint(x: 2 * w / 3, y: 0))
                path.addLine(to: CGPoint(x: 2 * w / 3, y: h))
                
                // Horizontal lines
                path.move(to: CGPoint(x: 0, y: h / 3))
                path.addLine(to: CGPoint(x: w, y: h / 3))
                path.move(to: CGPoint(x: 0, y: 2 * h / 3))
                path.addLine(to: CGPoint(x: w, y: 2 * h / 3))
            }
            .stroke(Color.white.opacity(0.15), lineWidth: 1)
        }
    }
    
    // MARK: - Photo Paging Controls
    
    private var photoPagingBar: some View {
        HStack {
            Button(action: {
                if currentPhotoIndex > 0 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentPhotoIndex -= 1
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(TAROTypography.caption)
                .foregroundColor(currentPhotoIndex > 0 ? .white : Color.white.opacity(0.3))
                .padding(.horizontal, TAROSpacing.md)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(TARORadius.pill)
            }
            .buttonStyle(.plain)
            .disabled(currentPhotoIndex == 0)
            
            Spacer()
            
            Button(action: {
                if currentPhotoIndex < totalPhotos - 1 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentPhotoIndex += 1
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .font(TAROTypography.caption)
                .foregroundColor(currentPhotoIndex < totalPhotos - 1 ? .white : Color.white.opacity(0.3))
                .padding(.horizontal, TAROSpacing.md)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(TARORadius.pill)
            }
            .buttonStyle(.plain)
            .disabled(currentPhotoIndex >= totalPhotos - 1)
        }
    }
    
    // MARK: - Crop Tools Bar
    
    private var cropToolsBar: some View {
        HStack(spacing: TAROSpacing.lg) {
            // Fit / Fill Toggle
            toolButton(
                icon: currentPhoto?.cropState.mode == .fill ? "arrow.up.backward.and.arrow.down.forward" : "arrow.up.left.and.arrow.down.right",
                label: currentPhoto?.cropState.mode == .fill ? "Fill" : "Fit",
                isActive: currentPhoto?.cropState.mode == .fill
            ) {
                toggleFitFill()
            }
            
            // Rotate Button
            toolButton(
                icon: TAROIcons.rotate,
                label: "Rotate"
            ) {
                rotatePhoto()
            }
            
            // Flip Horizontal Button
            toolButton(
                icon: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill",
                label: "Flip",
                isActive: currentPhoto?.cropState.isHorizontallyFlipped == true
            ) {
                flipPhoto()
            }
            
            // Reset Button
            toolButton(
                icon: "arrow.counterclockwise",
                label: "Reset"
            ) {
                resetCrop()
            }
        }
        .padding(.vertical, TAROSpacing.xs)
    }
    
    private func toolButton(icon: String, label: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isActive ? TAROColors.strongPink : Color.white.opacity(0.15))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text(label)
                    .font(TAROTypography.caption)
                    .foregroundColor(isActive ? TAROColors.softBlush : Color.white.opacity(0.8))
            }
        }
        .buttonStyle(.plain)
        .frame(minWidth: 54)
    }
    
    // MARK: - Bottom Primary CTA
    
    private var bottomCTA: some View {
        Button(action: {
            currentSession.normalizePhotoOrder()
            navigationPath.append(AppRoute.review)
        }) {
            Text("REVIEW PHOTOS")
                .font(TAROTypography.button)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(TAROColors.strongPink)
                .cornerRadius(TARORadius.pill)
                .applyTAROShadow(.medium)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty Fallback
    
    private var emptyFallbackView: some View {
        VStack(spacing: TAROSpacing.md) {
            Text("No photo to adjust")
                .font(TAROTypography.body)
                .foregroundColor(Color.white.opacity(0.6))
        }
        .frame(height: 300)
    }
    
    // MARK: - Tool Actions
    
    private func toggleFitFill() {
        guard currentPhotoIndex >= 0 && currentPhotoIndex < totalPhotos else { return }
        let currentMode = currentSession.photos[currentPhotoIndex].cropState.mode
        currentSession.photos[currentPhotoIndex].cropState.mode = (currentMode == .fit ? .fill : .fit)
    }
    
    private func rotatePhoto() {
        guard currentPhotoIndex >= 0 && currentPhotoIndex < totalPhotos else { return }
        let turns = currentSession.photos[currentPhotoIndex].cropState.rotationQuarterTurns
        currentSession.photos[currentPhotoIndex].cropState.rotationQuarterTurns = (turns + 1) % 4
    }
    
    private func flipPhoto() {
        guard currentPhotoIndex >= 0 && currentPhotoIndex < totalPhotos else { return }
        currentSession.photos[currentPhotoIndex].cropState.isHorizontallyFlipped.toggle()
    }
    
    private func resetCrop() {
        guard currentPhotoIndex >= 0 && currentPhotoIndex < totalPhotos else { return }
        currentSession.photos[currentPhotoIndex].cropState = PhotoCropState()
    }
}

#Preview {
    var session = BoothSession()
    session.photos = [
        BoothPhoto(id: "1", source: .library, localIdentifier: "lib_1", orderIndex: 0),
        BoothPhoto(id: "2", source: .library, localIdentifier: "lib_2", orderIndex: 1)
    ]
    
    return CropPhotoView(
        navigationPath: .constant(NavigationPath()),
        currentSession: .constant(session)
    )
}
