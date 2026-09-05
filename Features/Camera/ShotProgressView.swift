import SwiftUI

public struct CapturedPhotoStrip: View {
    public let capturedCount: Int
    public let totalCount: Int
    
    public init(capturedCount: Int, totalCount: Int) {
        self.capturedCount = capturedCount
        self.totalCount = totalCount
    }
    
    // Backward compatibility initializer
    public init(current: Int, total: Int) {
        self.capturedCount = current
        self.totalCount = total
    }
    
    public var body: some View {
        if totalCount > 1 {
            HStack(spacing: 6) {
                ForEach(0..<totalCount, id: \.self) { index in
                    let isCaptured = index < capturedCount
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(isCaptured ? TAROColors.primaryPink.opacity(0.85) : Color.white.opacity(0.12))
                            .frame(width: 22, height: 28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(isCaptured ? TAROColors.strongPink : Color.white.opacity(0.25), lineWidth: 1)
                            )
                        
                        if isCaptured {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.4))
                        }
                    }
                }
            }
            .padding(.horizontal, TAROSpacing.sm)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.4))
            .cornerRadius(TARORadius.pill)
        }
    }
}

public typealias ShotProgressView = CapturedPhotoStrip

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CapturedPhotoStrip(capturedCount: 2, totalCount: 4)
    }
}
