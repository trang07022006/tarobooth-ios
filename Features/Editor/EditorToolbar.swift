import SwiftUI

struct EditorToolbar: View {
    @Binding var selectedTab: EditorTab
    
    var body: some View {
        HStack(spacing: 0) {
            EditorTabButton(title: "Frame", icon: TAROIcons.frame, isSelected: selectedTab == .frame) {
                selectedTab = .frame
            }
            EditorTabButton(title: "Filter", icon: TAROIcons.filter, isSelected: selectedTab == .filter) {
                selectedTab = .filter
            }
            EditorTabButton(title: "Text", icon: TAROIcons.text, isSelected: selectedTab == .text) {
                selectedTab = .text
            }
            EditorTabButton(title: "Sticker", icon: TAROIcons.sticker, isSelected: selectedTab == .sticker) {
                selectedTab = .sticker
            }
        }
        .padding(.bottom, TAROSpacing.lg)
    }
}

#Preview {
    EditorToolbar(selectedTab: .constant(.frame))
}
