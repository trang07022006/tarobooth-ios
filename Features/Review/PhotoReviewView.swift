import SwiftUI

struct PhotoReviewView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var currentSession: BoothSession
    
    @State private var selectedPhotoID: String?
    
    init(navigationPath: Binding<NavigationPath>, currentSession: Binding<BoothSession> = .constant(BoothSession())) {
        self._navigationPath = navigationPath
        self._currentSession = currentSession
    }
    
    private var totalPhotos: Int {
        currentSession.selectedTemplate?.photoCount ?? 4
    }
    
    private var templateName: String {
        currentSession.selectedTemplate?.displayName ?? "Booth"
    }
    
    private var isSessionValid: Bool {
        !currentSession.photos.isEmpty && currentSession.photos.count == totalPhotos
    }
    
    private var selectedPhoto: BoothPhoto? {
        if let id = selectedPhotoID {
            return currentSession.photos.first { $0.id == id }
        }
        return currentSession.photos.first
    }
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            if currentSession.photos.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    // Top Bar
                    topBar
                        .padding(.top, TAROSpacing.xs)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: TAROSpacing.lg) {
                            // Template summary pill
                            templateSummaryBadge
                                .padding(.top, TAROSpacing.xs)
                            
                            // Photo Grid or Single Preview
                            if totalPhotos == 1 {
                                singlePhotoPreview
                            } else {
                                multiPhotoGrid
                            }
                            
                            // Selected Photo Inspector & Action Panel
                            if let photo = selectedPhoto {
                                selectedPhotoDetailPanel(for: photo)
                            }
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
        }
        .navigationBarHidden(true)
        .onAppear {
            // Select first photo by default if none selected
            if selectedPhotoID == nil || !currentSession.photos.contains(where: { $0.id == selectedPhotoID }) {
                selectedPhotoID = currentSession.photos.first?.id
            }
            // Normalize order index
            currentSession.normalizePhotoOrder()
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
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
                Text("Review photos")
                    .font(TAROTypography.heading2)
                    .foregroundColor(TAROColors.text)
                
                Text("Make sure every moment feels right.")
                    .font(TAROTypography.caption)
                    .foregroundColor(TAROColors.text.opacity(0.6))
            }
            
            Spacer()
            
            // Spacer balance for 44pt left button
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, TAROSpacing.lg)
    }
    
    // MARK: - Template Summary Badge
    
    private var templateSummaryBadge: some View {
        HStack(spacing: TAROSpacing.xs) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(TAROColors.strongPink)
            
            Text("\(templateName) • \(totalPhotos) \(totalPhotos == 1 ? "photo" : "photos")")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(TAROColors.text)
        }
        .padding(.horizontal, TAROSpacing.md)
        .padding(.vertical, 6)
        .background(Color.white)
        .cornerRadius(TARORadius.pill)
        .applyTAROShadow(.soft)
    }
    
    // MARK: - Single Photo Preview Layout
    
    @ViewBuilder
    private var singlePhotoPreview: some View {
        if let photo = currentSession.photos.first {
            let isSelected = selectedPhotoID == photo.id
            
            Button(action: {
                selectedPhotoID = photo.id
            }) {
                ZStack(alignment: .topTrailing) {
                    // Photo Card Surface
                    RoundedRectangle(cornerRadius: TARORadius.lg)
                        .fill(Color(hex: "232022"))
                        .aspectRatio(4/5, contentMode: .fit)
                        .overlay(
                            TAROPhotoSurfaceView(photo: photo)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: TARORadius.lg))
                
                // Position Badge (Top-Left)
                HStack {
                    Text("1")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    // Film Preset Badge (Top-Right)
                    Text(filmPresetName(for: photo.filmPresetID))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(TARORadius.sm)
                }
                .padding(TAROSpacing.sm)
            }
            .overlay(
                RoundedRectangle(cornerRadius: TARORadius.lg)
                    .stroke(isSelected ? TAROColors.strongPink : Color.black.opacity(0.1), lineWidth: isSelected ? 3 : 1)
            )
            .applyTAROShadow(.medium)
            .frame(maxWidth: 340)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Multi Photo Grid Layout
    
    private var multiPhotoGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: TAROSpacing.md),
                GridItem(.flexible(), spacing: TAROSpacing.md)
            ],
            spacing: TAROSpacing.md
        ) {
            ForEach(currentSession.photos) { photo in
                let isSelected = selectedPhotoID == photo.id
                let displayOrder = photo.orderIndex + 1
                
                Button(action: {
                    selectedPhotoID = photo.id
                }) {
                    ZStack(alignment: .bottom) {
                        // Card surface
                        RoundedRectangle(cornerRadius: TARORadius.md)
                            .fill(Color(hex: "232022"))
                            .aspectRatio(3/4, contentMode: .fit)
                            .overlay(
                                TAROPhotoSurfaceView(photo: photo)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: TARORadius.md))
                        
                        // Top row badges: Order (left) & Selection Indicator (right)
                        VStack {
                            HStack {
                                Text("\(displayOrder)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.black.opacity(0.65))
                                    .clipShape(Circle())
                                
                                Spacer()
                                
                                // Selection Radio / Checkmark
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? TAROColors.strongPink : Color.black.opacity(0.4))
                                        .frame(width: 22, height: 22)
                                    
                                    if isSelected {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(TAROSpacing.xs)
                            
                            Spacer()
                            
                            // Bottom row: Film Preset chip
                            HStack {
                                Text(filmPresetName(for: photo.filmPresetID))
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(TARORadius.sm)
                                
                                Spacer()
                            }
                            .padding(TAROSpacing.xs)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: TARORadius.md)
                            .stroke(isSelected ? TAROColors.strongPink : Color.black.opacity(0.08), lineWidth: isSelected ? 3 : 1)
                    )
                    .applyTAROShadow(isSelected ? .medium : .soft)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Selected Photo Detail & Actions Panel
    
    private func selectedPhotoDetailPanel(for photo: BoothPhoto) -> some View {
        let displayOrder = photo.orderIndex + 1
        let canMoveLeft = photo.orderIndex > 0
        let canMoveRight = photo.orderIndex < currentSession.photos.count - 1
        
        return VStack(spacing: TAROSpacing.md) {
            // Header Row: Info & Reorder buttons
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Photo \(displayOrder) of \(totalPhotos)")
                        .font(TAROTypography.heading2)
                        .foregroundColor(TAROColors.text)
                    
                    HStack(spacing: TAROSpacing.sm) {
                        // Source label
                        HStack(spacing: 3) {
                            Image(systemName: photo.source == .camera ? "camera.fill" : "photo.fill")
                                .font(.system(size: 10))
                            Text(photo.source.displayName)
                                .font(TAROTypography.caption)
                        }
                        .foregroundColor(TAROColors.text.opacity(0.6))
                        
                        Text("•")
                            .foregroundColor(TAROColors.text.opacity(0.6))
                        
                        // Film preset label with swatch
                        HStack(spacing: 4) {
                            Circle()
                                .fill(filmSwatchGradient(for: photo.filmPresetID))
                                .frame(width: 10, height: 10)
                            Text(filmPresetName(for: photo.filmPresetID))
                                .font(TAROTypography.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(TAROColors.text)
                    }
                }
                
                Spacer()
                
                // Reorder Buttons (only for multi-photo)
                if totalPhotos > 1 {
                    HStack(spacing: TAROSpacing.xs) {
                        Button(action: { moveSelectedPhoto(direction: -1) }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(canMoveLeft ? TAROColors.text : Color.gray.opacity(0.4))
                                .frame(width: 36, height: 36)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canMoveLeft)
                        
                        Button(action: { moveSelectedPhoto(direction: 1) }) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(canMoveRight ? TAROColors.text : Color.gray.opacity(0.4))
                                .frame(width: 36, height: 36)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canMoveRight)
                    }
                }
            }
            
            Divider()
            
            // Action Buttons: Retake & Replace
            HStack(spacing: TAROSpacing.md) {
                // Retake Button (Navigates to Camera in Retake Mode)
                Button(action: {
                    currentSession.pendingReplacementPhotoID = photo.id
                    navigationPath.append(AppRoute.camera)
                }) {
                    HStack(spacing: TAROSpacing.xs) {
                        Image(systemName: TAROIcons.retake)
                            .font(.system(size: 15, weight: .semibold))
                        Text("Retake")
                            .font(TAROTypography.button)
                    }
                    .foregroundColor(TAROColors.strongPink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(TAROColors.softBlush.opacity(0.5))
                    .cornerRadius(TARORadius.md)
                }
                .buttonStyle(.plain)
                
                // Replace Button (Navigates to Library Picker in Replacement Mode)
                Button(action: {
                    currentSession.pendingReplacementPhotoID = photo.id
                    navigationPath.append(AppRoute.library)
                }) {
                    HStack(spacing: TAROSpacing.xs) {
                        Image(systemName: TAROIcons.replace)
                            .font(.system(size: 15, weight: .semibold))
                        Text("Replace")
                            .font(TAROTypography.button)
                    }
                    .foregroundColor(TAROColors.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(TARORadius.md)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(TAROSpacing.md)
        .background(Color.white)
        .cornerRadius(TARORadius.lg)
        .applyTAROShadow(.soft)
    }
    
    // MARK: - Bottom CTA
    
    private var bottomCTA: some View {
        VStack(spacing: TAROSpacing.xs) {
            Button(action: {
                guard isSessionValid else { return }
                currentSession.normalizePhotoOrder()
                navigationPath.append(AppRoute.editor)
            }) {
                Text("CONTINUE TO EDIT")
                    .font(TAROTypography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(isSessionValid ? TAROColors.strongPink : Color.gray.opacity(0.4))
                    .cornerRadius(TARORadius.pill)
                    .applyTAROShadow(isSessionValid ? .medium : .soft)
            }
            .buttonStyle(.plain)
            .disabled(!isSessionValid)
            
            if !isSessionValid {
                Text("Need \(totalPhotos) photos to continue (\(currentSession.photos.count)/\(totalPhotos))")
                    .font(TAROTypography.caption)
                    .foregroundColor(TAROColors.text.opacity(0.6))
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: TAROSpacing.lg) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 56, weight: .light))
                .foregroundColor(TAROColors.text.opacity(0.6))
            
            VStack(spacing: TAROSpacing.xs) {
                Text("No photos to review")
                    .font(TAROTypography.heading1)
                    .foregroundColor(TAROColors.text)
                
                Text("Please capture or select photos for your booth session.")
                    .font(TAROTypography.body)
                    .foregroundColor(TAROColors.text.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, TAROSpacing.xl)
            
            Button(action: {
                navigationPath.removeLast()
            }) {
                Text("BACK TO SOURCE")
                    .font(TAROTypography.button)
                    .foregroundColor(.white)
                    .padding(.horizontal, TAROSpacing.xl)
                    .frame(height: 48)
                    .background(TAROColors.strongPink)
                    .cornerRadius(TARORadius.pill)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    
    // MARK: - Helpers
    
    private func moveSelectedPhoto(direction: Int) {
        guard let id = selectedPhotoID,
              let index = currentSession.photos.firstIndex(where: { $0.id == id }) else { return }
        let targetIndex = index + direction
        guard targetIndex >= 0 && targetIndex < currentSession.photos.count else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            currentSession.photos.swapAt(index, targetIndex)
            currentSession.normalizePhotoOrder()
        }
    }
    
    private func filmPresetName(for presetID: String?) -> String {
        let id = presetID ?? "original"
        return MockData.filmPresets.first(where: { $0.id == id })?.displayName ?? "Original"
    }
    
    private func filmSwatchGradient(for presetID: String?) -> LinearGradient {
        let id = presetID ?? "original"
        switch id.lowercased() {
        case "cream":
            return LinearGradient(colors: [Color(hex: "FFF8F0"), Color(hex: "F2E6D8")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "warm":
            return LinearGradient(colors: [Color(hex: "FFDFC4"), Color(hex: "F4A261")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "vintage":
            return LinearGradient(colors: [Color(hex: "DDB892"), Color(hex: "7F5539")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "retro":
            return LinearGradient(colors: [Color(hex: "E76F51"), Color(hex: "E9C46A")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "disposable":
            return LinearGradient(colors: [Color(hex: "2A9D8F"), Color(hex: "E76F51")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "mono":
            return LinearGradient(colors: [Color(hex: "2B2528"), Color(hex: "888888")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "cool":
            return LinearGradient(colors: [Color(hex: "C5E3F6"), Color(hex: "457B9D")], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [Color(hex: "E5E5E5"), Color(hex: "A3A3A3")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

#Preview {
    var session = BoothSession()
    session.selectedTemplate = MockData.templates[1] // 4 Cut
    session.photos = [
        BoothPhoto(id: "1", source: .camera, localIdentifier: "cam_1", orderIndex: 0, filmPresetID: "cream"),
        BoothPhoto(id: "2", source: .camera, localIdentifier: "cam_2", orderIndex: 1, filmPresetID: "warm"),
        BoothPhoto(id: "3", source: .camera, localIdentifier: "cam_3", orderIndex: 2, filmPresetID: "mono"),
        BoothPhoto(id: "4", source: .camera, localIdentifier: "cam_4", orderIndex: 3, filmPresetID: "vintage")
    ]
    
    return PhotoReviewView(
        navigationPath: .constant(NavigationPath()),
        currentSession: .constant(session)
    )
}
