import SwiftUI

public struct BoothCanvasView: View {
    public let layoutType: BoothLayoutType
    public let frameColor: Color
    public let photos: [BoothPhoto]
    public let selectedPhotoID: String?
    public let onSelectPhoto: ((String) -> Void)?
    
    // Step 7: Text Layers & Interactivity
    public let textLayers: [TextLayer]
    public let selectedTextLayerID: String?
    public let isInteractive: Bool
    public let onSelectTextLayer: ((String) -> Void)?
    public let onUpdateTextLayer: ((TextLayer) -> Void)?
    
    // Step 8: Stickers, Frame & Background
    public let backgroundPresetID: String?
    public let framePresetID: String?
    public let stickerLayers: [StickerLayer]
    public let selectedStickerLayerID: String?
    public let onSelectStickerLayer: ((String) -> Void)?
    public let onUpdateStickerLayer: ((StickerLayer) -> Void)?
    public let sessionDate: Date?
    
    // Config
    let cornerRadius: CGFloat = 8
    
    public init(
        layoutType: BoothLayoutType,
        frameColor: Color = TAROColors.cream,
        photos: [BoothPhoto] = [],
        selectedPhotoID: String? = nil,
        onSelectPhoto: ((String) -> Void)? = nil,
        textLayers: [TextLayer] = [],
        selectedTextLayerID: String? = nil,
        isInteractive: Bool = true,
        onSelectTextLayer: ((String) -> Void)? = nil,
        onUpdateTextLayer: ((TextLayer) -> Void)? = nil,
        backgroundPresetID: String? = nil,
        framePresetID: String? = nil,
        stickerLayers: [StickerLayer] = [],
        selectedStickerLayerID: String? = nil,
        onSelectStickerLayer: ((String) -> Void)? = nil,
        onUpdateStickerLayer: ((StickerLayer) -> Void)? = nil,
        sessionDate: Date? = nil
    ) {
        self.layoutType = layoutType
        self.frameColor = frameColor
        self.photos = photos
        self.selectedPhotoID = selectedPhotoID
        self.onSelectPhoto = onSelectPhoto
        self.textLayers = textLayers
        self.selectedTextLayerID = selectedTextLayerID
        self.isInteractive = isInteractive
        self.onSelectTextLayer = onSelectTextLayer
        self.onUpdateTextLayer = onUpdateTextLayer
        self.backgroundPresetID = backgroundPresetID
        self.framePresetID = framePresetID
        self.stickerLayers = stickerLayers
        self.selectedStickerLayerID = selectedStickerLayerID
        self.onSelectStickerLayer = onSelectStickerLayer
        self.onUpdateStickerLayer = onUpdateStickerLayer
        self.sessionDate = sessionDate
    }
    
    // Compatibility initializer for views passing templateName
    public init(templateName: String, frameColor: Color = TAROColors.cream) {
        let resolvedType = BoothLayoutType(rawValue: templateName) ?? .verticalFourCut
        self.init(layoutType: resolvedType, frameColor: frameColor)
    }
    
    private var resolvedBackgroundColor: Color {
        if let bgID = backgroundPresetID {
            return TAROBackgroundCatalog.color(for: bgID)
        }
        return frameColor
    }
    
    private var frameItem: TAROFrameItem {
        TAROFrameCatalog.item(for: framePresetID)
    }
    
    public var body: some View {
        ZStack {
            // Layer 1: Background Canvas Layer
            resolvedBackgroundColor
            
            // Layer 2: Photo Slots Grid & Inner Frame
            VStack(spacing: TAROSpacing.sm) {
                // Top film perforations if film style
                if frameItem.style == .film {
                    filmPerforationsRow
                }
                
                photoSlotsGrid
                    .padding(frameItem.style == .polaroid ? TAROSpacing.xs : 0)
                
                // Bottom film perforations if film style
                if frameItem.style == .film {
                    filmPerforationsRow
                }
                
                // Layer 3: Frame / Polaroid Space & Branding Footer
                brandingFooter
                    .padding(.top, frameItem.style == .polaroid ? TAROSpacing.md : TAROSpacing.xs)
            }
            .padding(frameItem.style == .polaroid ? TAROSpacing.lg : TAROSpacing.md)
            
            // Layer 3 Frame Border
            if frameItem.borderWidth > 0 && frameItem.id != "none" {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(frameItem.frameColor, lineWidth: frameItem.borderWidth)
            }
            
            // Layer 4: Text Layers Overlay
            if !textLayers.isEmpty {
                textLayersOverlay
            }
            
            // Layer 5: Sticker Layers Overlay
            if !stickerLayers.isEmpty {
                stickerLayersOverlay
            }
        }
        .cornerRadius(TARORadius.lg)
        .clipped()
        .applyTAROShadow(.medium)
    }
    
