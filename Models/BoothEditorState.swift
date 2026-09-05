import Foundation

public struct BoothEditorState: Hashable {
    public var layoutOverride: BoothLayoutType?
    public var framePresetID: String?
    public var backgroundPresetID: String?
    public var textLayers: [TextLayer]
    public var stickerLayers: [StickerLayer]
    
    public init(
        layoutOverride: BoothLayoutType? = nil,
        framePresetID: String? = nil,
        backgroundPresetID: String? = nil,
        textLayers: [TextLayer] = [],
        stickerLayers: [StickerLayer] = []
    ) {
        self.layoutOverride = layoutOverride
        self.framePresetID = framePresetID
        self.backgroundPresetID = backgroundPresetID
        self.textLayers = textLayers
        self.stickerLayers = stickerLayers
    }
}
