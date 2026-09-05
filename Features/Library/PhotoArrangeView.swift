import SwiftUI

struct PhotoArrangeView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var currentSession: BoothSession
    
    init(navigationPath: Binding<NavigationPath>, currentSession: Binding<BoothSession> = .constant(BoothSession())) {
        self._navigationPath = navigationPath
        self._currentSession = currentSession
    }
    
    private var totalPhotos: Int {
        currentSession.photos.count
    }
    
    private var templateLayout: BoothLayoutType {
        currentSession.selectedTemplate?.layoutType ?? .verticalFourCut
    }
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Header
                topHeader
                    .padding(.top, TAROSpacing.xs)
                    .padding(.horizontal, TAROSpacing.lg)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: TAROSpacing.lg) {
                        // Small Layout Preview
                        miniLayoutPreview
                            .padding(.top, TAROSpacing.xs)
                        
                        // Ordered Photos List
                        photoOrderList
                    }
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.bottom, TAROSpacing.xl)
                }
                
                // Bottom Primary CTA
                bottomCTA
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.vertical, TAROSpacing.md)
                    .background(
                        TAROColors.background
                            .applyTAROShadow(.soft)
                            .ignoresSafeArea(edges: .bottom)
                    )
            }
            .frame(maxWidth: 650)
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
        .onAppear {
            currentSession.normalizePhotoOrder()
        }
    }
    
    // MARK: - Header
    
    private var topHeader: some View {
        HStack {
            Button(action: {
                navigationPath.removeLast()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(TAROColors.text)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .applyTAROShadow(.soft)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Arrange photos")
                    .font(TAROTypography.heading2)
                    .foregroundColor(TAROColors.text)
                
                Text("Set the order for your booth.")
                    .font(TAROTypography.caption)
                    .foregroundColor(TAROColors.text.opacity(0.6))
            }
            
            Spacer()
            
            // Spacer balance for 44pt left button
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
    
    // MARK: - Mini Layout Preview
    
    private var miniLayoutPreview: some View {
        VStack(spacing: TAROSpacing.xs) {
            Text("PREVIEW LAYOUT")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(TAROColors.text.opacity(0.5))
                .tracking(1.0)
            
            BoothCanvasView(
                layoutType: templateLayout,
                frameColor: TAROColors.cream
            )
            .scaleEffect(0.62)
            .frame(height: 180)
            .clipped()
            .cornerRadius(TARORadius.md)
            .applyTAROShadow(.soft)
        }
    }
    
    // MARK: - Photo Order List
    
    private var photoOrderList: some View {
        VStack(spacing: TAROSpacing.sm) {
            ForEach(Array(currentSession.photos.enumerated()), id: \.element.id) { index, photo in
                let displayOrder = photo.orderIndex + 1
                let canMoveUp = index > 0
                let canMoveDown = index < totalPhotos - 1
                
                HStack(spacing: TAROSpacing.md) {
                    // Position Number Badge
                    Text("\(displayOrder)")
                        .font(TAROTypography.heading2)
                        .foregroundColor(TAROColors.primaryPink)
                        .frame(width: 32)
                    
                    // Photo Card Thumbnail
                    HStack(spacing: TAROSpacing.sm) {
                        ZStack {
                            RoundedRectangle(cornerRadius: TARORadius.sm)
                                .fill(Color(hex: "232022"))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    TAROPhotoSurfaceView(photo: photo)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: TARORadius.sm))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Photo \(displayOrder)")
                                .font(TAROTypography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(TAROColors.text)
                            
                            Text(photo.localIdentifier)
                                .font(TAROTypography.caption)
                                .foregroundColor(TAROColors.text.opacity(0.5))
                        }
                        
                        Spacer()
                    }
                    .padding(TAROSpacing.xs)
                    .background(Color.white)
                    .cornerRadius(TARORadius.md)
                    .applyTAROShadow(.soft)
                    
                    // Reorder Controls (Move Up / Move Down)
                    VStack(spacing: 4) {
                        Button(action: { movePhoto(from: index, to: index - 1) }) {
                            Image(systemName: "chevron.up.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(canMoveUp ? TAROColors.strongPink : Color.gray.opacity(0.25))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canMoveUp)
                        
                        Button(action: { movePhoto(from: index, to: index + 1) }) {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(canMoveDown ? TAROColors.strongPink : Color.gray.opacity(0.25))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canMoveDown)
                    }
                    .frame(width: 44)
                }
            }
        }
    }
    
    // MARK: - Bottom CTA
    
    private var bottomCTA: some View {
        TAROPrimaryButton(title: "Continue") {
            currentSession.normalizePhotoOrder()
            navigationPath.append(AppRoute.crop)
        }
    }
    
    // MARK: - Actions
    
    private func movePhoto(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex >= 0 && sourceIndex < totalPhotos,
              destinationIndex >= 0 && destinationIndex < totalPhotos else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            currentSession.photos.swapAt(sourceIndex, destinationIndex)
            currentSession.normalizePhotoOrder()
        }
    }
}

#Preview {
    var session = BoothSession()
    session.selectedTemplate = MockData.templates[1] // 4 Cut
    session.photos = [
        BoothPhoto(id: "1", source: .library, localIdentifier: "lib_1", orderIndex: 0),
        BoothPhoto(id: "2", source: .library, localIdentifier: "lib_2", orderIndex: 1),
        BoothPhoto(id: "3", source: .library, localIdentifier: "lib_3", orderIndex: 2),
        BoothPhoto(id: "4", source: .library, localIdentifier: "lib_4", orderIndex: 3)
    ]
    
    return PhotoArrangeView(
        navigationPath: .constant(NavigationPath()),
        currentSession: .constant(session)
    )
}
