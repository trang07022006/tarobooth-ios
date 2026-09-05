import SwiftUI

struct LibraryPickerView: View {
    @Binding var navigationPath: NavigationPath
    @State private var selectedPhotosCount = 0
    let requiredPhotos = 4
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Grid
                ScrollView {
                    PhotoSelectionGrid(selectedCount: $selectedPhotosCount, requiredCount: requiredPhotos)
                        .padding(.horizontal, TAROSpacing.md)
                        .padding(.top, TAROSpacing.md)
                }
                
                // Footer
                SelectedPhotoTray(selectedCount: selectedPhotosCount, requiredCount: requiredPhotos) {
                    if selectedPhotosCount == requiredPhotos {
                        navigationPath.append(AppRoute.arrange)
                    }
                }
            }
        }
        .navigationTitle("Select \(requiredPhotos) photos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LibraryPickerView(navigationPath: .constant(NavigationPath()))
}
