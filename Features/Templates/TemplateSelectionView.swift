import SwiftUI

struct TemplateSelectionView: View {
    @Binding var navigationPath: NavigationPath
    @State private var selectedCategory: String = "All"
    @State private var selectedTemplateId: String? = nil
    
    let categories = ["All", "Classic", "Film", "Cute"]
    
    var filteredTemplates: [Template] {
        if selectedCategory == "All" {
            return MockData.templates
        } else {
            return MockData.templates.filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Category Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: TAROSpacing.sm) {
                        ForEach(categories, id: \.self) { category in
                            TAROChip(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, TAROSpacing.md)
                    .padding(.vertical, TAROSpacing.md)
                }
                
                // Templates Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TAROSpacing.md) {
                        ForEach(filteredTemplates) { template in
                            TemplateCard(
                                template: template,
                                isSelected: selectedTemplateId == template.id
                            ) {
                                selectedTemplateId = template.id
                            }
                        }
                    }
                    .padding(.horizontal, TAROSpacing.md)
                    .padding(.bottom, 100) // Space for next button
                }
            }
            
            // Next Button
            VStack {
                Spacer()
                TAROPrimaryButton(title: "Next") {
                    if selectedTemplateId != nil {
                        navigationPath.append(AppRoute.sourcePicker)
                    }
                }
                .opacity(selectedTemplateId == nil ? 0.5 : 1.0)
                .disabled(selectedTemplateId == nil)
                .padding(.horizontal, TAROSpacing.lg)
                .padding(.bottom, TAROSpacing.xl)
            }
        }
        .navigationTitle("Select Template")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TemplateCard: View {
    let template: Template
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: TAROSpacing.sm) {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(TAROColors.cream)
                        .aspectRatio(2/3, contentMode: .fit)
                        .cornerRadius(TARORadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: TARORadius.md)
                                .stroke(isSelected ? TAROColors.primaryPink : TAROColors.gray, lineWidth: isSelected ? 3 : 1)
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(TAROColors.primaryPink)
                            .padding(8)
                            .background(Circle().fill(Color.white).padding(8))
                    }
                }
                
                Text(template.name)
                    .font(TAROTypography.subtitle)
                    .foregroundColor(TAROColors.text)
            }
            .padding(TAROSpacing.sm)
            .background(TAROColors.white)
            .cornerRadius(TARORadius.lg)
            .applyTAROShadow(.soft)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

#Preview {
    TemplateSelectionView(navigationPath: .constant(NavigationPath()))
}
