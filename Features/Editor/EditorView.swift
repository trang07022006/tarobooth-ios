import SwiftUI

struct EditorView: View {
    @Binding var navigationPath: NavigationPath
    @State private var selectedTab: EditorTab = .frame
    
    @State private var selectedFrameColor = TAROColors.white
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    TAROIconButton(icon: TAROIcons.back) {
                        navigationPath.removeLast()
                    }
                    Spacer()
                    Button("Save") {
                        navigationPath.append(AppRoute.result)
                    }
                    .font(TAROTypography.button)
                    .foregroundColor(TAROColors.primaryPink)
                }
                .padding()
                
                // Canvas Preview using BoothCanvasView
                BoothCanvasView(templateName: "4 Cut", frameColor: selectedFrameColor)
                    .padding(.horizontal, TAROSpacing.xl)
                
                Spacer()
                
                // Tool Panel
                VStack(spacing: 0) {
                    // Tool Content
                    Group {
                        switch selectedTab {
                        case .frame:
                            FramePickerView(selectedColor: $selectedFrameColor)
                        case .filter:
                            FilterPickerView()
                        case .text:
                            TextEditorPanel()
                        case .sticker:
                            StickerPickerView()
                        }
                    }
                    .frame(height: 120)
                    .padding(.vertical, TAROSpacing.sm)
                    
                    // Tab Bar
                    EditorToolbar(selectedTab: $selectedTab)
                }
                .background(TAROColors.white)
                .cornerRadius(TARORadius.lg, corners: [.topLeft, .topRight])
                .applyTAROShadow(.soft)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
    }
}

// Helper to round specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    EditorView(navigationPath: .constant(NavigationPath()))
}
