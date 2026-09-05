import SwiftUI

struct PhotoSourceView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var currentSession: BoothSession
    
    init(navigationPath: Binding<NavigationPath>, currentSession: Binding<BoothSession> = .constant(BoothSession())) {
        self._navigationPath = navigationPath
        self._currentSession = currentSession
    }
    
    private var activeTemplate: BoothTemplate {
        currentSession.selectedTemplate ?? MockData.templates[1] // Default to 4 Cut if unset
    }
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Header with Back Button
                HStack {
                    TAROIconButton(icon: TAROIcons.back, size: 20, color: TAROColors.text) {
                        navigationPath.removeLast()
                    }
                    Spacer()
                }
                .padding(.horizontal, TAROSpacing.lg)
                .padding(.top, TAROSpacing.xs)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: TAROSpacing.lg) {
                        // Title and Subtitle
                        VStack(spacing: TAROSpacing.xs) {
                            Text("Add photos")
                                .font(TAROTypography.heading1)
                                .foregroundColor(TAROColors.text)
                            
                            Text("Choose how you want to create your booth.")
                                .font(TAROTypography.subtitle)
                                .foregroundColor(TAROColors.text.opacity(0.6))
                        }
                        .padding(.top, TAROSpacing.sm)
                        
                        // Selected Template Summary Card
                        selectedBoothSummary
                        
                        // Two Action Cards
                        VStack(spacing: TAROSpacing.md) {
                            SourceCard(
                                title: "Take Photos",
                                subtitle: "Capture directly with TAROBOOTH",
                                icon: TAROIcons.camera,
                                color: TAROColors.softBlush
                            ) {
                                currentSession.sourceType = .camera
                                navigationPath.append(AppRoute.camera)
                            }
                            
                            SourceCard(
                                title: "Choose From Library",
                                subtitle: "Use photos already on your iPhone",
                                icon: TAROIcons.photo,
                                color: TAROColors.cream
                            ) {
                                currentSession.sourceType = .library
                                navigationPath.append(AppRoute.library)
                            }
                        }
                        .padding(.top, TAROSpacing.sm)
                    }
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.bottom, TAROSpacing.xxl)
                }
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
    }
    
    private var selectedBoothSummary: some View {
        HStack(spacing: TAROSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: TARORadius.md)
                    .fill(TAROColors.softBlush.opacity(0.4))
                    .frame(width: 44, height: 44)
                
                Image(systemName: TAROIcons.frame)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(TAROColors.primaryPink)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("SELECTED BOOTH")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(TAROColors.primaryPink)
                
                Text(activeTemplate.name)
                    .font(TAROTypography.subtitle)
                    .fontWeight(.semibold)
                    .foregroundColor(TAROColors.text)
            }
            
            Spacer()
            
            Text("\(activeTemplate.photoCount) \(activeTemplate.photoCount == 1 ? "photo" : "photos")")
                .font(TAROTypography.caption)
                .fontWeight(.medium)
                .padding(.horizontal, TAROSpacing.sm)
                .padding(.vertical, 4)
                .background(TAROColors.cream)
                .cornerRadius(TARORadius.pill)
                .foregroundColor(TAROColors.text.opacity(0.7))
        }
        .padding(TAROSpacing.md)
        .background(TAROColors.white)
        .cornerRadius(TARORadius.lg)
        .applyTAROShadow(.soft)
    }
}

// MARK: - Source Card

struct SourceCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: TAROSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: TARORadius.md)
                        .fill(color)
                        .frame(width: 58, height: 58)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundColor(TAROColors.primaryPink)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(TAROTypography.heading2)
                        .foregroundColor(TAROColors.text)
                    
                    Text(subtitle)
                        .font(TAROTypography.caption)
                        .foregroundColor(TAROColors.text.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
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
    PhotoSourceView(
        navigationPath: .constant(NavigationPath()),
        currentSession: .constant(BoothSession())
    )
}
