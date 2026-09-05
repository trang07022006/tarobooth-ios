import SwiftUI

struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var currentSession: BoothSession
    
    init(navigationPath: Binding<NavigationPath>, currentSession: Binding<BoothSession> = .constant(BoothSession())) {
        self._navigationPath = navigationPath
        self._currentSession = currentSession
    }
    
    private var quickModes: [BoothTemplate] {
        return MockData.templates.filter {
            $0.name == "Single Photo" || $0.name == "4 Cut" || $0.name == "Film Strip"
        }
    }
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: TAROSpacing.lg) {
                    // Top Bar
                    HStack {
                        Spacer()
                        TAROIconButton(icon: TAROIcons.settings, size: 20, color: TAROColors.text) {
                            navigationPath.append(AppRoute.settings)
                        }
                    }
                    .padding(.top, TAROSpacing.xs)
                    
                    // Brand Header
                    VStack(spacing: TAROSpacing.xs) {
                        HStack(spacing: 6) {
                            Text("TAROBOOTH")
                                .font(TAROTypography.brandTitle)
                                .foregroundColor(TAROColors.text)
                            Image(systemName: TAROIcons.heart)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(TAROColors.primaryPink)
                        }
                        
                        Text("Capture your little moments.")
                            .font(TAROTypography.subtitle)
                            .foregroundColor(TAROColors.text.opacity(0.65))
                    }
                    .padding(.top, TAROSpacing.xs)
                    
                    // Photobooth Decorative Preview Strip
                    decorativePhotoboothHero
                        .padding(.vertical, TAROSpacing.xs)
                    
                    // Primary CTA
                    Button(action: {
                        currentSession = BoothSession()
                        navigationPath.append(AppRoute.templates)
                    }) {
                        HStack(spacing: TAROSpacing.sm) {
                            Image(systemName: TAROIcons.camera)
                                .font(.system(size: 18, weight: .semibold))
                            Text("START PHOTOBOOTH")
                                .font(TAROTypography.button)
                        }
                        .foregroundColor(TAROColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(TAROColors.text)
                        .cornerRadius(TARORadius.pill)
                        .applyTAROShadow(.medium)
                    }
                    .buttonStyle(.plain)
                    
                    // Quick Modes Section
                    VStack(alignment: .leading, spacing: TAROSpacing.sm) {
                        HStack {
                            Text("QUICK MODES")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(TAROColors.text.opacity(0.5))
                            Spacer()
                            Text("Tap to shoot")
                                .font(TAROTypography.caption)
                                .foregroundColor(TAROColors.text.opacity(0.4))
                        }
                        .padding(.horizontal, 4)
                        
                        HStack(spacing: TAROSpacing.sm) {
                            ForEach(quickModes) { template in
                                QuickModeCard(template: template) {
                                    startQuickMode(template)
                                }
                            }
                        }
                    }
                    .padding(.top, TAROSpacing.xs)
                    
                    // Secondary Actions Row
                    VStack(alignment: .leading, spacing: TAROSpacing.sm) {
                        Text("EXPLORE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(TAROColors.text.opacity(0.5))
                            .padding(.horizontal, 4)
                        
                        HStack(spacing: TAROSpacing.sm) {
                            SecondaryActionCard(
                                title: "Gallery",
                                icon: TAROIcons.gallery,
                                action: { navigationPath.append(AppRoute.gallery) }
                            )
                            
                            SecondaryActionCard(
                                title: "Templates",
                                icon: TAROIcons.frame,
                                action: {
                                    currentSession = BoothSession()
                                    navigationPath.append(AppRoute.templates)
                                }
                            )
                            
                            SecondaryActionCard(
                                title: "Settings",
                                icon: TAROIcons.settings,
                                action: { navigationPath.append(AppRoute.settings) }
                            )
                        }
                    }
                    .padding(.top, TAROSpacing.xs)
                }
                .padding(.horizontal, TAROSpacing.lg)
                .padding(.bottom, TAROSpacing.xxl)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var decorativePhotoboothHero: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                ForEach(0..<3) { idx in
                    Rectangle()
                        .fill(TAROColors.cameraBackground.opacity(0.85))
                        .aspectRatio(4/3, contentMode: .fit)
                        .cornerRadius(TARORadius.sm)
                        .overlay(
                            Image(systemName: idx == 0 ? TAROIcons.sparkles : (idx == 1 ? TAROIcons.heart : TAROIcons.photo))
                                .font(.system(size: 18))
                                .foregroundColor(TAROColors.softBlush.opacity(0.7))
                        )
                }
            }
            
            HStack {
                Text("★ TAROBOOTH STRIP")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(TAROColors.text.opacity(0.5))
                Spacer()
                Text("V1.0 • MEMORIES")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(TAROColors.text.opacity(0.4))
            }
            .padding(.horizontal, 4)
            .padding(.top, 2)
        }
        .padding(TAROSpacing.sm)
        .background(TAROColors.white)
        .cornerRadius(TARORadius.md)
        .applyTAROShadow(.soft)
    }
    
    private func startQuickMode(_ template: BoothTemplate) {
        currentSession = BoothSession()
        currentSession.selectedTemplate = template
        navigationPath.append(AppRoute.sourcePicker)
    }
}

// MARK: - Quick Mode Card

private struct QuickModeCard: View {
    let template: BoothTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: TAROSpacing.xs) {
                // Mini Icon Layout representation
                ZStack {
                    RoundedRectangle(cornerRadius: TARORadius.md)
                        .fill(TAROColors.cream)
                        .frame(height: 52)
                    
                    quickIcon(for: template.name)
                        .foregroundColor(TAROColors.primaryPink)
                }
                
                Text(template.name)
                    .font(TAROTypography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(TAROColors.text)
                    .lineLimit(1)
                
                Text("\(template.photoCount) \(template.photoCount == 1 ? "photo" : "photos")")
                    .font(.system(size: 11))
                    .foregroundColor(TAROColors.text.opacity(0.5))
            }
            .padding(TAROSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(TAROColors.white)
            .cornerRadius(TARORadius.lg)
            .applyTAROShadow(.soft)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func quickIcon(for name: String) -> some View {
        switch name {
        case "Single Photo":
            RoundedRectangle(cornerRadius: TARORadius.sm)
                .stroke(TAROColors.primaryPink, lineWidth: 1.5)
                .frame(width: 22, height: 28)
        case "4 Cut":
            VStack(spacing: 2) {
                ForEach(0..<4) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(TAROColors.primaryPink.opacity(0.7))
                        .frame(width: 22, height: 5)
                }
            }
        default:
            // Film Strip
            HStack(spacing: 2) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(TAROColors.primaryPink.opacity(0.7))
                        .frame(width: 6, height: 24)
                }
            }
        }
    }
}

// MARK: - Secondary Action Card

private struct SecondaryActionCard: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: TAROSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(TAROColors.primaryPink)
                    .frame(height: 28)
                
                Text(title)
                    .font(TAROTypography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(TAROColors.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TAROSpacing.md)
            .background(TAROColors.white)
            .cornerRadius(TARORadius.md)
            .applyTAROShadow(.soft)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(navigationPath: .constant(NavigationPath()), currentSession: .constant(BoothSession()))
}
