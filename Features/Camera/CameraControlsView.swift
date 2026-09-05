import SwiftUI

struct CameraControlsView: View {
    let onCapture: () -> Void
    
    var body: some View {
        HStack {
            // Thumbnail placeholder
            RoundedRectangle(cornerRadius: TARORadius.md)
                .fill(Color.white.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: TAROIcons.photo)
                        .foregroundColor(.white)
                )
            
            Spacer()
            
            // Shutter Button
            Button(action: onCapture) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(TAROColors.strongPink, lineWidth: 4)
                            .frame(width: 80, height: 80)
                    )
            }
            
            Spacer()
            
            // Flip Camera Button
            Button(action: {}) {
                Image(systemName: TAROIcons.replace)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, TAROSpacing.xl)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CameraControlsView(onCapture: {})
    }
}
