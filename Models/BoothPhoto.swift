import Foundation

public enum PhotoCropMode: String, Hashable {
    case fit
    case fill
    
    public var displayName: String {
        switch self {
        case .fit: return "Fit"
        case .fill: return "Fill"
        }
    }
}

public struct PhotoCropState: Hashable {
    public var mode: PhotoCropMode
    public var rotationQuarterTurns: Int { // 0, 1, 2, 3 -> 0°, 90°, 180°, 270°
        didSet {
            let normalized = rotationQuarterTurns % 4
            let safe = normalized < 0 ? normalized + 4 : normalized
            if rotationQuarterTurns != safe {
                rotationQuarterTurns = safe
            }
        }
    }
    public var isHorizontallyFlipped: Bool
    
    public init(mode: PhotoCropMode = .fit, rotationQuarterTurns: Int = 0, isHorizontallyFlipped: Bool = false) {
        self.mode = mode
        let normalized = rotationQuarterTurns % 4
        self.rotationQuarterTurns = normalized < 0 ? normalized + 4 : normalized
        self.isHorizontallyFlipped = isHorizontallyFlipped
    }
    
    public var rotationDegrees: Double {
        Double(rotationQuarterTurns * 90)
    }
}

/// Lightweight abstraction for a captured or selected photo reference
public struct BoothPhoto: Identifiable, Hashable {
    public let id: String
    public let source: PhotoSource
    public let localIdentifier: String
    public var assetKey: String?
    public var orderIndex: Int
    public var filmPresetID: String?
    public var cropState: PhotoCropState
    
    public init(
        id: String = UUID().uuidString,
        source: PhotoSource,
        localIdentifier: String,
        assetKey: String? = nil,
        orderIndex: Int,
        filmPresetID: String? = nil,
        cropState: PhotoCropState = PhotoCropState()
    ) {
        self.id = id
        self.source = source
        self.localIdentifier = localIdentifier
        self.assetKey = assetKey
        self.orderIndex = orderIndex
        self.filmPresetID = filmPresetID
        self.cropState = cropState
    }
}
