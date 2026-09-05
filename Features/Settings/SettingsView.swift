import SwiftUI

struct SettingsView: View {
    @Binding var navigationPath: NavigationPath
    
    // Settings local state foundation (Step 9)
    @State private var options = SettingsOptions()
    @State private var showCountdownPicker = false
    @State private var showFilmPicker = false
    @State private var showThemePicker = false
    @State private var showDateFormatPicker = false
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar with Back Button
                HStack {
                    TAROIconButton(icon: TAROIcons.back) {
                        navigationPath.removeLast()
                    }
                    
                    Spacer()
                    
                    Text("Settings")
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
                        // CAMERA Section
                        sectionBlock(title: "CAMERA") {
                            VStack(spacing: 0) {
                                settingsToggleRow(
                                    title: "Mirror Selfie",
                                    isOn: $options.mirrorSelfie
                                )
                                
                                Divider().padding(.leading, TAROSpacing.md)
                                
                                settingsValueRow(
                                    title: "Countdown",
                                    value: options.countdown.displayName
                                ) {
                                    showCountdownPicker = true
                                }
                                
                                Divider().padding(.leading, TAROSpacing.md)
                                
                                settingsValueRow(
                                    title: "Default Film",
                                    value: filmPresetDisplayName(for: options.defaultFilmPresetID)
                                ) {
                                    showFilmPicker = true
                                }
                            }
                        }
                        
                        // PHOTO Section
                        sectionBlock(title: "PHOTO") {
                            VStack(spacing: 0) {
                                settingsToggleRow(
                                    title: "Auto Save",
                                    isOn: $options.autoSave
                                )
                                
                                Divider().padding(.leading, TAROSpacing.md)
                                
                                settingsToggleRow(
                                    title: "High Resolution",
                                    isOn: $options.highResolution
                                )
                            }
                        }
                        
                        // APPEARANCE Section
                        sectionBlock(title: "APPEARANCE") {
                            VStack(spacing: 0) {
                                settingsValueRow(
                                    title: "Theme",
                                    value: options.theme.displayName
                                ) {
                                    showThemePicker = true
                                }
                                
                                Divider().padding(.leading, TAROSpacing.md)
                                
                                settingsValueRow(
                                    title: "Date Format",
                                    value: options.dateFormat.displayName
                                ) {
                                    showDateFormatPicker = true
                                }
                            }
                        }
                        
                        // SUPPORT Section
                        sectionBlock(title: "SUPPORT") {
                            VStack(spacing: 0) {
                                settingsInfoRow(
                                    title: "Help & Feedback",
                                    subtitle: "Contact via GitHub repo"
                                )
                                
                                Divider().padding(.leading, TAROSpacing.md)
                                
                                settingsValueRow(
                                    title: "About TAROBOOTH",
                                    value: "v\(TAROAppInfo.version)"
                                ) {
                                    navigationPath.append(AppRoute.about)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.top, TAROSpacing.sm)
                    .padding(.bottom, TAROSpacing.xxl)
                    .frame(maxWidth: 650)
                }
            }
        }
        .navigationBarHidden(true)
        .confirmationDialog("Select Countdown", isPresented: $showCountdownPicker, titleVisibility: .visible) {
            ForEach(CountdownOption.allCases, id: \.self) { opt in
                Button(opt.displayName) {
                    options.countdown = opt
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Default Film Preset", isPresented: $showFilmPicker, titleVisibility: .visible) {
            ForEach(DefaultFilmOption.allCases, id: \.self) { opt in
                Button(opt.displayName) {
                    options.defaultFilmPresetID = opt.rawValue
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Appearance Theme", isPresented: $showThemePicker, titleVisibility: .visible) {
            ForEach(ThemeOption.allCases, id: \.self) { opt in
                Button(opt.displayName) {
                    options.theme = opt
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Date Format", isPresented: $showDateFormatPicker, titleVisibility: .visible) {
            ForEach(DateFormatOption.allCases, id: \.self) { opt in
                Button(opt.displayName) {
                    options.dateFormat = opt
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Row Helpers
    
    private func sectionBlock<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
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
    
    private func settingsToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(TAROTypography.body)
                .foregroundColor(TAROColors.text)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(TAROColors.strongPink)
        }
        .frame(minHeight: 44)
        .padding(.horizontal, TAROSpacing.md)
        .padding(.vertical, TAROSpacing.xs)
    }
    
    private func settingsValueRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(TAROTypography.body)
                    .foregroundColor(TAROColors.text)
                
                Spacer()
                
                Text(value)
                    .font(TAROTypography.body)
                    .foregroundColor(TAROColors.text.opacity(0.5))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(TAROColors.gray.opacity(0.7))
            }
            .frame(minHeight: 44)
            .padding(.horizontal, TAROSpacing.md)
            .padding(.vertical, TAROSpacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func settingsInfoRow(title: String, subtitle: String) -> some View {
        HStack {
            Text(title)
                .font(TAROTypography.body)
                .foregroundColor(TAROColors.text)
            
            Spacer()
            
            Text(subtitle)
                .font(TAROTypography.caption)
                .foregroundColor(TAROColors.text.opacity(0.4))
        }
        .frame(minHeight: 44)
        .padding(.horizontal, TAROSpacing.md)
        .padding(.vertical, TAROSpacing.xs)
    }
    
    private func filmPresetDisplayName(for id: String) -> String {
        MockData.filmPresets.first(where: { $0.id == id })?.displayName ?? id.capitalized
    }
}

#Preview {
    SettingsView(navigationPath: .constant(NavigationPath()))
}
