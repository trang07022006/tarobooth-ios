import Foundation

public enum TAROCoreError: Error, LocalizedError {
    case permissionDenied
    case unavailable
    case invalidState
    case captureFailed
    case exportFailed
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied: return "Permission was denied."
        case .unavailable: return "The requested feature is unavailable."
        case .invalidState: return "The system is in an invalid state for this operation."
        case .captureFailed: return "Failed to capture the photo."
        case .exportFailed: return "Failed to export the image."
        case .unknown: return "An unknown error occurred."
        }
    }
}
