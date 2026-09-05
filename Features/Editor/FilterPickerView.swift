import SwiftUI

struct FilterPickerView: View {
    @State private var selectedFilterId = "1"
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TAROSpacing.md) {
                ForEach(MockData.filmPresets) { filter in
                    VStack(spacing: TAROSpacing.xs) {
                        Circle()
                            .fill(TAROColors.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(selectedFilterId == filter.id ? TAROColors.strongPink : Color.clear, lineWidth: 3)
                            )
                        
                        Text(filter.name)
                            .font(TAROTypography.caption)
                            .foregroundColor(selectedFilterId == filter.id ? TAROColors.strongPink : TAROColors.text)
                    }
                    .onTapGesture {
                        selectedFilterId = filter.id
                    }
                }
            }
            .padding(.horizontal, TAROSpacing.md)
        }
    }
}

#Preview {
    FilterPickerView()
}
