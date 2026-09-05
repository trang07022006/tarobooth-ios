import Foundation

public enum CountdownOption: Int, Hashable, CaseIterable {
    case off = 0
    case threeSeconds = 3
    case fiveSeconds = 5
    case tenSeconds = 10
}

public enum DefaultFilmOption: String, Hashable, CaseIterable {
    case original = "Original"
    case cream = "Cream"
    case warm = "Warm"
    case retro = "Retro"
}

public enum DateFormatOption: String, Hashable, CaseIterable {
    case yyyyMMdd = "yyyy.MM.dd"
    case ddMMyyyy = "dd.MM.yyyy"
    case hidden = "Hidden"
}
