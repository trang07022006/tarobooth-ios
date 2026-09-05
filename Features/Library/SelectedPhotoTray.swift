import SwiftUI

struct SelectedPhotoTray: View {
    let selectedItems: [Int]
    let requiredCount: Int
    let onRemove: (Int) -> Void
    let onContinue: () -> Void
    
    // Backwards compatibility initializer
    init(selectedCount: Int, requiredCount: Int, onContinue: @escaping () -> Void) {
        self.selectedItems = selectedCount > 0 ? Array(1...selectedCount) : []
        self.requiredCount = requiredCount
        self.onRemove = { _ in }
        self.onContinue = onContinue
    }
    
    init(selectedItems: [Int], requiredCount: Int, onRemove: @escaping (Int) -> Void, onContinue: @escaping () -> Void) {
        self.selectedItems = selectedItems
        self.requiredCount = requiredCount
        self.onRemove = onRemove
        self.onContinue = onContinue
    }
    
    private var isReadyToContinue: Bool {
        selectedItems.count == requiredCount && requiredCount > 0
    }
    
    var body: some View {
        VStack(spacing: TAROSpacing.sm) {
            // Thumbnails strip
            HStack(spacing: TAROSpacing.xs) {
                ForEach(0..<requiredCount, id: \.self) { slotIndex in
                    if slotIndex < selectedItems.count {
                        let item = selectedItems[slotIndex]
                        // Selected slot with photo & remove button
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: TARORadius.sm)
                                .fill(TAROColors.primaryPink.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: TARORadius.sm)
                                        .stroke(TAROColors.strongPink, lineWidth: 1.5)
                                )
                                .overlay(
                                    VStack(spacing: 2) {
                                        Text("\(slotIndex + 1)")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(TAROColors.strongPink)
                                        Text("Item \(item)")
                                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                                            .foregroundColor(TAROColors.text.opacity(0.6))
                                    }
                                )
                            
                            // Remove Button (>= 44pt hit target via padding)
                            Button(action: { onRemove(item) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(TAROColors.strongPink)
                                    .background(Circle().fill(Color.white))
                            }
                            .buttonStyle(.plain)
                            .offset(x: 4, y: -4)
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                    } else {
                        // Empty slot placeholder
                        RoundedRectangle(cornerRadius: TARORadius.sm)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                            .foregroundColor(Color.black.opacity(0.15))
                            .background(Color.black.opacity(0.02))
                            .overlay(
                                Text("\(slotIndex + 1)")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(TAROColors.text.opacity(0.3))
                            )
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .frame(height: 52)
            .padding(.horizontal, TAROSpacing.lg)
            
            // Primary Action Button
            TAROPrimaryButton(title: "Continue") {
                onContinue()
            }
            .opacity(isReadyToContinue ? 1.0 : 0.45)
            .disabled(!isReadyToContinue)
            .padding(.horizontal, TAROSpacing.lg)
        }
        .padding(.vertical, TAROSpacing.sm)
        .background(TAROColors.white)
        .applyTAROShadow(.medium)
    }
}

#Preview {
    SelectedPhotoTray(selectedItems: [1, 2], requiredCount: 4, onRemove: { _ in }, onContinue: {})
        .background(TAROColors.background)
}
