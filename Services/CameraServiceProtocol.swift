import Foundation

public enum CameraPosition: String, Hashable {
    case front
    case back
}

public enum FlashMode: String, Hashable {
    case on
    case off
    case auto
}

public protocol CameraServiceProtocol {
    func startSession() async throws
    func stopSession()
    func capturePhoto() async throws -> BoothPhoto
    func switchCamera(to position: CameraPosition) async throws
    func setFlashMode(_ mode: FlashMode)
}
