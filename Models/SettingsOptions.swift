import Foundation

public enum CountdownOption: Int, Hashable, CaseIterable {
    case off = 0
    case threeSeconds = 3
    case fiveSeconds = 5
    case tenSeconds = 10
    
    public var displayName: String {
        switch self {
        case .off: return "Off"
        case .threeSeconds: return "3s"
        case .fiveSeconds: return "5s"
        case .tenSeconds: return "10s"
        }
    }
}

public enum DefaultFilmOption: String, Hashable, CaseIterable {
    case original = "original"
    case cream = "cream"
    case warm = "warm"
    case vintage = "vintage"
    case retro = "retro"
    case disposable = "disposable"
    case mono = "mono"
    case cool = "cool"
    
    public var displayName: String {
        switch self {
        case .original: return "Original"
        case .cream: return "Cream"
        case .warm: return "Warm"
        case .vintage: return "Vintage"
        case .retro: return "Retro"
        case .disposable: return "Disposable"
        case .mono: return "Mono"
        case .cool: return "Cool"
        }
    }
}

public enum ThemeOption: String, Hashable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    public var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

public enum DateFormatOption: String, Hashable, CaseIterable {
    case ddMMyyyy = "dd.MM.yyyy"
    case yyyyMMdd = "yyyy.MM.dd"
    
    public var displayName: String {
        switch self {
        case .ddMMyyyy: return "DD.MM.YYYY"
        case .yyyyMMdd: return "YYYY.MM.DD"
        }
    }
}

public struct SettingsOptions: Hashable {
    public var mirrorSelfie: Bool
    public var countdown: CountdownOption
    public var defaultFilmPresetID: String
    public var autoSave: Bool
    public var highResolution: Bool
    public var theme: ThemeOption
    public var dateFormat: DateFormatOption
    
    public init(
        mirrorSelfie: Bool = true,
        countdown: CountdownOption = .threeSeconds,
        defaultFilmPresetID: String = "original",
        autoSave: Bool = false,
        highResolution: Bool = true,
        theme: ThemeOption = .system,
        dateFormat: DateFormatOption = .ddMMyyyy
    ) {
        self.mirrorSelfie = mirrorSelfie
        self.countdown = countdown
        self.defaultFilmPresetID = defaultFilmPresetID
        self.autoSave = autoSave
        self.highResolution = highResolution
        self.theme = theme
        self.dateFormat = dateFormat
    }
}
