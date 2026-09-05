import SwiftUI

public enum TAROShadow {
    public struct Config {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    public static let soft = Config(
        color: TAROColors.strongPink.opacity(0.1),
        radius: 10,
        x: 0,
        y: 4
    )
    
    public static let medium = Config(
        color: TAROColors.text.opacity(0.15),
        radius: 16,
        x: 0,
        y: 8
    )
}

extension View {
    public func applyTAROShadow(_ style: TAROShadow.Config = TAROShadow.soft) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
