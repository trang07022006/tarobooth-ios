import SwiftUI

struct AboutTAROBOOTHView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Bar with Back Button
                HStack {
                    TAROIconButton(icon: TAROIcons.back) {
                        navigationPath.removeLast()
                    }
                    
                    Spacer()
                    
                    Text("About")
                        .font(TAROTypography.heading2)
                        .foregroundColor(TAROColors.text)
                    
                    Spacer()
                    
                    // Balance space
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, TAROSpacing.md)
                .padding(.top, TAROSpacing.xs)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: TAROSpacing.lg) {
                        // Brand Identity Header
                        VStack(spacing: TAROSpacing.xs) {
                            ZStack {
                                RoundedRectangle(cornerRadius: TARORadius.lg)
                                    .fill(TAROColors.white)
                                    .frame(width: 76, height: 76)
                                    .applyTAROShadow(.soft)
                                
                                Image(systemName: TAROIcons.camera)
                                    .font(.system(size: 36, weight: .light))
                                    .foregroundColor(TAROColors.primaryPink)
                            }
                            .padding(.top, TAROSpacing.sm)
                            
                            HStack(spacing: 6) {
                                Text(TAROAppInfo.appName)
                                    .font(TAROTypography.brandTitle)
                                    .foregroundColor(TAROColors.text)
                                Image(systemName: TAROIcons.heart)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(TAROColors.primaryPink)
                            }
                            
                            Text(TAROAppInfo.tagline)
                                .font(TAROTypography.subtitle)
                                .foregroundColor(TAROColors.text.opacity(0.65))
                            
                            Text("Version \(TAROAppInfo.version)")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(TAROColors.text.opacity(0.45))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.6))
                                .cornerRadius(TARORadius.pill)
                        }
                        .padding(.vertical, TAROSpacing.xs)
                        
                        // FOUNDER Section
                        creditGroup(title: "FOUNDER") {
                            HStack(spacing: TAROSpacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(TAROColors.softBlush.opacity(0.5))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 18))
                                        .foregroundColor(TAROColors.strongPink)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(TAROAppInfo.founderName)
                                        .font(TAROTypography.body)
                                        .fontWeight(.bold)
                                        .foregroundColor(TAROColors.text)
                                    Text(TAROAppInfo.founderRole)
                                        .font(TAROTypography.caption)
                                        .foregroundColor(TAROColors.text.opacity(0.55))
                                }
                                
                                Spacer()
                            }
                            .padding(TAROSpacing.md)
                        }
                        
                        // DEVELOPMENT TEAM Section
                        creditGroup(title: "DEVELOPMENT TEAM") {
                            VStack(spacing: 0) {
                                ForEach(Array(TAROAppInfo.teamMembers.enumerated()), id: \.offset) { index, member in
                                    HStack(spacing: TAROSpacing.md) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.black.opacity(0.04))
                                                .frame(width: 38, height: 38)
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 15))
                                                .foregroundColor(TAROColors.text.opacity(0.6))
                                        }
                                        
                                        Text(member)
                                            .font(TAROTypography.body)
                                            .foregroundColor(TAROColors.text)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, TAROSpacing.md)
                                    .padding(.vertical, TAROSpacing.sm)
                                    
                                    if index < TAROAppInfo.teamMembers.count - 1 {
                                        Divider().padding(.leading, 64)
                                    }
                                }
                            }
                        }
                        
                        // LINKS & INFO Section
                        creditGroup(title: "PROJECT & PRIVACY") {
                            VStack(spacing: 0) {
                                if let url = URL(string: TAROAppInfo.githubURL) {
                                    Link(destination: url) {
                                        HStack(spacing: TAROSpacing.md) {
                                            Image(systemName: "link")
                                                .font(.system(size: 16))
                                                .foregroundColor(TAROColors.primaryPink)
                                            
                                            Text("GitHub Repository")
                                                .font(TAROTypography.body)
                                                .foregroundColor(TAROColors.text)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(TAROColors.gray.opacity(0.7))
                                        }
                                        .frame(minHeight: 44)
                                        .padding(.horizontal, TAROSpacing.md)
                                        .padding(.vertical, TAROSpacing.xs)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Divider().padding(.leading, TAROSpacing.md)
                                }
                                
                                HStack(spacing: TAROSpacing.md) {
                                    Image(systemName: "lock.shield")
                                        .font(.system(size: 16))
                                        .foregroundColor(TAROColors.primaryPink)
                                    
                                    Text(TAROAppInfo.privacyNotice)
                                        .font(TAROTypography.caption)
                                        .foregroundColor(TAROColors.text.opacity(0.6))
                                    
                                    Spacer()
                                }
                                .frame(minHeight: 44)
                                .padding(.horizontal, TAROSpacing.md)
                                .padding(.vertical, TAROSpacing.xs)
                            }
                        }
                        
                        // Footer
                        VStack(spacing: 4) {
                            Text(TAROAppInfo.copyright)
                                .font(TAROTypography.caption)
                                .foregroundColor(TAROColors.text.opacity(0.45))
                            Text(TAROAppInfo.tagline)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(TAROColors.text.opacity(0.35))
                        }
                        .padding(.top, TAROSpacing.md)
                        .padding(.bottom, TAROSpacing.xxl)
                    }
                    .padding(.horizontal, TAROSpacing.lg)
                    .frame(maxWidth: 650)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Group Card Helper
    
    private func creditGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: TAROSpacing.xs) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(TAROColors.text.opacity(0.45))
                .padding(.horizontal, 4)
                .tracking(0.5)
            
            VStack(spacing: 0) {
                content()
            }
            .background(TAROColors.white)
            .cornerRadius(TARORadius.md)
            .applyTAROShadow(.soft)
        }
    }
}

#Preview {
    AboutTAROBOOTHView(navigationPath: .constant(NavigationPath()))
}
