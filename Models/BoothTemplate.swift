import Foundation
import SwiftUI

public enum BoothLayoutType: String, Hashable, Codable {
    case singlePhoto = "Single Photo"
    case verticalFourCut = "4 Cut"
    case verticalThreeCut = "3 Cut"
    case gridTwoByTwo = "2 x 2"
    case filmStrip = "Film Strip"
    case multiCollage = "Multi Collage"
    
    public static func compatibleLayouts(for photoCount: Int) -> [BoothLayoutType] {
        switch photoCount {
        case 1:
            return [.singlePhoto]
        case 3:
            return [.verticalThreeCut]
        case 4:
            return [.verticalFourCut, .gridTwoByTwo, .filmStrip]
        case 5:
            return [.multiCollage]
        default:
            return [.verticalFourCut]
        }
    }
}

public struct BoothTemplate: Identifiable, Hashable {
    public let id: String
    public let name: String
    public var displayName: String { name }
    public let category: String
    public let layoutType: BoothLayoutType
    public let photoCount: Int
    
    // UI placeholder compatibility
    public let placeholderColor: Color
    
    public init(id: String, name: String, category: String, layoutType: BoothLayoutType, photoCount: Int, placeholderColor: Color) {
        self.id = id
        self.name = name
        self.category = category
        self.layoutType = layoutType
        self.photoCount = photoCount
        self.placeholderColor = placeholderColor
    }
}

// Typealias to maintain compatibility with existing frontend code
public typealias Template = BoothTemplate
