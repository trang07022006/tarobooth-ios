import Foundation

public protocol PhotoPickerServiceProtocol {
    /// Presents a picker and returns a list of local photo references.
    func selectPhotos(maxSelection: Int) async throws -> [BoothPhoto]
}
