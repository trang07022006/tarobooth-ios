import Foundation

public struct BoothSession: Identifiable {
    public let id: String
    public var selectedTemplate: BoothTemplate?
    public var sourceType: PhotoSource?
    public var photos: [BoothPhoto] = []
    public var currentShotIndex: Int = 0
    
    public var selectedFilmPreset: FilmPreset?
    public var selectedFramePreset: FramePreset?
    
    public var customText: String?
    public var selectedSticker: String? // Placeholder for a sticker identifier
    
    public let createdAt: Date
    
    public init(id: String = UUID().uuidString, createdAt: Date = Date()) {
        self.id = id
        self.createdAt = createdAt
    }
    
    // MARK: - Helpers
    
    public var requiredPhotoCount: Int {
        return selectedTemplate?.photoCount ?? 4
    }
    
    public var selectedPhotoCount: Int {
        return photos.count
    }
    
    public var isPhotoSelectionComplete: Bool {
        return selectedPhotoCount >= requiredPhotoCount
    }
    
    public var nextShotIndex: Int {
        return currentShotIndex + 1
    }
    
    public var canContinue: Bool {
        return isPhotoSelectionComplete && selectedTemplate != nil
    }
}
