import SwiftUI

struct PhotoSourceView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: TAROSpacing.xl) {
                Text("How would you like to add photos?")
                    .font(TAROTypography.heading1)
                    .foregroundColor(TAROColors.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.top, TAROSpacing.xl)
                
                Spacer()
                
                VStack(spacing: TAROSpacing.lg) {
                    SourceCard(
                        title: "Take Photos",
                        subtitle: "Capture directly with TAROBOOTH",
                        icon: TAROIcons.camera,
                        color: TAROColors.primaryPink
                    ) {
                        navigationPath.append(AppRoute.camera)
                    }
                    
                    SourceCard(
                        title: "Choose From Library",
                        subtitle: "Use photos already on your iPhone",
                        icon: TAROIcons.photo,
                        color: TAROColors.softBlush
                    ) {
                        navigationPath.append(AppRoute.library)
                    }
                }
                .padding(.horizontal, TAROSpacing.lg)
                
                Spacer()
            }
        }
        .navigationTitle("Source")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SourceCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: TAROSpacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(TAROColors.primaryPink)
                    .frame(width: 60, height: 60)
                    .background(color.opacity(0.2))
                    .cornerRadius(TARORadius.md)
                
                VStack(alignment: .leading, spacing: TAROSpacing.xs) {
                    Text(title)
                        .font(TAROTypography.heading2)
                        .foregroundColor(TAROColors.text)
                    
                    Text(subtitle)
                        .font(TAROTypography.caption)
                        .foregroundColor(TAROColors.text.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(TAROColors.gray)
            }
            .padding(TAROSpacing.md)
            .background(TAROColors.white)
            .cornerRadius(TARORadius.lg)
            .applyTAROShadow(.medium)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PhotoSourceView(navigationPath: .constant(NavigationPath()))
}
