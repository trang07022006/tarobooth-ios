import SwiftUI

struct PhotoSelectionGrid: View {
    @Binding var selectedCount: Int
    let requiredCount: Int
    
    // Mock items
    let items = Array(1...30)
    @State private var selectedItems: Set<Int> = []
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
            ForEach(items, id: \.self) { item in
                let isSelected = selectedItems.contains(item)
                
                Rectangle()
                    .fill(TAROColors.gray.opacity(isSelected ? 0.8 : 0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        ZStack {
                            if isSelected {
                                Circle()
                                    .fill(TAROColors.strongPink)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text("\(selectedItems.firstIndex(of: item)?.distance(to: 0) ?? 0 + 1)") // Rough mock ordering
                                            .font(TAROTypography.caption)
                                            .foregroundColor(.white)
                                    )
                                    .position(x: 20, y: 20)
                            } else {
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .position(x: 20, y: 20)
                            }
                        }
                    )
                    .onTapGesture {
                        if isSelected {
                            selectedItems.remove(item)
                            selectedCount -= 1
                        } else if selectedCount < requiredCount {
                            selectedItems.insert(item)
                            selectedCount += 1
                        }
                    }
            }
        }
    }
}

#Preview {
    PhotoSelectionGrid(selectedCount: .constant(2), requiredCount: 4)
}
