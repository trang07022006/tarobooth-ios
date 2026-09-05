import SwiftUI

struct ShotProgressView: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: TAROSpacing.xs) {
            ForEach(1...total, id: \.self) { index in
                Circle()
                    .fill(index <= current ? TAROColors.primaryPink : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, TAROSpacing.md)
        .padding(.vertical, TAROSpacing.sm)
        .background(Color.black.opacity(0.4))
        .cornerRadius(TARORadius.pill)
    }
}

#Preview {
    ShotProgressView(current: 2, total: 4)
        .padding()
        .background(Color.gray)
}
