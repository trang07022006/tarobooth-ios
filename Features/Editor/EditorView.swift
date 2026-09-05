import SwiftUI

// MARK: - Editor Selection Type

enum EditorSelection: Hashable {
    case photo(String)
    case text(String)
    case sticker(String)
}

struct EditorView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var currentSession: BoothSession
    
    @State private var selectedTab: EditorTab = .filter
    @State private var selection: EditorSelection? = nil
    
    // Text Composer Modal State
    @State private var isTextComposerPresented = false
    @State private var composerDraft = ""
    @State private var editingLayerID: String? = nil
    
    init(
        navigationPath: Binding<NavigationPath>,
        currentSession: Binding<BoothSession> = .constant(BoothSession())
    ) {
        self._navigationPath = navigationPath
        self._currentSession = currentSession
    }
    
    private var selectedTemplate: BoothTemplate? {
        currentSession.selectedTemplate
    }
    
    private var activeLayout: BoothLayoutType {
        currentSession.editorState.layoutOverride ?? selectedTemplate?.layoutType ?? .verticalFourCut
    }
    
    private var selectedPhotoID: String? {
        if case .photo(let id) = selection {
            return id
        }
        return nil
    }
    
    private var selectedTextLayerID: String? {
        if case .text(let id) = selection {
            return id
        }
        return nil
    }
    
    private var selectedStickerLayerID: String? {
        if case .sticker(let id) = selection {
            return id
        }
        return nil
    }
    
    private var selectedPhoto: BoothPhoto? {
        guard let id = selectedPhotoID else { return currentSession.photos.first }
        return currentSession.photos.first { $0.id == id }
    }
    
    private var selectedTextLayer: TextLayer? {
        guard let id = selectedTextLayerID else { return nil }
        return currentSession.editorState.textLayers.first { $0.id == id }
    }
    
    private var selectedStickerLayer: StickerLayer? {
        guard let id = selectedStickerLayerID else { return nil }
        return currentSession.editorState.stickerLayers.first { $0.id == id }
    }
    
    var body: some View {
        ZStack {
            TAROColors.editorBackground
                .ignoresSafeArea()
            
            if currentSession.photos.isEmpty || selectedTemplate == nil {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    // Top Bar
                    topBar
                        .padding(.top, TAROSpacing.xs)
                        .padding(.horizontal, TAROSpacing.lg)
                    
                    Spacer(minLength: TAROSpacing.xs)
                    
                    // Central Interactive Photobooth Canvas Area
                    canvasArea
                        .padding(.horizontal, TAROSpacing.lg)
                    
                    Spacer(minLength: TAROSpacing.xs)
                    
                    // Tool Panel & Toolbar
                    bottomToolSection
                }
                .frame(maxWidth: 650)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if selection == nil, let firstID = currentSession.photos.first?.id {
                selection = .photo(firstID)
            }
        }
        .sheet(isPresented: $isTextComposerPresented) {
            textComposerSheet
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            // Close / X Button (POP back to existing Review)
            Button(action: {
                navigationPath.removeLast()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close Editor")
            
            Spacer()
            
            // Center Title
            VStack(spacing: 2) {
                Text("Edit Booth")
                    .font(TAROTypography.heading2)
                    .foregroundColor(.white)
                
                Text(selectedTemplate?.displayName ?? "Booth")
                    .font(TAROTypography.caption)
                    .foregroundColor(Color.white.opacity(0.6))
            }
            
            Spacer()
            
            // DONE Button (Navigates to Result)
            Button(action: {
                navigationPath.append(AppRoute.result)
            }) {
                Text("DONE")
                    .font(TAROTypography.button)
                    .foregroundColor(TAROColors.strongPink)
                    .padding(.horizontal, TAROSpacing.md)
                    .frame(height: 44)
                    .background(Color.white)
                    .cornerRadius(TARORadius.pill)
                    .applyTAROShadow(.soft)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Done Editing")
        }
    }
    
    // MARK: - Canvas Area
    
    private var canvasArea: some View {
        VStack(spacing: TAROSpacing.xs) {
            // Selection Helper Note
            selectionIndicatorBadge
            
            // Interactive Canvas Preview with 5-Layer Composition Stack
            BoothCanvasView(
                layoutType: activeLayout,
                photos: currentSession.photos,
                selectedPhotoID: selectedPhotoID,
                onSelectPhoto: { photoID in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selection = .photo(photoID)
                        selectedTab = .filter
                    }
                },
                textLayers: currentSession.editorState.textLayers,
                selectedTextLayerID: selectedTextLayerID,
                isInteractive: true,
                onSelectTextLayer: { textID in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selection = .text(textID)
                        selectedTab = .text
                    }
                },
                onUpdateTextLayer: { updatedLayer in
                    if let idx = currentSession.editorState.textLayers.firstIndex(where: { $0.id == updatedLayer.id }) {
                        currentSession.editorState.textLayers[idx] = updatedLayer
                    }
                },
                backgroundPresetID: currentSession.editorState.backgroundPresetID,
                framePresetID: currentSession.editorState.framePresetID,
                stickerLayers: currentSession.editorState.stickerLayers,
                selectedStickerLayerID: selectedStickerLayerID,
                onSelectStickerLayer: { stickerID in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selection = .sticker(stickerID)
                        selectedTab = .sticker
                    }
                },
                onUpdateStickerLayer: { updatedLayer in
                    if let idx = currentSession.editorState.stickerLayers.firstIndex(where: { $0.id == updatedLayer.id }) {
                        currentSession.editorState.stickerLayers[idx] = updatedLayer
                    }
                },
                sessionDate: currentSession.createdAt
            )
            .scaleEffect(canvasScaleForLayout(activeLayout))
            .frame(maxHeight: 390)
            .clipped()
        }
    }
    
    @ViewBuilder
    private var selectionIndicatorBadge: some View {
        if let stickerLayer = selectedStickerLayer {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(TAROColors.softBlush)
                Text("Sticker: \(stickerLayer.stickerID.capitalized)")
                    .font(TAROTypography.caption)
                    .foregroundColor(TAROColors.softBlush)
            }
            .padding(.horizontal, TAROSpacing.sm)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.1))
            .cornerRadius(TARORadius.pill)
        } else if let textLayer = selectedTextLayer {
            HStack(spacing: 4) {
                Image(systemName: "character.cursor.ibeam")
                    .font(.system(size: 10))
                    .foregroundColor(TAROColors.softBlush)
                Text("Text Layer: \"\(textLayer.text)\"")
                    .font(TAROTypography.caption)
                    .foregroundColor(TAROColors.softBlush)
                    .lineLimit(1)
            }
            .padding(.horizontal, TAROSpacing.sm)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.1))
            .cornerRadius(TARORadius.pill)
        } else if let photo = selectedPhoto {
            HStack(spacing: 4) {
                Image(systemName: "cursorarrow.click.2")
                    .font(.system(size: 10))
                    .foregroundColor(TAROColors.softBlush)
                Text("Selected: Photo \(photo.orderIndex + 1) (\(filmPresetName(for: photo.filmPresetID)))")
                    .font(TAROTypography.caption)
                    .foregroundColor(TAROColors.softBlush)
            }
            .padding(.horizontal, TAROSpacing.sm)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.1))
            .cornerRadius(TARORadius.pill)
        }
    }
    
    private func canvasScaleForLayout(_ layout: BoothLayoutType) -> CGFloat {
        switch layout {
        case .singlePhoto:
            return 0.95
        case .verticalFourCut, .filmStrip:
            return 0.88
        case .verticalThreeCut, .gridTwoByTwo:
            return 0.90
        case .multiCollage:
            return 0.85
        }
    }
    
    // MARK: - Bottom Tool Section
    
    private var bottomToolSection: some View {
        VStack(spacing: 0) {
            // Tool Content Area
            Group {
                switch selectedTab {
                case .frame:
                    frameToolPanel
                case .background:
                    backgroundToolPanel
                case .layout:
                    layoutToolPanel
                case .filter:
                    filterToolPanel
                case .text:
                    textToolPanel
                case .sticker:
                    stickerToolPanel
                }
            }
            .frame(height: 140)
            .padding(.horizontal, TAROSpacing.md)
            .padding(.top, TAROSpacing.xs)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Toolbar
            EditorToolbar(selectedTab: $selectedTab)
                .padding(.top, TAROSpacing.xs)
        }
        .background(Color(hex: "232022"))
        .clipShape(RoundedRectangle(cornerRadius: TARORadius.lg))
        .applyTAROShadow(.medium)
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Sticker Tool Panel (Step 8)
    
    private var stickerToolPanel: some View {
        let isMaxStickers = currentSession.editorState.stickerLayers.count >= 15
        let layer = selectedStickerLayer
        
        return VStack(spacing: TAROSpacing.xs) {
            HStack {
                Text("STICKERS (\(currentSession.editorState.stickerLayers.count)/15)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
                    .tracking(0.8)
                Spacer()
                if let selected = layer {
                    Button(action: {
                        deleteSelectedStickerLayer()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "trash")
                                .font(.system(size: 11))
                            Text("Delete")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(TAROColors.strongPink)
                        .padding(.horizontal, TAROSpacing.sm)
                        .frame(height: 28)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(TARORadius.pill)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TAROSpacing.xs)
            
            // Horizontal Sticker Catalog
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TAROSpacing.md) {
                    ForEach(TAROStickerCatalog.stickers) { item in
                        Button(action: {
                            addSticker(item.id)
                        }) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 46, height: 46)
                                    
                                    Image(systemName: item.symbolName)
                                        .font(.system(size: 22))
                                        .foregroundColor(item.defaultTint)
                                }
                                
                                Text(item.name)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(isMaxStickers)
                    }
                }
                .padding(.horizontal, TAROSpacing.xs)
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Frame Tool Panel (Step 8)
    
    private var frameToolPanel: some View {
        VStack(spacing: TAROSpacing.xs) {
            HStack {
                Text("FRAME PRESETS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
                    .tracking(0.8)
                Spacer()
                let currentFrameName = TAROFrameCatalog.item(for: currentSession.editorState.framePresetID).name
                Text("Active: \(currentFrameName)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(TAROColors.softBlush)
            }
            .padding(.horizontal, TAROSpacing.xs)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TAROSpacing.md) {
                    ForEach(TAROFrameCatalog.frames) { frame in
                        let activeFrame = TAROFrameCatalog.item(for: currentSession.editorState.framePresetID)
                        let isSelected = activeFrame.id == frame.id
                        
                        Button(action: {
                            currentSession.editorState.framePresetID = frame.id
                        }) {
                            VStack(spacing: 4) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: TARORadius.sm)
                                        .fill(frame.id == "none" ? Color.clear : (frame.frameColor == Color.clear ? Color.white.opacity(0.1) : frame.frameColor))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: TARORadius.sm)
                                                .stroke(isSelected ? TAROColors.strongPink : Color.white.opacity(0.2), lineWidth: isSelected ? 2.5 : 1)
                                        )
                                    
                                    if frame.style == .polaroid {
                                        VStack {
                                            Spacer()
                                            Rectangle()
                                                .fill(Color.black.opacity(0.2))
                                                .frame(height: 8)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: TARORadius.sm))
                                    } else if frame.style == .film {
                                        Image(systemName: "film")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    } else if frame.id == "none" {
                                        Image(systemName: "slash.circle")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.white.opacity(0.5))
                                    }
                                }
                                
                                Text(frame.name)
                                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? TAROColors.softBlush : Color.white.opacity(0.7))
                            }
                            .frame(width: 54)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, TAROSpacing.xs)
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Background Tool Panel (Step 8)
    
    private var backgroundToolPanel: some View {
        VStack(spacing: TAROSpacing.xs) {
            HStack {
                Text("CANVAS BACKGROUND")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
                    .tracking(0.8)
                Spacer()
                let currentBg = currentSession.editorState.backgroundPresetID ?? "cream"
                Text("Active: \(currentBg.capitalized)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(TAROColors.softBlush)
            }
            .padding(.horizontal, TAROSpacing.xs)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TAROSpacing.md) {
                    ForEach(TAROBackgroundCatalog.backgrounds) { bg in
                        let activeID = currentSession.editorState.backgroundPresetID ?? "cream"
                        let isSelected = activeID.lowercased() == bg.id.lowercased()
                        
                        Button(action: {
                            currentSession.editorState.backgroundPresetID = bg.id
                        }) {
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(bg.color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(isSelected ? TAROColors.strongPink : Color.white.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                                    )
                                    .overlay(
                                        Group {
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(bg.id == "white" || bg.id == "cream" || bg.id == "blush" ? TAROColors.text : .white)
                                            }
                                        }
                                    )
                                
                                Text(bg.name)
                                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? TAROColors.softBlush : Color.white.opacity(0.7))
                            }
                            .frame(width: 56)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, TAROSpacing.xs)
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Layout Tool Panel (Step 8)
    
    private var layoutToolPanel: some View {
        let photoCount = currentSession.photos.count
        let compatibleLayouts = BoothLayoutType.compatibleLayouts(for: photoCount)
        
        return VStack(spacing: TAROSpacing.xs) {
            HStack {
                Text("COMPATIBLE LAYOUTS (\(photoCount) PHOTOS)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
                    .tracking(0.8)
                Spacer()
                Text("Active: \(activeLayout.rawValue)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(TAROColors.softBlush)
            }
            .padding(.horizontal, TAROSpacing.xs)
            
            HStack(spacing: TAROSpacing.md) {
                ForEach(compatibleLayouts, id: \.self) { layout in
                    let isSelected = activeLayout == layout
                    
                    Button(action: {
                        currentSession.editorState.layoutOverride = layout
                    }) {
                        VStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: TARORadius.sm)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 68, height: 46)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: TARORadius.sm)
                                            .stroke(isSelected ? TAROColors.strongPink : Color.white.opacity(0.2), lineWidth: isSelected ? 2.5 : 1)
                                    )
                                
                                Image(systemName: "rectangle.3.group")
                                    .font(.system(size: 16))
                                    .foregroundColor(isSelected ? TAROColors.softBlush : Color.white.opacity(0.6))
                            }
                            
                            Text(layout.rawValue)
                                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? TAROColors.softBlush : Color.white.opacity(0.7))
                        }
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, TAROSpacing.xs)
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Text Tool Panel (Step 7)
    
    private var textToolPanel: some View {
        let isMaxLayers = currentSession.editorState.textLayers.count >= 10
        let layer = selectedTextLayer
        
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: TAROSpacing.xs) {
                // Action Header: ADD TEXT / EDIT / DELETE
                HStack(spacing: TAROSpacing.sm) {
                    Button(action: {
                        composerDraft = ""
                        editingLayerID = nil
                        isTextComposerPresented = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                            Text(isMaxLayers ? "LIMIT (10)" : "ADD TEXT")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, TAROSpacing.sm)
                        .frame(height: 32)
                        .background(isMaxLayers ? Color.gray.opacity(0.4) : TAROColors.strongPink)
                        .cornerRadius(TARORadius.pill)
                    }
                    .buttonStyle(.plain)
                    .disabled(isMaxLayers)
                    
                    if let selected = layer {
                        Button(action: {
                            composerDraft = selected.text
                            editingLayerID = selected.id
                            isTextComposerPresented = true
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 11))
                                Text("Edit")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, TAROSpacing.sm)
                            .frame(height: 32)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(TARORadius.pill)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            deleteSelectedTextLayer()
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "trash")
                                    .font(.system(size: 11))
                                Text("Delete")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(TAROColors.strongPink)
                            .padding(.horizontal, TAROSpacing.sm)
                            .frame(height: 32)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(TARORadius.pill)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                }
                
                // Detailed Text Controls (when a layer is selected)
                if let selected = layer {
                    // Row 1: Font Style Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: TAROSpacing.xs) {
                            ForEach(TAROFontStyle.allCases, id: \.self) { font in
                                let isFontSelected = selected.fontStyle == font
                                Button(action: {
                                    updateSelectedTextLayer { $0.fontStyle = font }
                                }) {
                                    Text(font.displayName)
                                        .font(.system(size: 11, weight: isFontSelected ? .bold : .medium))
                                        .foregroundColor(isFontSelected ? TAROColors.softBlush : Color.white.opacity(0.7))
                                        .padding(.horizontal, 8)
                                        .frame(height: 26)
                                        .background(isFontSelected ? TAROColors.strongPink.opacity(0.4) : Color.white.opacity(0.08))
                                        .cornerRadius(TARORadius.sm)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Row 2: Color Palette Swatches & Align / Style
                    HStack(spacing: TAROSpacing.md) {
                        // Color Swatches
                        HStack(spacing: 6) {
                            ForEach(TAROTextColorPalette.palette) { item in
                                let isColorSelected = selected.colorID == item.id
                                Button(action: {
                                    updateSelectedTextLayer { $0.colorID = item.id }
                                }) {
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Circle()
                                                .stroke(isColorSelected ? TAROColors.strongPink : Color.white.opacity(0.3), lineWidth: isColorSelected ? 2.5 : 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Spacer()
                        
                        // Alignment toggles
                        HStack(spacing: 4) {
                            ForEach(TAROTextAlignment.allCases, id: \.self) { align in
                                let isAlign = selected.alignment == align
                                Button(action: {
                                    updateSelectedTextLayer { $0.alignment = align }
                                }) {
                                    Image(systemName: alignIcon(for: align))
                                        .font(.system(size: 12))
                                        .foregroundColor(isAlign ? TAROColors.softBlush : Color.white.opacity(0.5))
                                        .frame(width: 24, height: 24)
                                        .background(isAlign ? TAROColors.strongPink.opacity(0.4) : Color.white.opacity(0.08))
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        // Style toggles (Normal, Shadow, Outline)
                        HStack(spacing: 4) {
                            ForEach(TAROTextStyle.allCases, id: \.self) { style in
                                let isStyle = selected.style == style
                                Button(action: {
                                    updateSelectedTextLayer { $0.style = style }
                                }) {
                                    Text(style.displayName.prefix(1))
                                        .font(.system(size: 10, weight: isStyle ? .bold : .medium))
                                        .foregroundColor(isStyle ? TAROColors.softBlush : Color.white.opacity(0.5))
                                        .frame(width: 24, height: 24)
                                        .background(isStyle ? TAROColors.strongPink.opacity(0.4) : Color.white.opacity(0.08))
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                } else {
                    Text("Select a text layer on canvas to edit font, color & style.")
                        .font(TAROTypography.caption)
                        .foregroundColor(Color.white.opacity(0.45))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, TAROSpacing.xs)
        }
    }
    
    // MARK: - Filter Tool Panel (Per-Photo Film Editing)
    
    private var filterToolPanel: some View {
        VStack(spacing: TAROSpacing.xs) {
            HStack {
                Text("FILM PRESETS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
                    .tracking(0.8)
                Spacer()
                if let photo = selectedPhoto {
                    Text("Editing Photo \(photo.orderIndex + 1)")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(TAROColors.softBlush)
                } else {
                    Text("Select a photo above")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            .padding(.horizontal, TAROSpacing.xs)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TAROSpacing.sm) {
                    ForEach(MockData.filmPresets) { preset in
                        let isSelected = selectedPhoto?.filmPresetID == preset.id || (selectedPhoto?.filmPresetID == nil && preset.id == "original")
                        
                        Button(action: {
                            applyFilmPreset(preset.id)
                        }) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(filmSwatchGradient(for: preset.id))
                                        .frame(width: 44, height: 44)
                                    
                                    if isSelected {
                                        Circle()
                                            .stroke(TAROColors.strongPink, lineWidth: 2.5)
                                            .frame(width: 48, height: 48)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(preset.id == "cream" ? TAROColors.text : .white)
                                    }
                                }
                                
                                Text(preset.displayName)
                                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? TAROColors.softBlush : Color.white.opacity(0.7))
                            }
                            .frame(width: 58)
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedPhotoID == nil)
                    }
                }
                .padding(.horizontal, TAROSpacing.xs)
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Text Composer Sheet
    
    private var textComposerSheet: some View {
        NavigationStack {
            ZStack {
                TAROColors.editorBackground
                    .ignoresSafeArea()
                
                VStack(spacing: TAROSpacing.lg) {
                    TextField("Enter your text...", text: $composerDraft)
                        .font(TAROTypography.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(TARORadius.md)
                    
                    // Quick Date Preset Button
                    Button(action: {
                        composerDraft = formattedTodayDate()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text("Insert Today's Date (\(formattedTodayDate()))")
                                .font(TAROTypography.caption)
                        }
                        .foregroundColor(TAROColors.softBlush)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(TAROSpacing.lg)
            }
            .navigationTitle(editingLayerID == nil ? "Add text" : "Edit text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isTextComposerPresented = false
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingLayerID == nil ? "Add" : "Save") {
                        saveTextComposer()
                    }
                    .font(TAROTypography.button)
                    .foregroundColor(composerDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : TAROColors.strongPink)
                    .disabled(composerDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.fraction(0.38)])
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: TAROSpacing.lg) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 56, weight: .light))
                .foregroundColor(Color.white.opacity(0.4))
            
            VStack(spacing: TAROSpacing.xs) {
                Text("Nothing to edit yet.")
                    .font(TAROTypography.heading1)
                    .foregroundColor(.white)
                
                Text("Please choose a template and photos to edit your booth.")
                    .font(TAROTypography.body)
                    .foregroundColor(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, TAROSpacing.xl)
            
            Button(action: {
                navigationPath.removeLast()
            }) {
                Text("BACK TO REVIEW")
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
    
    // MARK: - Actions & Helpers
    
    private func addSticker(_ stickerID: String) {
        guard currentSession.editorState.stickerLayers.count < 15 else { return }
        let newLayer = StickerLayer(stickerID: stickerID, positionX: 0.5, positionY: 0.5)
        currentSession.editorState.stickerLayers.append(newLayer)
        selection = .sticker(newLayer.id)
    }
    
    private func deleteSelectedStickerLayer() {
        guard let id = selectedStickerLayerID else { return }
        currentSession.editorState.stickerLayers.removeAll { $0.id == id }
        selection = nil
    }
    
    private func saveTextComposer() {
        let trimmed = composerDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if let editID = editingLayerID,
           let idx = currentSession.editorState.textLayers.firstIndex(where: { $0.id == editID }) {
            // Edit existing layer in place
            currentSession.editorState.textLayers[idx].text = trimmed
        } else {
            // Add new layer
            guard currentSession.editorState.textLayers.count < 10 else { return }
            let newLayer = TextLayer(
                text: trimmed,
                fontStyle: .rounded,
                colorID: "white",
                positionX: 0.5,
                positionY: 0.5
            )
            currentSession.editorState.textLayers.append(newLayer)
            selection = .text(newLayer.id)
            selectedTab = .text
        }
        isTextComposerPresented = false
    }
    
    private func deleteSelectedTextLayer() {
        guard let id = selectedTextLayerID else { return }
        currentSession.editorState.textLayers.removeAll { $0.id == id }
        selection = nil
    }
    
    private func updateSelectedTextLayer(_ transform: (inout TextLayer) -> Void) {
        guard let id = selectedTextLayerID,
              let idx = currentSession.editorState.textLayers.firstIndex(where: { $0.id == id }) else { return }
        transform(&currentSession.editorState.textLayers[idx])
    }
    
    private func applyFilmPreset(_ presetID: String) {
        guard let id = selectedPhotoID,
              let targetIdx = currentSession.photos.firstIndex(where: { $0.id == id }) else { return }
        currentSession.photos[targetIdx].filmPresetID = presetID
    }
    
    private func alignIcon(for alignment: TAROTextAlignment) -> String {
        switch alignment {
        case .left: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .right: return "text.alignright"
        }
    }
    
    private func filmPresetName(for presetID: String?) -> String {
        let id = presetID ?? "original"
        return MockData.filmPresets.first(where: { $0.id == id })?.displayName ?? "Original"
    }
    
    private func formattedTodayDate() -> String {
        TARODateFormatter.shared.string(from: currentSession.createdAt, format: .ddMMyyyy)
    }
    
    private func filmSwatchGradient(for presetID: String) -> LinearGradient {
        switch presetID.lowercased() {
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
    session.editorState.textLayers = [
        TextLayer(text: "TAROBOOTH", fontStyle: .rounded, colorID: "pink", positionX: 0.5, positionY: 0.15)
    ]
    session.editorState.stickerLayers = [
        StickerLayer(stickerID: "heart", positionX: 0.5, positionY: 0.8)
    ]
    
    return EditorView(
        navigationPath: .constant(NavigationPath()),
        currentSession: .constant(session)
    )
}
