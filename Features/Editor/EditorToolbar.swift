import SwiftUI

struct EditorToolbar: View {
    @Binding var selectedTab: EditorTab
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TAROSpacing.xs) {
                EditorTabButton(title: "Frame", icon: TAROIcons.frame, isSelected: selectedTab == .frame) {
                    selectedTab = .frame
                }
                EditorTabButton(title: "Background", icon: TAROIcons.background, isSelected: selectedTab == .background) {
                    selectedTab = .background
                }
                EditorTabButton(title: "Layout", icon: TAROIcons.layout, isSelected: selectedTab == .layout) {
                    selectedTab = .layout
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
            .padding(.horizontal, TAROSpacing.sm)
        }
        .padding(.bottom, TAROSpacing.lg)
    }
}

struct EditorTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: TAROSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(TAROTypography.caption)
            }
            .foregroundColor(isSelected ? TAROColors.softBlush : Color.white.opacity(0.45))
            .frame(minWidth: 62)
            .frame(height: 48)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EditorToolbar(selectedTab: .constant(.frame))
        .background(Color(hex: "232022"))
}
