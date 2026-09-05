import Foundation

public enum TARODateFormat: String, CaseIterable, Hashable {
    case ddMMyyyy = "dd.MM.yyyy"
    case yyyyMMdd = "yyyy.MM.dd"
    
    public var displayName: String {
        switch self {
        case .ddMMyyyy:
            return "DD.MM.YYYY"
        case .yyyyMMdd:
            return "YYYY.MM.DD"
        }
    }
}

public final class TARODateFormatter {
    public static let shared = TARODateFormatter()
    
    private let ddMMyyyyFormatter: DateFormatter
    private let yyyyMMddFormatter: DateFormatter
    
    private init() {
        let f1 = DateFormatter()
        f1.dateFormat = "dd.MM.yyyy"
        f1.locale = Locale(identifier: "en_US_POSIX")
        self.ddMMyyyyFormatter = f1
        
        let f2 = DateFormatter()
        f2.dateFormat = "yyyy.MM.dd"
        f2.locale = Locale(identifier: "en_US_POSIX")
        self.yyyyMMddFormatter = f2
    }
    
    public func string(from date: Date, format: TARODateFormat = .ddMMyyyy) -> String {
        switch format {
        case .ddMMyyyy:
            return ddMMyyyyFormatter.string(from: date)
        case .yyyyMMdd:
            return yyyyMMddFormatter.string(from: date)
        }
    }
    
    public func currentFormattedDate(format: TARODateFormat = .ddMMyyyy) -> String {
        return string(from: Date(), format: format)
    }
}
