import SwiftUI

struct GalleryView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var galleryItems: [GalleryItem]
    
    @State private var selectedFilter: String = "All"
    private let filters = ["All", "Favorites", "Single", "Multi"]
    
    init(
        navigationPath: Binding<NavigationPath>,
        galleryItems: Binding<[GalleryItem]> = .constant([])
    ) {
        self._navigationPath = navigationPath
        self._galleryItems = galleryItems
    }
    
    private var filteredItems: [GalleryItem] {
        switch selectedFilter {
        case "Favorites":
            return galleryItems.filter { $0.isFavorite }
        case "Single":
            return galleryItems.filter { $0.layoutType == .singlePhoto || $0.templateName == "Single Photo" }
        case "Multi":
            return galleryItems.filter { $0.layoutType != .singlePhoto && $0.templateName != "Single Photo" }
        default:
            return galleryItems
        }
    }
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Bar with Back Button and Brand Subtitle
                VStack(spacing: 2) {
                    HStack {
                        TAROIconButton(icon: TAROIcons.back) {
                            navigationPath.removeLast()
                        }
                        
                        Spacer()
                        
                        Text("Gallery")
                            .font(TAROTypography.heading2)
                            .foregroundColor(TAROColors.text)
                        
                        Spacer()
                        
                        // Balance space for center title
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, TAROSpacing.md)
                    
                    Text("Your little moments.")
                        .font(TAROTypography.caption)
                        .foregroundColor(TAROColors.text.opacity(0.55))
                        .padding(.bottom, TAROSpacing.xs)
                }
                .padding(.top, TAROSpacing.xs)
                
                // Filters Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: TAROSpacing.sm) {
                        ForEach(filters, id: \.self) { filter in
                            TAROChip(
                                title: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.vertical, TAROSpacing.sm)
                }
                
                // Content Grid or Empty State
                if filteredItems.isEmpty {
                    emptyGalleryView
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: 150, maximum: 200), spacing: TAROSpacing.md)
                            ],
                            spacing: TAROSpacing.lg
                        ) {
                            ForEach(filteredItems) { item in
                                Button(action: {
                                    navigationPath.append(AppRoute.galleryDetail(item.id))
                                }) {
                                    GalleryBoothCard(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, TAROSpacing.lg)
                        .padding(.top, TAROSpacing.xs)
                        .padding(.bottom, TAROSpacing.xxl)
                    }
                    .frame(maxWidth: 700)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Polished Empty State
    
    private var emptyGalleryView: some View {
        VStack(spacing: TAROSpacing.md) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(TAROColors.softBlush.opacity(0.35))
                    .frame(width: 88, height: 88)
                
                Image(systemName: TAROIcons.gallery)
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(TAROColors.primaryPink)
            }
            
            VStack(spacing: 4) {
                Text(selectedFilter == "Favorites" ? "No favorites yet" : "No booths yet")
                    .font(TAROTypography.heading2)
                    .foregroundColor(TAROColors.text)
                
                Text(selectedFilter == "Favorites" ? "Tap the heart on any booth to save it here." : "Create your first little moment.")
                    .font(TAROTypography.body)
                    .foregroundColor(TAROColors.text.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, TAROSpacing.xl)
            
            Button(action: {
                // Navigate cleanly to start booth creation
                navigationPath.append(AppRoute.templates)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: TAROIcons.camera)
                        .font(.system(size: 15, weight: .semibold))
                    Text("START PHOTOBOOTH")
                        .font(TAROTypography.button)
                }
                .foregroundColor(TAROColors.white)
                .padding(.horizontal, TAROSpacing.xl)
                .frame(height: 48)
                .background(TAROColors.text)
                .cornerRadius(TARORadius.pill)
                .applyTAROShadow(.soft)
            }
            .buttonStyle(.plain)
            .padding(.top, TAROSpacing.sm)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Gallery Booth Card

private struct GalleryBoothCard: View {
    let item: GalleryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: TAROSpacing.xs) {
            // Booth Canvas Preview
            ZStack(alignment: .topTrailing) {
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
                .scaleEffect(0.55)
                .frame(height: 180)
                .clipped()
                .background(TAROColors.white)
                .cornerRadius(TARORadius.md)
                .applyTAROShadow(.soft)
                
                // Favorite Heart Badge
                if item.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(TAROColors.primaryPink)
                        .padding(8)
                        .background(Color.white.opacity(0.85))
                        .clipShape(Circle())
                        .padding(6)
                        .applyTAROShadow(.soft)
                }
            }
            
            // Meta: Template & Created Date
            VStack(alignment: .leading, spacing: 2) {
                Text(item.templateName)
                    .font(TAROTypography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(TAROColors.text)
                    .lineLimit(1)
                
                Text(TARODateFormatter.shared.string(from: item.createdAt, format: .ddMMyyyy))
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(TAROColors.text.opacity(0.5))
            }
            .padding(.horizontal, 2)
        }
    }
}

#Preview {
    GalleryView(
        navigationPath: .constant(NavigationPath()),
        galleryItems: .constant(MockData.galleryItems)
    )
}
