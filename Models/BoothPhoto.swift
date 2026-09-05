import Foundation

/// Lightweight abstraction for a captured or selected photo reference
public struct BoothPhoto: Identifiable, Hashable {
    public let id: String
    public let source: PhotoSource
    public let localIdentifier: String
    public var orderIndex: Int
    
    public init(id: String = UUID().uuidString, source: PhotoSource, localIdentifier: String, orderIndex: Int) {
        self.id = id
        self.source = source
        self.localIdentifier = localIdentifier
        self.orderIndex = orderIndex
    }
}
