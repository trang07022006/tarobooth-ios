import SwiftUI

struct GalleryDetailView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var galleryItems: [GalleryItem]
    let itemId: String
    
    @State private var showDeleteConfirmation = false
    @State private var feedbackMessage: String? = nil
    
    init(
        navigationPath: Binding<NavigationPath>,
        itemId: String,
        galleryItems: Binding<[GalleryItem]> = .constant([])
    ) {
        self._navigationPath = navigationPath
        self.itemId = itemId
        self._galleryItems = galleryItems
    }
    
    private var itemIndex: Int? {
        galleryItems.firstIndex(where: { $0.id == itemId })
    }
    
    private var currentItem: GalleryItem? {
        guard let idx = itemIndex else { return nil }
        return galleryItems[idx]
    }
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            if let item = currentItem {
                VStack(spacing: 0) {
                    // Top Bar with Back, Title/Date, and Favorite Toggle
                    HStack {
                        TAROIconButton(icon: TAROIcons.back) {
                            navigationPath.removeLast()
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text(item.templateName)
                                .font(TAROTypography.heading2)
                                .foregroundColor(TAROColors.text)
                            Text(TARODateFormatter.shared.string(from: item.createdAt, format: .ddMMyyyy))
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundColor(TAROColors.text.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        TAROIconButton(
                            icon: item.isFavorite ? "heart.fill" : "heart",
                            color: item.isFavorite ? TAROColors.primaryPink : TAROColors.text
                        ) {
                            toggleFavorite()
                        }
                    }
                    .padding(.horizontal, TAROSpacing.md)
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
                        .padding(.top, TAROSpacing.xs)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    
                    Spacer()
                    
                    // Non-Interactive Booth Preview
                    BoothCanvasView(
                        layoutType: item.layoutType,
                        frameColor: TAROColors.cream,
                        photos: item.photos,
                        textLayers: item.editorState.textLayers,
                        backgroundPresetID: item.editorState.backgroundPresetID,
                        framePresetID: item.editorState.framePresetID,
                        stickerLayers: item.editorState.stickerLayers,
                        isInteractive: false,
                        sessionDate: item.createdAt
                    )
                    .scaleEffect(0.85)
                    .frame(maxHeight: 400)
                    .clipped()
                    .padding(.horizontal, TAROSpacing.xl)
                    
                    Spacer()
                    
                    // Bottom Action Bar: Share, Save, Delete
                    HStack(spacing: TAROSpacing.xl) {
                        TAROIconButton(icon: TAROIcons.share, size: 22, color: TAROColors.text) {
                            showFeedback("Share sheet will be available in the native export step.")
                        }
                        
                        TAROIconButton(icon: TAROIcons.save, size: 22, color: TAROColors.text) {
                            showFeedback("High-resolution export will be available in the native rendering step.")
                        }
                        
                        TAROIconButton(icon: TAROIcons.delete, size: 22, color: TAROColors.strongPink) {
                            showDeleteConfirmation = true
                        }
                    }
                    .padding(.bottom, TAROSpacing.xxl)
                }
                .confirmationDialog(
                    "Delete this booth?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        deleteCurrentItem()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This saved photobooth card will be removed from your local gallery.")
                }
            } else {
                ErrorStateView(message: "Photo not found") {
                    navigationPath.removeLast()
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Actions
    
    private func toggleFavorite() {
        guard let idx = itemIndex else { return }
        galleryItems[idx].isFavorite.toggle()
    }
    
    private func deleteCurrentItem() {
        guard let idx = itemIndex else { return }
        galleryItems.remove(at: idx)
        navigationPath.removeLast()
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
}

#Preview {
    GalleryDetailView(
        navigationPath: .constant(NavigationPath()),
        itemId: "1",
        galleryItems: .constant(MockData.galleryItems)
    )
}