    // MARK: - Layer 5: Sticker Layers Overlay
    
    private var stickerLayersOverlay: some View {
        GeometryReader { geo in
            let canvasSize = geo.size
            ForEach(stickerLayers) { layer in
                let isSelected = isInteractive && (layer.id == selectedStickerLayerID)
                
                StickerLayerItemView(
                    layer: layer,
                    canvasSize: canvasSize,
                    isSelected: isSelected,
                    isInteractive: isInteractive,
                    onSelect: { onSelectStickerLayer?(layer.id) },
                    onUpdate: { updated in onUpdateStickerLayer?(updated) }
                )
            }
        }
    }
    
    // MARK: - Layer 4: Text Layers Overlay
    
    private var textLayersOverlay: some View {
        GeometryReader { geo in
            let canvasSize = geo.size
            ForEach(textLayers) { layer in
                let isSelected = isInteractive && (layer.id == selectedTextLayerID)
                
                TextLayerItemView(
                    layer: layer,
                    canvasSize: canvasSize,
                    isSelected: isSelected,
                    isInteractive: isInteractive,
                    onSelect: { onSelectTextLayer?(layer.id) },
                    onUpdate: { updated in onUpdateTextLayer?(updated) }
                )
            }
        }
    }
    
    // MARK: - Layer 2: Photo Slots Grid
    
    @ViewBuilder
    private var photoSlotsGrid: some View {
        switch layoutType {
        case .singlePhoto:
            photoSlotView(index: 0, aspectRatio: 4/5)
            
        case .verticalFourCut:
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TAROSpacing.sm) {
                ForEach(0..<4, id: \.self) { idx in
                    photoSlotView(index: idx, aspectRatio: 3/4)
                }
            }
            
        case .verticalThreeCut:
            VStack(spacing: TAROSpacing.sm) {
                ForEach(0..<3, id: \.self) { idx in
                    photoSlotView(index: idx, aspectRatio: 4/3)
                }
            }
            
        case .gridTwoByTwo:
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TAROSpacing.sm) {
                ForEach(0..<4, id: \.self) { idx in
                    photoSlotView(index: idx, aspectRatio: 1.0)
                }
            }
            
        case .filmStrip:
            VStack(spacing: TAROSpacing.sm) {
                ForEach(0..<4, id: \.self) { idx in
                    photoSlotView(index: idx, aspectRatio: 3/2)
                }
            }
            
