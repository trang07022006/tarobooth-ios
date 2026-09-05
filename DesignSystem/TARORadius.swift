import Foundation

public enum TARORadius {
    /// 4 points - subtle rounding
    public static let sm: CGFloat = 4
    
    /// 8 points - general UI elements
    public static let md: CGFloat = 8
    
    /// 16 points - cards and panels
    public static let lg: CGFloat = 16
    
    /// 24 points - large structural elements
    public static let xl: CGFloat = 24
    
    /// Circular (or very large for pill shapes)
    public static let pill: CGFloat = 999
}
