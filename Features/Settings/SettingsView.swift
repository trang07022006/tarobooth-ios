import SwiftUI

struct SettingsView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: TAROSpacing.lg) {
                    // CAMERA Section
                    TAROSectionHeader(title: "CAMERA")
                    TAROCard {
                        VStack(spacing: 0) {
                            SettingsRow(title: "Mirror Selfie", hasToggle: true, isOn: .constant(true))
                            Divider().padding(.leading, TAROSpacing.md)
                            SettingsRow(title: "Countdown", value: "3s")
                            Divider().padding(.leading, TAROSpacing.md)
                            SettingsRow(title: "Default Film", value: "Original")
                        }
                    }
                    
                    // PHOTO Section
                    TAROSectionHeader(title: "PHOTO")
                    TAROCard {
                        VStack(spacing: 0) {
                            SettingsRow(title: "Save to Photos", hasToggle: true, isOn: .constant(true))
                            Divider().padding(.leading, TAROSpacing.md)
                            SettingsRow(title: "High Resolution", hasToggle: true, isOn: .constant(false))
                        }
                    }
                    
                    // APPEARANCE Section
                    TAROSectionHeader(title: "APPEARANCE")
                    TAROCard {
                        VStack(spacing: 0) {
                            SettingsRow(title: "Theme", value: "Pink Soft")
                            Divider().padding(.leading, TAROSpacing.md)
                            SettingsRow(title: "Date Format", value: "YYYY.MM.DD")
                        }
                    }
                    
                    // SUPPORT Section
                    TAROSectionHeader(title: "SUPPORT")
                    TAROCard {
                        VStack(spacing: 0) {
                            SettingsRow(title: "Help & Feedback", action: {})
                            Divider().padding(.leading, TAROSpacing.md)
                            SettingsRow(title: "About TAROBOOTH", action: {
                                navigationPath.append(AppRoute.about)
                            })
                        }
                    }
                }
                .padding(TAROSpacing.md)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsRow: View {
    let title: String
    var value: String? = nil
    var hasToggle: Bool = false
    @Binding var isOn: Bool
    var action: (() -> Void)? = nil
    
    init(title: String, value: String? = nil, hasToggle: Bool = false, isOn: Binding<Bool> = .constant(false), action: (() -> Void)? = nil) {
        self.title = title
        self.value = value
        self.hasToggle = hasToggle
        self._isOn = isOn
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if let action = action {
                action()
            }
        }) {
            HStack {
                Text(title)
                    .font(TAROTypography.body)
                    .foregroundColor(TAROColors.text)
                
                Spacer()
                
                if hasToggle {
                    Toggle("", isOn: $isOn)
                        .labelsHidden()
                        .tint(TAROColors.strongPink)
                } else if let value = value {
                    Text(value)
                        .font(TAROTypography.body)
                        .foregroundColor(TAROColors.text.opacity(0.5))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(TAROColors.gray)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(TAROColors.gray)
                }
            }
            .padding(TAROSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(navigationPath: .constant(NavigationPath()))
}
