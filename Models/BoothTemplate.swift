import Foundation
import SwiftUI

public enum BoothLayoutType: String, Hashable, Codable {
    case verticalFourCut = "4 Cut"
    case verticalThreeCut = "3 Cut"
    case gridTwoByTwo = "2 x 2"
    case filmStrip = "Film Strip"
}

public struct BoothTemplate: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let category: String
    public let layoutType: BoothLayoutType
    public let photoCount: Int
    
    // UI placeholder compatibility
    public let placeholderColor: Color
}

// Typealias to maintain compatibility with existing frontend code
public typealias Template = BoothTemplate
