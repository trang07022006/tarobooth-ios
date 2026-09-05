import Foundation

public enum PhotoSource: String, Hashable, Codable {
    case camera
    case library
    
    public var displayName: String {
        switch self {
        case .camera:
            return "Camera"
        case .library:
            return "Library"
        }
    }
}