        case .multiCollage:
            VStack(spacing: TAROSpacing.xs) {
                photoSlotView(index: 0, aspectRatio: 16/9)
                HStack(spacing: TAROSpacing.xs) {
                    photoSlotView(index: 1, aspectRatio: 1.0)
                    photoSlotView(index: 2, aspectRatio: 1.0)
                }
                HStack(spacing: TAROSpacing.xs) {
                    photoSlotView(index: 3, aspectRatio: 1.0)
                    photoSlotView(index: 4, aspectRatio: 1.0)
                }
            }
        }
    }
    
    // MARK: - Individual Photo Slot
    
    @ViewBuilder
    private func photoSlotView(index: Int, aspectRatio: CGFloat) -> some View {
        if index < photos.count {
            let photo = photos[index]
            let isSelected = photo.id == selectedPhotoID
            
            ZStack(alignment: .topTrailing) {
                // Base Slot surface
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(hex: "232022"))
                
                // Photo Content Pipeline: Real Image or Mock Fallback
                TAROPhotoSurfaceView(photo: photo)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                
                // Selection Indicator: Distinct outline + checkmark badge
                if isSelected {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(TAROColors.strongPink, lineWidth: 3)
                    
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(TAROColors.strongPink)
                            .background(Circle().fill(Color.white))
                            .padding(4)
                    }
                }
            }
            .aspectRatio(aspectRatio, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(Rectangle())
            .onTapGesture {
                onSelectPhoto?(photo.id)
            }
        } else {
            // Unfilled slot placeholder
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(TAROColors.cameraBackground.opacity(0.8))
                .aspectRatio(aspectRatio, contentMode: .fit)
                .overlay(
                    Text("Slot \(index + 1)")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.3))
                )
        }
    }
    
    // MARK: - Stable Mock Photo Surface
    
    private func mockPhotoSurface(for photo: BoothPhoto) -> some View {
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
    }
    
    // MARK: - Layer 3: Frame Decorations & Branding Footer
    
    private var filmPerforationsRow: some View {
        HStack(spacing: 6) {
            ForEach(0..<8, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 8, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var brandingTextColor: Color {
        let bgID = backgroundPresetID?.lowercased() ?? ""
        if bgID == "black" || bgID == "charcoal" {
            return Color.white
        }
        return TAROColors.text
    }
    
    private var brandingFooter: some View {
        HStack {
            Text("TAROBOOTH")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(brandingTextColor)
            Spacer()
            Text(formattedSessionDate)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(brandingTextColor.opacity(0.7))
        }
        .padding(.top, TAROSpacing.xs)
        .padding(.horizontal, TAROSpacing.xs)
    }
    
    private var formattedSessionDate: String {
        let date = sessionDate ?? Date()
        return TARODateFormatter.shared.string(from: date, format: .yyyyMMdd)
    }
}

// MARK: - Interactive Sticker Layer Item View

private struct StickerLayerItemView: View {
    let layer: StickerLayer
    let canvasSize: CGSize
    let isSelected: Bool
    let isInteractive: Bool
    let onSelect: () -> Void
    let onUpdate: (StickerLayer) -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var currentMagnification: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    
    var body: some View {
        let posX = (layer.positionX * canvasSize.width) + dragOffset.width
        let posY = (layer.positionY * canvasSize.height) + dragOffset.height
        let totalScale = layer.scale * Double(currentMagnification)
        let totalRotation = layer.rotationDegrees + currentRotation.degrees
        let symbol = TAROStickerCatalog.symbol(for: layer.stickerID)
        let tint = TAROStickerCatalog.tint(for: layer.stickerID)
        
        ZStack {
            Image(systemName: symbol)
                .font(.system(size: 36, weight: .medium))
                .foregroundColor(tint)
                .applyTAROShadow(.soft)
                .padding(6)
                .overlay(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                .foregroundColor(TAROColors.strongPink)
                        }
                    }
                )
        }
        .scaleEffect(totalScale)
        .rotationEffect(.degrees(totalRotation))
        .position(x: posX, y: posY)
        .contentShape(Rectangle())
        .onTapGesture {
            if isInteractive {
                onSelect()
            }
        }
        .simultaneousGesture(
            isInteractive && isSelected ?
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let deltaX = Double(value.translation.width / canvasSize.width)
                    let deltaY = Double(value.translation.height / canvasSize.height)
                    dragOffset = .zero
                    var updated = layer
                    updated.positionX += deltaX
                    updated.positionY += deltaY
                    onUpdate(updated)
                } : nil
        )
        .simultaneousGesture(
            isInteractive && isSelected ?
            MagnificationGesture()
                .onChanged { mag in
                    currentMagnification = mag
                }
                .onEnded { mag in
                    var updated = layer
                    updated.scale = layer.scale * Double(mag)
                    currentMagnification = 1.0
                    onUpdate(updated)
                } : nil
        )
        .simultaneousGesture(
            isInteractive && isSelected ?
            RotationGesture()
                .onChanged { angle in
                    currentRotation = angle
                }
                .onEnded { angle in
                    var updated = layer
                    updated.rotationDegrees += angle.degrees
                    currentRotation = .zero
                    onUpdate(updated)
                } : nil
        )
    }
}

// MARK: - Interactive Text Layer Item View

