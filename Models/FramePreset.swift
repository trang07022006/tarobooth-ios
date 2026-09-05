import Foundation

public struct FramePreset: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let displayName: String
    public let backgroundStyleIdentifier: String
    
    public init(id: String, name: String, displayName: String, backgroundStyleIdentifier: String) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.backgroundStyleIdentifier = backgroundStyleIdentifier
    }
}
