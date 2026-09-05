import Foundation
import SwiftUI

// MARK: - Local Mock Models

public struct GalleryItem: Identifiable, Hashable {
    public let id: String
    public let date: Date
    public let templateName: String
    public let isFavorite: Bool
}

// MARK: - Mock Data

public struct MockData {
    public static let templates: [BoothTemplate] = [
        BoothTemplate(id: "1", name: "4 Cut", category: "Classic", layoutType: .verticalFourCut, photoCount: 4, placeholderColor: TAROColors.primaryPink),
        BoothTemplate(id: "2", name: "3 Cut", category: "Cute", layoutType: .verticalThreeCut, photoCount: 3, placeholderColor: TAROColors.softBlush),
        BoothTemplate(id: "3", name: "2 x 2", category: "Classic", layoutType: .gridTwoByTwo, photoCount: 4, placeholderColor: TAROColors.strongPink),
        BoothTemplate(id: "4", name: "Film Strip", category: "Film", layoutType: .filmStrip, photoCount: 4, placeholderColor: TAROColors.cream)
    ]
    
    public static let filmPresets: [FilmPreset] = [
        FilmPreset(id: "1", name: "Original", displayName: "Original", filterIdentifier: "none"),
        FilmPreset(id: "2", name: "Cream", displayName: "Cream", filterIdentifier: "cream"),
        FilmPreset(id: "3", name: "Warm", displayName: "Warm", filterIdentifier: "warm"),
        FilmPreset(id: "4", name: "Retro", displayName: "Retro", filterIdentifier: "retro"),
        FilmPreset(id: "5", name: "Flash", displayName: "Flash", filterIdentifier: "flash"),
        FilmPreset(id: "6", name: "Mono", displayName: "Mono", filterIdentifier: "mono"),
        FilmPreset(id: "7", name: "Cool", displayName: "Cool", filterIdentifier: "cool")
    ]
    
    public static let frames: [String] = [
        "Cream", "White", "Black", "Pink", "Film"
    ]
    
    public static let framePresets: [FramePreset] = [
        FramePreset(id: "1", name: "Cream", displayName: "Cream", backgroundStyleIdentifier: "cream"),
        FramePreset(id: "2", name: "White", displayName: "White", backgroundStyleIdentifier: "white"),
        FramePreset(id: "3", name: "Black", displayName: "Black", backgroundStyleIdentifier: "black"),
        FramePreset(id: "4", name: "Pink", displayName: "Pink", backgroundStyleIdentifier: "pink"),
        FramePreset(id: "5", name: "Film", displayName: "Film", backgroundStyleIdentifier: "film")
    ]
    
    public static let galleryItems: [GalleryItem] = [
        GalleryItem(id: "1", date: Date().addingTimeInterval(-86400 * 1), templateName: "4 Cut", isFavorite: true),
        GalleryItem(id: "2", date: Date().addingTimeInterval(-86400 * 3), templateName: "Film Strip", isFavorite: false),
        GalleryItem(id: "3", date: Date().addingTimeInterval(-86400 * 5), templateName: "2 x 2", isFavorite: true),
        GalleryItem(id: "4", date: Date().addingTimeInterval(-86400 * 7), templateName: "3 Cut", isFavorite: false)
    ]
}
