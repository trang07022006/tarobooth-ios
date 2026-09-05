import SwiftUI

struct RootView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showSplash = true
    @State private var currentSession = BoothSession()
    @State private var galleryItems: [GalleryItem] = MockData.galleryItems
    
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
                HomeView(navigationPath: $navigationPath, currentSession: $currentSession)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .home:
                            HomeView(navigationPath: $navigationPath, currentSession: $currentSession)
                        case .templates:
                            TemplateSelectionView(navigationPath: $navigationPath, currentSession: $currentSession)
                        case .sourcePicker:
                            PhotoSourceView(navigationPath: $navigationPath, currentSession: $currentSession)
                        case .camera:
                            CameraView(navigationPath: $navigationPath, currentSession: $currentSession)
                        case .library:
                            LibraryPickerView(navigationPath: $navigationPath, currentSession: $currentSession)
                        case .arrange:
                            PhotoArrangeView(navigationPath: $navigationPath, currentSession: $currentSession)
                        case .crop:
                            CropPhotoView(navigationPath: $navigationPath, currentSession: $currentSession)
                        case .review:
                            PhotoReviewView(navigationPath: $navigationPath, currentSession: $currentSession)
                        case .editor:
                            EditorView(navigationPath: $navigationPath, currentSession: $currentSession)
                        case .result:
                            ResultView(navigationPath: $navigationPath, currentSession: $currentSession, galleryItems: $galleryItems)
                        case .gallery:
                            GalleryView(navigationPath: $navigationPath, galleryItems: $galleryItems)
                        case .galleryDetail(let id):
                            GalleryDetailView(navigationPath: $navigationPath, itemId: id, galleryItems: $galleryItems)
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
