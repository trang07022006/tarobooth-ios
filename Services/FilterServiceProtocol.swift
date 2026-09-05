import Foundation

public protocol FilterServiceProtocol {
    /// Applies a film preset to an image representation.
    /// Note: Returns an opaque type (e.g. Data or abstract reference) for V1 abstraction.
    func apply(preset: FilmPreset, toImageData data: Data) async throws -> Data
}
