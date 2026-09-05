import SwiftUI

struct GalleryDetailView: View {
    @Binding var navigationPath: NavigationPath
    let itemId: String
    
    // Mock finding the item
    var item: GalleryItem? {
        MockData.galleryItems.first { $0.id == itemId }
    }
    
    @State private var isFavorite = false
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            if let item = item {
                VStack(spacing: TAROSpacing.md) {
                    // Top Bar
                    HStack {
                        TAROIconButton(icon: TAROIcons.back) {
                            navigationPath.removeLast()
                        }
                        Spacer()
                        Text(item.date, style: .date)
                            .font(TAROTypography.subtitle)
                            .foregroundColor(TAROColors.text)
                        Spacer()
                        TAROIconButton(icon: isFavorite ? "heart.fill" : "heart", color: isFavorite ? TAROColors.primaryPink : TAROColors.text) {
                            isFavorite.toggle()
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    BoothCanvasView(templateName: item.templateName, frameColor: TAROColors.cream)
                        .padding(.horizontal, TAROSpacing.xl)
                    
                    Spacer()
                    
                    // Bottom actions
                    HStack(spacing: TAROSpacing.xl) {
                        TAROIconButton(icon: TAROIcons.share, size: 24, color: TAROColors.text) {
                            // Mock share
                        }
                        
                        TAROIconButton(icon: TAROIcons.save, size: 24, color: TAROColors.text) {
                            // Mock save
                        }
                        
                        TAROIconButton(icon: TAROIcons.delete, size: 24, color: TAROColors.text) {
                            // Mock delete
                            navigationPath.removeLast()
                        }
                    }
                    .padding(.bottom, TAROSpacing.xl)
                }
                .onAppear {
                    self.isFavorite = item.isFavorite
                }
            } else {
                ErrorStateView(message: "Photo not found") {
                    navigationPath.removeLast()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    GalleryDetailView(navigationPath: .constant(NavigationPath()), itemId: "1")
}
