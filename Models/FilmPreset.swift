import Foundation

public struct FilmPreset: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let displayName: String
    public let filterIdentifier: String
    
    // Filter parameters placeholder for V1 core abstraction
    public let brightness: Float
    public let contrast: Float
    public let saturation: Float
    public let temperature: Float
    public let fade: Float
    public let grain: Float
    
    public init(id: String, name: String, displayName: String, filterIdentifier: String, brightness: Float = 0, contrast: Float = 1, saturation: Float = 1, temperature: Float = 6500, fade: Float = 0, grain: Float = 0) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.filterIdentifier = filterIdentifier
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
        self.temperature = temperature
        self.fade = fade
        self.grain = grain
    }
}