private struct TextLayerItemView: View {
    let layer: TextLayer
    let canvasSize: CGSize
    let isSelected: Bool
    let isInteractive: Bool
    let onSelect: () -> Void
    let onUpdate: (TextLayer) -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var currentMagnification: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    
    var body: some View {
        let posX = (layer.positionX * canvasSize.width) + dragOffset.width
        let posY = (layer.positionY * canvasSize.height) + dragOffset.height
        let totalScale = layer.scale * Double(currentMagnification)
        let totalRotation = layer.rotationDegrees + currentRotation.degrees
        let textColor = TAROTextColorPalette.color(for: layer.colorID)
        
        ZStack {
            Text(layer.text)
                .font(layer.fontStyle.font(baseSize: 20))
                .foregroundColor(textColor)
                .multilineTextAlignment(layer.alignment.textAlignment)
                .modifier(TextStyleModifier(style: layer.style, textColor: textColor))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                .foregroundColor(TAROColors.strongPink)
                        }
                    }
                )
        }
        .scaleEffect(totalScale)
        .rotationEffect(.degrees(totalRotation))
        .position(x: posX, y: posY)
        .contentShape(Rectangle())
        .onTapGesture {
            if isInteractive {
                onSelect()
            }
        }
        .simultaneousGesture(
            isInteractive && isSelected ?
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let deltaX = Double(value.translation.width / canvasSize.width)
                    let deltaY = Double(value.translation.height / canvasSize.height)
                    dragOffset = .zero
                    var updated = layer
                    updated.positionX += deltaX
                    updated.positionY += deltaY
                    onUpdate(updated)
                } : nil
        )
        .simultaneousGesture(
            isInteractive && isSelected ?
            MagnificationGesture()
                .onChanged { mag in
                    currentMagnification = mag
                }
                .onEnded { mag in
                    var updated = layer
                    updated.scale = layer.scale * Double(mag)
                    currentMagnification = 1.0
                    onUpdate(updated)
                } : nil
        )
        .simultaneousGesture(
            isInteractive && isSelected ?
            RotationGesture()
                .onChanged { angle in
                    currentRotation = angle
                }
                .onEnded { angle in
                    var updated = layer
                    updated.rotationDegrees += angle.degrees
                    currentRotation = .zero
                    onUpdate(updated)
                } : nil
        )
    }
}

// MARK: - Text Style Modifier

private struct TextStyleModifier: ViewModifier {
    let style: TAROTextStyle
    let textColor: Color
    
    func body(content: Content) -> some View {
        switch style {
        case .normal:
            content
        case .shadow:
            content
                .shadow(color: Color.black.opacity(0.5), radius: 2, x: 1.5, y: 1.5)
        case .outline:
            content
                .shadow(color: textColor == .white ? Color.black : Color.white, radius: 1, x: 1, y: 0)
                .shadow(color: textColor == .white ? Color.black : Color.white, radius: 1, x: -1, y: 0)
                .shadow(color: textColor == .white ? Color.black : Color.white, radius: 1, x: 0, y: 1)
                .shadow(color: textColor == .white ? Color.black : Color.white, radius: 1, x: 0, y: -1)
        }
    }
}

#Preview {
    ZStack {
        TAROColors.background.ignoresSafeArea()
        BoothCanvasView(
            layoutType: .verticalFourCut,
            frameColor: TAROColors.softBlush,
            photos: [
                BoothPhoto(id: "1", source: .camera, localIdentifier: "cam_1", orderIndex: 0, filmPresetID: "cream"),
                BoothPhoto(id: "2", source: .library, localIdentifier: "mock-library-2", orderIndex: 1, filmPresetID: "warm")
            ],
            selectedPhotoID: "1",
            textLayers: [
                TextLayer(text: "TAROBOOTH", fontStyle: .rounded, colorID: "white", positionX: 0.5, positionY: 0.2)
            ],
            selectedTextLayerID: nil,
            backgroundPresetID: "cream",
            framePresetID: "polaroid",
            stickerLayers: [
                StickerLayer(stickerID: "heart", positionX: 0.5, positionY: 0.8)
            ]
        )
        .padding(40)
    }
}
