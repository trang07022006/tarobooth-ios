import SwiftUI

struct CountdownOverlay: View {
    let count: Int
    let isCapturing: Bool
    
    var body: some View {
        ZStack {
            if isCapturing {
                Color.white
                    .ignoresSafeArea()
                    .opacity(0.8)
                    .transition(.opacity)
            } else if count > 0 {
                Text("\(count)")
                    .font(.system(size: 140, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

#Preview {
    CountdownOverlay(count: 3, isCapturing: false)
        .background(Color.gray)
}
