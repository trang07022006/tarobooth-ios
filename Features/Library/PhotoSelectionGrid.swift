import SwiftUI

struct PhotoSelectionGrid: View {
    @Binding var selectedItems: [Int]
    let requiredCount: Int
    
    // Mock items (Array 1...30)
    let items = Array(1...30)
    
    init(selectedItems: Binding<[Int]>, requiredCount: Int) {
        self._selectedItems = selectedItems
        self.requiredCount = requiredCount
    }
    
    // Compatibility initializer for passing selectedCount
    init(selectedCount: Binding<Int>, requiredCount: Int) {
        self._selectedItems = .constant([])
        self.requiredCount = requiredCount
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 2) {
            ForEach(items, id: \.self) { item in
                photoCell(for: item)
            }
        }
    }
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2)
        ]
    }
    
    @ViewBuilder
    private func photoCell(for item: Int) -> some View {
        let isSelected = selectedItems.contains(item)
        let order = selectionOrder(for: item)
        
        Button(action: {
            handleTap(for: item, isSelected: isSelected)
        }) {
            ZStack(alignment: .topLeading) {
                // Background cell representing mock photo
                Rectangle()
                    .fill(isSelected ? TAROColors.primaryPink.opacity(0.12) : TAROColors.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        VStack(spacing: 2) {
                            Image(systemName: "photo")
                                .font(.system(size: 20, weight: .ultraLight))
                                .foregroundColor(isSelected ? TAROColors.strongPink.opacity(0.7) : Color.black.opacity(0.25))
                            Text("\(item)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(isSelected ? TAROColors.strongPink.opacity(0.7) : Color.black.opacity(0.25))
                        }
                    )
                
                // Selection Badge
                SelectionBadge(isSelected: isSelected, order: order)
                    .padding(6)
            }
            .overlay(
                Rectangle()
                    .stroke(isSelected ? TAROColors.strongPink : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func handleTap(for item: Int, isSelected: Bool) {
        if isSelected {
            // Deselect: remove from array, automatically shifts remaining items into contiguous order
            selectedItems.removeAll(where: { $0 == item })
        } else if requiredCount == 1 {
            // Single selection / replacement mode: tapping another replaces selection
            selectedItems = [item]
        } else if selectedItems.count < requiredCount {
            // Select: append in exact user tap order
            selectedItems.append(item)
        }
    }
    
    private func selectionOrder(for item: Int) -> Int {
        if let idx = selectedItems.firstIndex(of: item) {
            return idx + 1
        }
        return 0
    }
}

private struct SelectionBadge: View {
    let isSelected: Bool
    let order: Int
    
    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(TAROColors.strongPink)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("\(order)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )
            } else {
                Circle()
                    .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    .background(Circle().fill(Color.black.opacity(0.2)))
                    .frame(width: 24, height: 24)
            }
        }
    }
}

#Preview {
    PhotoSelectionGrid(selectedItems: .constant([1, 4]), requiredCount: 4)
}
