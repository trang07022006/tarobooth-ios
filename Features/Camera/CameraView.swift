import SwiftUI
import UIKit

struct CameraView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var currentSession: BoothSession
    
    @StateObject private var cameraService = CameraService()
    
    @State private var activeFilmPreset: FilmPreset
    @State private var sessionCapturedPhotoIDs: [String] = []
    @State private var isFrontCamera = false
    @State private var isCapturing = false
    @State private var flashOpacity: Double = 0.0
    @State private var isCameraAuthorized = true
    
    init(navigationPath: Binding<NavigationPath>, currentSession: Binding<BoothSession> = .constant(BoothSession())) {
        self._navigationPath = navigationPath
        self._currentSession = currentSession
        
        let presetID = currentSession.wrappedValue.selectedFilmPresetID ?? "original"
        let initialPreset = MockData.filmPresets.first { $0.id == presetID } ?? MockData.filmPresets[0]
        self._activeFilmPreset = State(initialValue: initialPreset)
    }
    
    private var isRetakeMode: Bool {
        currentSession.pendingReplacementPhotoID != nil
    }
    
    private var targetPhotoBeingReplaced: BoothPhoto? {
        guard let id = currentSession.pendingReplacementPhotoID else { return nil }
        return currentSession.photos.first { $0.id == id }
    }
    
    private var totalPhotos: Int {
        currentSession.selectedTemplate?.photoCount ?? 4
    }
    
    private var modeTitle: String {
        if isRetakeMode, let target = targetPhotoBeingReplaced {
            return "Retake Photo \(target.orderIndex + 1)"
        }
        return currentSession.selectedTemplate?.displayName ?? "Booth"
    }
    
    private var capturedCount: Int {
        currentSession.photos.count
    }
    
    private var isSessionComplete: Bool {
        if isRetakeMode { return false }
        return capturedCount >= totalPhotos
    }
    
    private var currentSlotDisplayNumber: Int {
        if isRetakeMode, let target = targetPhotoBeingReplaced {
            return target.orderIndex + 1
        }
        guard totalPhotos > 0 else { return 1 }
        if capturedCount >= totalPhotos {
            return totalPhotos
        }
        return max(1, capturedCount + 1)
    }
    
    var body: some View {
        ZStack {
            TAROColors.cameraBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                topBar
                    .padding(.top, TAROSpacing.xs)
                
                Spacer(minLength: TAROSpacing.xs)
                
                // Camera Viewfinder Preview (Adaptive 4:5 ratio)
                cameraPreview
                    .padding(.horizontal, TAROSpacing.md)
                
                Spacer(minLength: TAROSpacing.xs)
                
                // Captured Photo Strip (Multi-shot only)
                if totalPhotos > 1 {
                    CapturedPhotoStrip(capturedCount: capturedCount, totalCount: totalPhotos)
                        .padding(.vertical, 4)
                }
                
                // Film Preset Carousel
                FilmPresetCarousel(selectedPreset: $activeFilmPreset)
                    .padding(.vertical, TAROSpacing.xs)
                    .onChange(of: activeFilmPreset) { _, newPreset in
                        currentSession.selectedFilmPresetID = newPreset.id
                    }
                
                // Bottom Area: Shutter Controls OR Review CTA
                bottomControlsArea
                    .padding(.bottom, TAROSpacing.lg)
            }
            .frame(maxWidth: 650)
            .frame(maxWidth: .infinity)
            
            // Flash Overlay Animation
            Color.white
                .ignoresSafeArea()
                .opacity(flashOpacity)
                .allowsHitTesting(false)
        }
        .navigationBarHidden(true)
        .onAppear {
            setupInitialPreset()
            startNativeCamera()
        }
        .onDisappear {
            cameraService.stopSession()
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button(action: exitCamera) {
                Image(systemName: TAROIcons.close)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(modeTitle)
                .font(TAROTypography.heading2)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(currentSlotDisplayNumber) / \(totalPhotos)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(TAROColors.softBlush)
                .padding(.horizontal, TAROSpacing.sm)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.15))
                .cornerRadius(TARORadius.pill)
                .frame(minWidth: 44)
        }
        .padding(.horizontal, TAROSpacing.lg)
    }
    
    // MARK: - Camera Viewfinder Preview
    
    private var cameraPreview: some View {
        ZStack {
            // Base viewfinder surface
            RoundedRectangle(cornerRadius: TARORadius.lg)
                .fill(Color(hex: "232022"))
                .aspectRatio(4/5, contentMode: .fit)
            
            // Native Video Feed or Permission/Fallback Surface
            if !isCameraAuthorized {
                permissionDeniedViewfinder
            } else if cameraService.isRunning {
                CameraPreviewView(session: cameraService.session)
                    .aspectRatio(4/5, contentMode: .fit)
                    .clipped()
            } else {
                fallbackViewfinderSurface
            }
            
            // Viewfinder corner marks
            viewfinderCorners
            
            // Session Complete Banner
            if isSessionComplete {
                ZStack {
                    Color.black.opacity(0.65)
                        .cornerRadius(TARORadius.lg)
                    
                    VStack(spacing: TAROSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(TAROColors.primaryPink)
                        
                        Text("All shots captured")
                            .font(TAROTypography.heading2)
                            .foregroundColor(.white)
                        
                        Text("Ready to review your moments")
                            .font(TAROTypography.caption)
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                }
                .transition(.opacity)
            }
        }
        .applyFilmPresetEffect(activeFilmPreset.id)
        .clipShape(RoundedRectangle(cornerRadius: TARORadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: TARORadius.lg)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var permissionDeniedViewfinder: some View {
        VStack(spacing: TAROSpacing.sm) {
            Image(systemName: "camera.badge.ellipsis")
                .font(.system(size: 44, weight: .light))
                .foregroundColor(TAROColors.strongPink)
            
            Text("Camera Access Needed")
                .font(TAROTypography.heading2)
                .foregroundColor(.white)
            
            Text("Camera access is required to take photos.")
                .font(TAROTypography.caption)
                .foregroundColor(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, TAROSpacing.lg)
            
            HStack(spacing: TAROSpacing.md) {
                Button(action: {
                    navigationPath.removeLast()
                }) {
                    Text("BACK")
                        .font(TAROTypography.button)
                        .foregroundColor(.white)
                        .padding(.horizontal, TAROSpacing.lg)
                        .frame(height: 38)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(TARORadius.pill)
                }
                .buttonStyle(.plain)
                
                Button(action: openDeviceSettings) {
                    Text("OPEN SETTINGS")
                        .font(TAROTypography.button)
                        .foregroundColor(.white)
                        .padding(.horizontal, TAROSpacing.lg)
                        .frame(height: 38)
                        .background(TAROColors.strongPink)
                        .cornerRadius(TARORadius.pill)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(TAROSpacing.md)
    }
    
    private var fallbackViewfinderSurface: some View {
        VStack(spacing: TAROSpacing.sm) {
            Image(systemName: isFrontCamera ? "person.crop.circle.fill" : "viewfinder")
                .font(.system(size: 52, weight: .ultraLight))
                .foregroundColor(Color.white.opacity(0.35))
            
            Text(isFrontCamera ? "FRONT CAMERA" : "BACK CAMERA")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.4))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.3))
                .cornerRadius(TARORadius.sm)
        }
    }
    
    // Viewfinder Corner Markings
    private var viewfinderCorners: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cornerLen: CGFloat = 20
            
            Path { path in
                // Top-Left
                path.move(to: CGPoint(x: 16, y: 16 + cornerLen))
                path.addLine(to: CGPoint(x: 16, y: 16))
                path.addLine(to: CGPoint(x: 16 + cornerLen, y: 16))
                
                // Top-Right
                path.move(to: CGPoint(x: w - 16 - cornerLen, y: 16))
                path.addLine(to: CGPoint(x: w - 16, y: 16))
                path.addLine(to: CGPoint(x: w - 16, y: 16 + cornerLen))
                
                // Bottom-Left
                path.move(to: CGPoint(x: 16, y: h - 16 - cornerLen))
                path.addLine(to: CGPoint(x: 16, y: h - 16))
                path.addLine(to: CGPoint(x: 16 + cornerLen, y: h - 16))
                
                // Bottom-Right
                path.move(to: CGPoint(x: w - 16 - cornerLen, y: h - 16))
                path.addLine(to: CGPoint(x: w - 16, y: h - 16))
                path.addLine(to: CGPoint(x: w - 16 - cornerLen, y: h - 16))
            }
            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
        }
    }
    
    // MARK: - Bottom Controls Area
    
    @ViewBuilder
    private var bottomControlsArea: some View {
        if !isCameraAuthorized && cameraService.hasCameraHardware {
            // Shutter controls hidden when permission denied on hardware
            Color.clear
                .frame(height: 80)
        } else if isSessionComplete && !isRetakeMode {
            // Completed state CTA: Proceed to Review
            VStack(spacing: TAROSpacing.xs) {
                Button(action: {
                    navigationPath.append(AppRoute.review)
                }) {
                    HStack(spacing: TAROSpacing.xs) {
                        Text("REVIEW PHOTOS")
                            .font(TAROTypography.button)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(TAROColors.cameraBackground)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(TAROColors.primaryPink)
                    .cornerRadius(TARORadius.pill)
                    .applyTAROShadow(.medium)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, TAROSpacing.xl)
            }
            .transition(.opacity)
        } else {
            // Live Shutter Controls
            CameraControlsView(
                currentShot: currentSlotDisplayNumber,
                totalShots: totalPhotos,
                canCapture: !isCapturing && (!isSessionComplete || isRetakeMode),
                isCapturing: isCapturing,
                canRetake: !isRetakeMode && !sessionCapturedPhotoIDs.isEmpty,
                onCapture: triggerCapture,
                onFlip: switchCameraOrientation,
                onRetake: retakeLastShot
            )
        }
    }
    
    // MARK: - Actions
    
    private func setupInitialPreset() {
        if isRetakeMode, let target = targetPhotoBeingReplaced, let targetPresetID = target.filmPresetID {
            if let preset = MockData.filmPresets.first(where: { $0.id == targetPresetID }) {
                activeFilmPreset = preset
            }
        } else {
            let presetID = currentSession.selectedFilmPresetID ?? "original"
            if let saved = MockData.filmPresets.first(where: { $0.id == presetID }) {
                activeFilmPreset = saved
            }
        }
        currentSession.selectedFilmPresetID = activeFilmPreset.id
    }
    
    private func startNativeCamera() {
        Task {
            do {
                try await cameraService.startSession()
            } catch {
                if let taroErr = error as? TAROCoreError, taroErr == .permissionDenied {
                    await MainActor.run {
                        isCameraAuthorized = false
                    }
                }
            }
        }
    }
    
    private func switchCameraOrientation() {
        let nextPos: CameraPosition = isFrontCamera ? .back : .front
        Task {
            try? await cameraService.switchCamera(to: nextPos)
            await MainActor.run {
                isFrontCamera.toggle()
            }
        }
    }
    
    private func triggerCapture() {
        guard !isCapturing else { return }
        if !isRetakeMode && isSessionComplete { return }
        
        // Strict guard: production permission denial must NEVER silently take fake mock photos
        if !isCameraAuthorized && cameraService.hasCameraHardware {
            return
        }
        
        isCapturing = true
        
        // Flash effect animation
        withAnimation(.easeIn(duration: 0.08)) {
            flashOpacity = 0.85
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeOut(duration: 0.2)) {
                flashOpacity = 0.0
            }
        }
        
        Task {
            var captureResult: CameraCaptureResult? = nil
            
            if cameraService.isRunning {
                do {
                    captureResult = try await cameraService.capturePhoto()
                } catch {
                    // Capture failure
                }
            }
            
            // Mock capture allowed ONLY in preview/simulator/development where camera hardware is genuinely unavailable
            if captureResult == nil && (!cameraService.hasCameraHardware || !cameraService.isRunning) {
                #if DEBUG
                captureResult = CameraCaptureResult(
                    assetKey: "",
                    localIdentifier: "cam_\(UUID().uuidString.prefix(6))"
                )
                #endif
            }
            
            guard let result = captureResult else {
                await MainActor.run { isCapturing = false }
                return
            }
            
            await MainActor.run {
                let assetKeyToUse = result.assetKey.isEmpty ? nil : result.assetKey
                
                if isRetakeMode, let targetID = currentSession.pendingReplacementPhotoID,
                   let targetIdx = currentSession.photos.firstIndex(where: { $0.id == targetID }) {
                    let targetOrder = currentSession.photos[targetIdx].orderIndex
                    let replacementPhoto = BoothPhoto(
                        id: UUID().uuidString,
                        source: .camera,
                        localIdentifier: result.localIdentifier,
                        assetKey: assetKeyToUse,
                        orderIndex: targetOrder,
                        filmPresetID: activeFilmPreset.id,
                        cropState: PhotoCropState() // Fresh default crop state per Constraint 32
                    )
                    currentSession.photos[targetIdx] = replacementPhoto
                    currentSession.pendingReplacementPhotoID = nil
                    isCapturing = false
                    navigationPath.removeLast() // Return by POP to existing Review
                    return
                }
                
                let newPhoto = BoothPhoto(
                    id: UUID().uuidString,
                    source: .camera,
                    localIdentifier: result.localIdentifier,
                    assetKey: assetKeyToUse,
                    orderIndex: currentSession.photos.count,
                    filmPresetID: activeFilmPreset.id,
                    cropState: PhotoCropState()
                )
                
                sessionCapturedPhotoIDs.append(newPhoto.id)
                currentSession.photos.append(newPhoto)
                currentSession.currentShotIndex = currentSession.photos.count
                isCapturing = false
                
                if isSessionComplete {
                    currentSession.normalizePhotoOrder()
                }
            }
        }
    }
    
    private func retakeLastShot() {
        guard let lastSessionShotID = sessionCapturedPhotoIDs.last else { return }
        
        if let idx = currentSession.photos.lastIndex(where: { $0.id == lastSessionShotID }) {
            currentSession.photos.remove(at: idx)
        }
        sessionCapturedPhotoIDs.removeLast()
        currentSession.currentShotIndex = currentSession.photos.count
    }
    
    private func exitCamera() {
        cameraService.stopSession()
        
        if isRetakeMode {
            currentSession.pendingReplacementPhotoID = nil
            navigationPath.removeLast()
            return
        }
        
        currentSession.photos.removeAll { photo in
            sessionCapturedPhotoIDs.contains(photo.id)
        }
        sessionCapturedPhotoIDs.removeAll()
        currentSession.currentShotIndex = currentSession.photos.count
        navigationPath.removeLast()
    }
    
    private func openDeviceSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    CameraView(
        navigationPath: .constant(NavigationPath()),
        currentSession: .constant(BoothSession())
    )
}
