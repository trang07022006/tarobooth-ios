import SwiftUI

public struct CameraControlsView: View {
    public let currentShot: Int?
    public let totalShots: Int?
    public let canCapture: Bool
    public let isCapturing: Bool
    public let canRetake: Bool
    public let onCapture: () -> Void
    public let onFlip: () -> Void
    public let onRetake: () -> Void
    
    public init(
        currentShot: Int? = nil,
        totalShots: Int? = nil,
        canCapture: Bool = true,
        isCapturing: Bool = false,
        canRetake: Bool = false,
        onCapture: @escaping () -> Void,
        onFlip: @escaping () -> Void = {},
        onRetake: @escaping () -> Void = {}
    ) {
        self.currentShot = currentShot
        self.totalShots = totalShots
        self.canCapture = canCapture
        self.isCapturing = isCapturing
        self.canRetake = canRetake
        self.onCapture = onCapture
        self.onFlip = onFlip
        self.onRetake = onRetake
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            // Left: Retake Last Action (if applicable)
            ZStack {
                if canRetake {
                    Button(action: onRetake) {
                        VStack(spacing: 2) {
                            Image(systemName: TAROIcons.retake)
                                .font(.system(size: 20, weight: .medium))
                            Text("Retake")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(Color.white.opacity(0.85))
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 60)
            
            Spacer()
            
            // Center: Large Shutter Button (72-84pt visual size, high contrast)
            Button(action: onCapture) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 4)
                        .frame(width: 84, height: 84)
                    
                    Circle()
                        .fill(isCapturing ? TAROColors.primaryPink : Color.white)
                        .frame(width: 72, height: 72)
                        .scaleEffect(isCapturing ? 0.92 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isCapturing)
                }
            }
            .buttonStyle(.plain)
            .disabled(!canCapture || isCapturing)
            
            Spacer()
            
            // Right: Flip Camera Button (44pt+ tap target)
            Button(action: onFlip) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .frame(width: 60)
        }
        .padding(.horizontal, TAROSpacing.xl)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CameraControlsView(
            isCapturing: false,
            canRetake: true,
            onCapture: {},
            onFlip: {},
            onRetake: {}
        )
    }
}
