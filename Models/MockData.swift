import Foundation
import SwiftUI

// MARK: - Mock Data

public struct MockData {
    public static let templates: [BoothTemplate] = [
        BoothTemplate(id: "1", name: "Single Photo", category: "Classic", layoutType: .singlePhoto, photoCount: 1, placeholderColor: TAROColors.cream),
        BoothTemplate(id: "2", name: "4 Cut", category: "Classic", layoutType: .verticalFourCut, photoCount: 4, placeholderColor: TAROColors.primaryPink),
        BoothTemplate(id: "3", name: "3 Cut", category: "Cute", layoutType: .verticalThreeCut, photoCount: 3, placeholderColor: TAROColors.softBlush),
        BoothTemplate(id: "4", name: "2 x 2", category: "Classic", layoutType: .gridTwoByTwo, photoCount: 4, placeholderColor: TAROColors.strongPink),
        BoothTemplate(id: "5", name: "Film Strip", category: "Film", layoutType: .filmStrip, photoCount: 4, placeholderColor: TAROColors.cream),
        BoothTemplate(id: "6", name: "Multi Collage", category: "Creative", layoutType: .multiCollage, photoCount: 5, placeholderColor: TAROColors.softBlush)
    ]
    
    public static let filmPresets: [FilmPreset] = [
        FilmPreset(id: "original", name: "Original", displayName: "Original", filterIdentifier: "none"),
        FilmPreset(id: "cream", name: "Cream", displayName: "Cream", filterIdentifier: "cream"),
        FilmPreset(id: "warm", name: "Warm", displayName: "Warm", filterIdentifier: "warm"),
        FilmPreset(id: "vintage", name: "Vintage", displayName: "Vintage", filterIdentifier: "vintage"),
        FilmPreset(id: "retro", name: "Retro", displayName: "Retro", filterIdentifier: "retro"),
        FilmPreset(id: "disposable", name: "Disposable", displayName: "Disposable", filterIdentifier: "disposable"),
        FilmPreset(id: "mono", name: "Mono", displayName: "Mono", filterIdentifier: "mono"),
        FilmPreset(id: "cool", name: "Cool", displayName: "Cool", filterIdentifier: "cool")
    ]
    
    public static let frames: [String] = [
        "Cream", "White", "Black", "Pink", "Film"
    ]
    
    public static let framePresets: [FramePreset] = [
        FramePreset(id: "none", name: "None", displayName: "None", backgroundStyleIdentifier: "none"),
        FramePreset(id: "cream", name: "Cream", displayName: "Cream", backgroundStyleIdentifier: "cream"),
        FramePreset(id: "white", name: "White", displayName: "White", backgroundStyleIdentifier: "white"),
        FramePreset(id: "pink", name: "Pink", displayName: "Pink", backgroundStyleIdentifier: "pink"),
        FramePreset(id: "black", name: "Black", displayName: "Black", backgroundStyleIdentifier: "black"),
        FramePreset(id: "polaroid", name: "Polaroid", displayName: "Polaroid", backgroundStyleIdentifier: "polaroid"),
        FramePreset(id: "film", name: "Film", displayName: "Film", backgroundStyleIdentifier: "film")
    ]
    
    private static func mockSamplePhotos(count: Int, prefix: String, filmPreset: String) -> [BoothPhoto] {
        (0..<count).map { idx in
            BoothPhoto(
                id: "\(prefix)_\(idx + 1)",
                source: .camera,
                localIdentifier: "\(prefix)_\(idx + 1)",
                orderIndex: idx,
                filmPresetID: filmPreset
            )
        }
    }
    
    public static let galleryItems: [GalleryItem] = [
        GalleryItem(
            id: "1",
            createdAt: Date().addingTimeInterval(-86400 * 1),
            templateName: "4 Cut",
            layoutType: .verticalFourCut,
            isFavorite: true,
            photos: mockSamplePhotos(count: 4, prefix: "gal_1", filmPreset: "warm"),
            editorState: BoothEditorState(
                layoutOverride: .verticalFourCut,
                framePresetID: "cream",
                backgroundPresetID: "cream",
                textLayers: [TextLayer(text: "TAROBOOTH", fontStyle: .rounded, colorID: "pink", positionX: 0.5, positionY: 0.15)]
            )
        ),
        GalleryItem(
            id: "2",
            createdAt: Date().addingTimeInterval(-86400 * 3),
            templateName: "Film Strip",
            layoutType: .filmStrip,
            isFavorite: false,
            photos: mockSamplePhotos(count: 4, prefix: "gal_2", filmPreset: "vintage"),
            editorState: BoothEditorState(
                layoutOverride: .filmStrip,
                framePresetID: "film",
                backgroundPresetID: "black"
            )
        ),
        GalleryItem(
            id: "3",
            createdAt: Date().addingTimeInterval(-86400 * 5),
            templateName: "2 x 2",
            layoutType: .gridTwoByTwo,
            isFavorite: true,
            photos: mockSamplePhotos(count: 4, prefix: "gal_3", filmPreset: "mono"),
            editorState: BoothEditorState(
                layoutOverride: .gridTwoByTwo,
                framePresetID: "white",
                backgroundPresetID: "blush"
            )
        ),
        GalleryItem(
            id: "4",
            createdAt: Date().addingTimeInterval(-86400 * 7),
            templateName: "3 Cut",
            layoutType: .verticalThreeCut,
            isFavorite: false,
            photos: mockSamplePhotos(count: 3, prefix: "gal_4", filmPreset: "cream"),
            editorState: BoothEditorState(
                layoutOverride: .verticalThreeCut,
                framePresetID: "polaroid",
                backgroundPresetID: "warmGray"
            )
        )
    ]
}
