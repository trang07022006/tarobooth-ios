import SwiftUI

struct ResultView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var currentSession: BoothSession
    @Binding var galleryItems: [GalleryItem]
    
    @State private var feedbackMessage: String? = nil
    @State private var isAddedToGallery = false
    
    init(
        navigationPath: Binding<NavigationPath>,
        currentSession: Binding<BoothSession> = .constant(BoothSession()),
        galleryItems: Binding<[GalleryItem]> = .constant([])
    ) {
        self._navigationPath = navigationPath
        self._currentSession = currentSession
        self._galleryItems = galleryItems
    }
    
    private var activeLayout: BoothLayoutType {
        currentSession.editorState.layoutOverride ?? currentSession.selectedTemplate?.layoutType ?? .verticalFourCut
    }
    
    private var templateDisplayName: String {
        currentSession.selectedTemplate?.name ?? "4 Cut"
    }
    
    private var filmSummary: String {
        let presetIDs = Set(currentSession.photos.compactMap { $0.filmPresetID })
        if presetIDs.isEmpty {
            return "Original"
        } else if presetIDs.count == 1, let first = presetIDs.first {
            return MockData.filmPresets.first(where: { $0.id == first })?.displayName ?? first.capitalized
        } else {
            return "Mixed Film (\(presetIDs.count))"
        }
    }
    
    private var formattedCreatedDate: String {
        TARODateFormatter.shared.string(from: currentSession.createdAt, format: .ddMMyyyy)
    }
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Bar: Back & Brand Title
                HStack {
                    TAROIconButton(icon: TAROIcons.back) {
                        // Return to existing Editor
                        navigationPath.removeLast()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("TAROBOOTH")
                            .font(TAROTypography.brandTitle)
                            .foregroundColor(TAROColors.text)
                        Image(systemName: TAROIcons.heart)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(TAROColors.primaryPink)
                    }
                    
                    Spacer()
                    
                    // Balance space for center title
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, TAROSpacing.md)
                .padding(.top, TAROSpacing.xs)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: TAROSpacing.md) {
                        // Final Non-Interactive Photobooth Preview
                        BoothCanvasView(
                            layoutType: activeLayout,
                            frameColor: TAROColors.cream,
                            photos: currentSession.photos,
                            textLayers: currentSession.editorState.textLayers,
                            backgroundPresetID: currentSession.editorState.backgroundPresetID,
                            framePresetID: currentSession.editorState.framePresetID,
                            stickerLayers: currentSession.editorState.stickerLayers,
                            isInteractive: false,
                            sessionDate: currentSession.createdAt
                        )
                        .scaleEffect(0.85)
                        .frame(maxHeight: 380)
                        .clipped()
                        .padding(.horizontal, TAROSpacing.lg)
                        .padding(.top, TAROSpacing.xs)
                        
                        // Feedback Toast Banner
                        if let message = feedbackMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(TAROColors.strongPink)
                                Text(message)
                                    .font(TAROTypography.caption)
                                    .foregroundColor(TAROColors.text)
                            }
                            .padding(.horizontal, TAROSpacing.md)
                            .padding(.vertical, TAROSpacing.xs)
                            .background(TAROColors.white)
                            .cornerRadius(TARORadius.pill)
                            .applyTAROShadow(.soft)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                        
                        // Quick Info Card
                        HStack(spacing: TAROSpacing.lg) {
                            quickInfoItem(title: "TEMPLATE", value: templateDisplayName)
                            Divider().frame(height: 24)
                            quickInfoItem(title: "FILM", value: filmSummary)
                            Divider().frame(height: 24)
                            quickInfoItem(title: "DATE", value: formattedCreatedDate)
                        }
                        .padding(.vertical, TAROSpacing.sm)
                        .padding(.horizontal, TAROSpacing.md)
                        .background(TAROColors.white)
                        .cornerRadius(TARORadius.md)
                        .applyTAROShadow(.soft)
                        .padding(.horizontal, TAROSpacing.lg)
                        
                        // Primary Actions: SAVE PHOTO & SHARE (Honest Foundation)
                        HStack(spacing: TAROSpacing.md) {
                            Button(action: {
                                showFeedback("High-resolution export will be available in the native rendering step.")
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: TAROIcons.save)
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("SAVE PHOTO")
                                        .font(TAROTypography.button)
                                }
                                .foregroundColor(TAROColors.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(TAROColors.text)
                                .cornerRadius(TARORadius.pill)
                                .applyTAROShadow(.soft)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                showFeedback("Share sheet will be available in the native export step.")
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: TAROIcons.share)
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("SHARE")
                                        .font(TAROTypography.button)
                                }
                                .foregroundColor(TAROColors.text)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(TAROColors.white)
                                .cornerRadius(TARORadius.pill)
                                .overlay(
                                    RoundedRectangle(cornerRadius: TARORadius.pill)
                                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                                )
                                .applyTAROShadow(.soft)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, TAROSpacing.lg)
                        
                        // Secondary Actions: ADD TO GALLERY & CREATE ANOTHER
                        VStack(spacing: TAROSpacing.sm) {
                            Button(action: {
                                addToGallery()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: isAddedToGallery ? "checkmark.circle.fill" : TAROIcons.gallery)
                                        .font(.system(size: 15))
                                    Text(isAddedToGallery ? "ADDED TO GALLERY" : "ADD TO GALLERY")
                                        .font(TAROTypography.button)
                                }
                                .foregroundColor(isAddedToGallery ? TAROColors.text.opacity(0.4) : TAROColors.strongPink)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(isAddedToGallery ? Color.black.opacity(0.04) : TAROColors.softBlush.opacity(0.4))
                                .cornerRadius(TARORadius.pill)
                            }
                            .buttonStyle(.plain)
                            .disabled(isAddedToGallery)
                            
                            Button(action: {
                                createAnother()
                            }) {
                                Text("CREATE ANOTHER")
                                    .font(TAROTypography.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(TAROColors.text.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, TAROSpacing.lg)
                        .padding(.bottom, TAROSpacing.xl)
                    }
                    .frame(maxWidth: 650)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Helpers
    
    private func quickInfoItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(TAROColors.text.opacity(0.4))
            Text(value)
                .font(TAROTypography.caption)
                .fontWeight(.semibold)
                .foregroundColor(TAROColors.text)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func showFeedback(_ text: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            feedbackMessage = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if feedbackMessage == text {
                    feedbackMessage = nil
                }
            }
        }
    }
    
    private func addToGallery() {
        guard !isAddedToGallery else { return }
        
        // Take a pure value-type snapshot of the booth session
        let snapshotItem = GalleryItem(
            id: UUID().uuidString,
            createdAt: currentSession.createdAt,
            templateName: templateDisplayName,
            layoutType: activeLayout,
            isFavorite: false,
            photos: currentSession.photos,
            editorState: currentSession.editorState
        )
        
        galleryItems.insert(snapshotItem, at: 0)
        isAddedToGallery = true
        showFeedback("Booth added to Gallery!")
    }
    
    private func createAnother() {
        // Reset only current creation session
        currentSession = BoothSession()
        // Pop back to root (Home)
        navigationPath = NavigationPath()
    }
}

#Preview {
    ResultView(
        navigationPath: .constant(NavigationPath()),
        currentSession: .constant(BoothSession()),
        galleryItems: .constant([])
    )
}
