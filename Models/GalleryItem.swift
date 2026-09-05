import Foundation

public struct GalleryItem: Identifiable, Hashable {
    public let id: String
    public let createdAt: Date
    public let templateName: String
    public let layoutType: BoothLayoutType
    public var isFavorite: Bool
    public let photos: [BoothPhoto]
    public let editorState: BoothEditorState
    
    public init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        templateName: String = "4 Cut",
        layoutType: BoothLayoutType = .verticalFourCut,
        isFavorite: Bool = false,
        photos: [BoothPhoto] = [],
        editorState: BoothEditorState = BoothEditorState()
    ) {
        self.id = id
        self.createdAt = createdAt
        self.templateName = templateName
        self.layoutType = layoutType
        self.isFavorite = isFavorite
        self.photos = photos
        self.editorState = editorState
    }
    
    // Compatibility getter for legacy callers
    public var date: Date {
        createdAt
    }
}
