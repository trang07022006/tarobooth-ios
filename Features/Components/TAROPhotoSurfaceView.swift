import SwiftUI
import UIKit

public struct TAROPhotoSurfaceView: View {
    public let photo: BoothPhoto
    public var customAspectRatio: CGFloat? = nil
    
    @State private var loadedImage: UIImage? = nil
    @State private var isLoading: Bool = false
    @State private var loadFailed: Bool = false
    
    public init(photo: BoothPhoto, customAspectRatio: CGFloat? = nil) {
        self.photo = photo
        self.customAspectRatio = customAspectRatio
    }
    
    public var body: some View {
        let crop = photo.cropState
        
        ZStack {
            if let uiImage = loadedImage {
                // Real captured/imported original image with correct transform semantics
                if crop.mode == .fill {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .rotationEffect(.degrees(crop.rotationDegrees))
                        .scaleEffect(x: crop.isHorizontallyFlipped ? -1 : 1, y: 1)
                        .applyFilmPresetEffect(photo.filmPresetID)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(crop.rotationDegrees))
                        .scaleEffect(x: crop.isHorizontallyFlipped ? -1 : 1, y: 1)
                        .applyFilmPresetEffect(photo.filmPresetID)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else if isLoading {
                // Async image decode placeholder
                ZStack {
                    Color(hex: "232022")
                    ProgressView()
                        .tint(TAROColors.strongPink)
                        .scaleEffect(0.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Fallback stable mock surface for preview / testing / load failed
                mockSurface(crop: crop)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .onAppear {
            loadImageIfNeeded()
        }
        .onChange(of: photo.assetKey) {
            loadImageIfNeeded()
        }
    }
    
    private func loadImageIfNeeded() {
        guard let key = photo.assetKey else {
            loadedImage = nil
            isLoading = false
            loadFailed = false
            return
        }
        
        // Fast synchronous check against bounded memory cache
        if let cached = LocalPhotoStore.shared.cachedImage(assetKey: key) {
            self.loadedImage = cached
            self.isLoading = false
            self.loadFailed = false
            return
        }
        
        // Asynchronous decode off main thread to maintain 60/120fps UI
        isLoading = true
        loadFailed = false
        
        Task.detached(priority: .userInitiated) {
            let image = LocalPhotoStore.shared.loadImage(assetKey: key)
            await MainActor.run {
                self.loadedImage = image
                self.isLoading = false
                self.loadFailed = (image == nil)
            }
        }
    }
    
    @ViewBuilder
    private func mockSurface(crop: PhotoCropState) -> some View {
        VStack(spacing: TAROSpacing.xs) {
            Image(systemName: photo.source == .camera ? "camera.fill" : "photo.fill")
                .font(.system(size: 22, weight: .light))
                .foregroundColor(Color.white.opacity(0.45))
            
            Text("SHOT \(photo.orderIndex + 1)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.65))
            
            Text(photo.localIdentifier)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.4))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "2E2A2D"))
        .rotationEffect(.degrees(crop.rotationDegrees))
        .scaleEffect(x: crop.isHorizontallyFlipped ? -1 : 1, y: 1)
        .applyFilmPresetEffect(photo.filmPresetID)
    }
}

#Preview {
    TAROPhotoSurfaceView(
        photo: BoothPhoto(
            source: .camera,
            localIdentifier: "cam_sample",
            orderIndex: 0,
            filmPresetID: "cream"
        )
    )
}
