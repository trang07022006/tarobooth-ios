import Foundation

public protocol PhotoLibraryServiceProtocol {
    func requestAuthorization() async throws -> Bool
    func saveImage(data: Data) async throws
    func fetchLocalPhoto(identifier: String) async throws -> Data
}
