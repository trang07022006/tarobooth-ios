import Foundation

public protocol PhotoComposerProtocol {
    /// Composes a set of photos with a template, frame, and optional text/stickers.
    /// Returns the final image representation as Data.
    func compose(
        photos: [BoothPhoto],
        template: BoothTemplate,
        frame: FramePreset,
        customText: String?,
        stickerIdentifier: String?
    ) async throws -> Data
}
