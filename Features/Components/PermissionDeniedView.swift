import SwiftUI

struct PermissionDeniedView: View {
    let type: PermissionType
    
    enum PermissionType {
        case camera
        case photoLibrary
    }
    
    var body: some View {
        EmptyStateView(
            icon: type == .camera ? TAROIcons.camera : TAROIcons.photo,
            title: "Access Needed",
            message: type == .camera ? "Please allow camera access in Settings to take photos." : "Please allow photo library access to select and save photos.",
            actionTitle: "Open Settings",
            action: {
                // Mock open settings
            }
        )
    }
}

#Preview {
    PermissionDeniedView(type: .camera)
}
