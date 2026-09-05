import SwiftUI

public enum TAROTypography {
    
    /// Large titles for branding
    public static var brandTitle: Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }
    
    /// Primary page headings
    public static var heading1: Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    
    /// Section headings
    public static var heading2: Font {
        .system(size: 22, weight: .semibold, design: .rounded)
    }
    
    /// Main body text
    public static var body: Font {
        .system(size: 17, weight: .regular, design: .default)
    }
    
    /// Subtitles, taglines, descriptive text
    public static var subtitle: Font {
        .system(size: 15, weight: .medium, design: .default)
    }
    
    /// Captions, small indicators
    public static var caption: Font {
        .system(size: 13, weight: .regular, design: .default)
    }
    
    /// Button text
    public static var button: Font {
        .system(size: 17, weight: .semibold, design: .rounded)
    }
}
