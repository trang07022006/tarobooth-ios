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

public struct CameraCaptureResult: Hashable {
    public let assetKey: String
    public let localIdentifier: String
    public let timestamp: Date
    
    public init(assetKey: String, localIdentifier: String, timestamp: Date = Date()) {
        self.assetKey = assetKey
        self.localIdentifier = localIdentifier
        self.timestamp = timestamp
    }
}

public protocol CameraServiceProtocol {
    func startSession() async throws
    func stopSession()
    func capturePhoto() async throws -> CameraCaptureResult
    func switchCamera(to position: CameraPosition) async throws
    func setFlashMode(_ mode: FlashMode)
}
