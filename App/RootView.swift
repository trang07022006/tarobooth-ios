import SwiftUI

struct RootView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showSplash = true
    
    var body: some View {
        if showSplash {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showSplash = false
                        }
                    }
                }
        } else {
            NavigationStack(path: $navigationPath) {
                HomeView(navigationPath: $navigationPath)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .home:
                            HomeView(navigationPath: $navigationPath)
                        case .templates:
                            TemplateSelectionView(navigationPath: $navigationPath)
                        case .sourcePicker:
                            PhotoSourceView(navigationPath: $navigationPath)
                        case .camera:
                            CameraView(navigationPath: $navigationPath)
                        case .library:
                            LibraryPickerView(navigationPath: $navigationPath)
                        case .arrange:
                            PhotoArrangeView(navigationPath: $navigationPath)
                        case .crop:
                            CropPhotoView(navigationPath: $navigationPath)
                        case .review:
                            PhotoReviewView(navigationPath: $navigationPath)
                        case .editor:
                            EditorView(navigationPath: $navigationPath)
                        case .result:
                            ResultView(navigationPath: $navigationPath)
                        case .gallery:
                            GalleryView(navigationPath: $navigationPath)
                        case .galleryDetail(let id):
                            GalleryDetailView(navigationPath: $navigationPath, itemId: id)
                        case .settings:
                            SettingsView(navigationPath: $navigationPath)
                        case .about:
                            AboutTAROBOOTHView(navigationPath: $navigationPath)
                        }
                    }
            }
            .tint(TAROColors.strongPink)
        }
    }
}
