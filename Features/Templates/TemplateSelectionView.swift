import SwiftUI

struct TemplateSelectionView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var currentSession: BoothSession
    
    @State private var selectedCategory: String = "All"
    @State private var pendingSelectedTemplateId: String? = nil
    
    init(navigationPath: Binding<NavigationPath>, currentSession: Binding<BoothSession> = .constant(BoothSession())) {
        self._navigationPath = navigationPath
        self._currentSession = currentSession
    }
    
    let categories = ["All", "Classic", "Cute", "Film", "Creative"]
    
    var filteredTemplates: [BoothTemplate] {
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
                // Top Custom Header
                headerBar
                
                // Title and Subtitle
                VStack(spacing: TAROSpacing.xs) {
                    Text("Choose your booth")
                        .font(TAROTypography.heading1)
                        .foregroundColor(TAROColors.text)
                    
                    Text("Pick a layout for your little moments.")
                        .font(TAROTypography.subtitle)
                        .foregroundColor(TAROColors.text.opacity(0.6))
                }
                .padding(.top, TAROSpacing.sm)
                .padding(.bottom, TAROSpacing.md)
                
                // Category Filter Chips
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
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.vertical, TAROSpacing.xs)
                }
                
                // Templates Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: TAROSpacing.md), GridItem(.flexible(), spacing: TAROSpacing.md)],
                        spacing: TAROSpacing.md
                    ) {
                        ForEach(filteredTemplates) { template in
                            TemplateCard(
                                template: template,
                                isSelected: pendingSelectedTemplateId == template.id
                            ) {
                                // Local pending selection only - do NOT mutate session yet
                                pendingSelectedTemplateId = template.id
                            }
                        }
                    }
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.top, TAROSpacing.md)
                    .padding(.bottom, 100) // Space for bottom CTA
                }
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
            
            // Bottom Continue CTA
            VStack {
                Spacer()
                
                TAROPrimaryButton(title: "CONTINUE") {
                    // Commit pending selection to session only when CONTINUE is pressed
                    if let selectedId = pendingSelectedTemplateId,
                       let chosen = MockData.templates.first(where: { $0.id == selectedId }) {
                        currentSession.selectedTemplate = chosen
                        navigationPath.append(AppRoute.sourcePicker)
                    }
                }
                .opacity(pendingSelectedTemplateId == nil ? 0.4 : 1.0)
                .disabled(pendingSelectedTemplateId == nil)
                .padding(.horizontal, TAROSpacing.lg)
                .padding(.bottom, TAROSpacing.xl)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if pendingSelectedTemplateId == nil, let current = currentSession.selectedTemplate {
                pendingSelectedTemplateId = current.id
            }
        }
    }
    
    private var headerBar: some View {
        HStack {
            TAROIconButton(icon: TAROIcons.back, size: 20, color: TAROColors.text) {
                navigationPath.removeLast()
            }
            Spacer()
        }
        .padding(.horizontal, TAROSpacing.lg)
        .padding(.top, TAROSpacing.xs)
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let template: BoothTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: TAROSpacing.sm) {
                // Visual Mock Preview
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: TARORadius.md)
                        .fill(isSelected ? TAROColors.softBlush.opacity(0.3) : TAROColors.cream)
                        .aspectRatio(3/4, contentMode: .fit)
                        .overlay(
                            TemplateMiniPreview(layoutType: template.layoutType, isSelected: isSelected)
                                .padding(TAROSpacing.sm)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: TARORadius.md)
                                .stroke(isSelected ? TAROColors.primaryPink : Color.clear, lineWidth: 2.5)
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(TAROColors.primaryPink)
                            .padding(8)
                    }
                }
                
                // Details
                VStack(spacing: 2) {
                    Text(template.name)
                        .font(TAROTypography.subtitle)
                        .fontWeight(.semibold)
                        .foregroundColor(TAROColors.text)
                    
                    Text("\(template.photoCount) \(template.photoCount == 1 ? "photo" : "photos")")
                        .font(TAROTypography.caption)
                        .foregroundColor(TAROColors.text.opacity(0.55))
                }
            }
            .padding(TAROSpacing.sm)
            .background(TAROColors.white)
            .cornerRadius(TARORadius.lg)
            .applyTAROShadow(isSelected ? .medium : .soft)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mini Layout Preview

private struct TemplateMiniPreview: View {
    let layoutType: BoothLayoutType
    let isSelected: Bool
    
    private var cellColor: Color {
        isSelected ? TAROColors.strongPink.opacity(0.7) : TAROColors.cameraBackground.opacity(0.2)
    }
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                switch layoutType {
                case .singlePhoto:
                    RoundedRectangle(cornerRadius: 3)
                        .fill(cellColor)
                        .frame(width: w * 0.75, height: h * 0.8)
                    
                case .verticalFourCut:
                    VStack(spacing: 3) {
                        ForEach(1...4, id: \.self) { num in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cellColor)
                                .overlay(
                                    Text("\(num)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(isSelected ? .white : TAROColors.text.opacity(0.4))
                                )
                        }
                    }
                    .frame(width: w * 0.55)
                    
                case .verticalThreeCut:
                    VStack(spacing: 4) {
                        ForEach(1...3, id: \.self) { num in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cellColor)
                                .overlay(
                                    Text("\(num)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(isSelected ? .white : TAROColors.text.opacity(0.4))
                                )
                        }
                    }
                    .frame(width: w * 0.6)
                    
                case .gridTwoByTwo:
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            cellView(num: "1")
                            cellView(num: "2")
                        }
                        HStack(spacing: 4) {
                            cellView(num: "3")
                            cellView(num: "4")
                        }
                    }
                    .frame(width: w * 0.8, height: h * 0.8)
                    
                case .filmStrip:
                    VStack(spacing: 3) {
                        // Sprocket holes simulation top & bottom
                        HStack(spacing: 3) {
                            ForEach(0..<5) { _ in
                                Rectangle()
                                    .fill(TAROColors.text.opacity(0.25))
                                    .frame(width: 4, height: 4)
                            }
                        }
                        
                        VStack(spacing: 3) {
                            ForEach(1...3, id: \.self) { num in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(cellColor)
                                    .frame(height: (h - 32) / 3)
                            }
                        }
                        
                        HStack(spacing: 3) {
                            ForEach(0..<5) { _ in
                                Rectangle()
                                    .fill(TAROColors.text.opacity(0.25))
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                    .frame(width: w * 0.65)
                    
                case .multiCollage:
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(cellColor)
                            .frame(height: h * 0.42)
                        HStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cellColor)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cellColor)
                        }
                        HStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cellColor)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cellColor)
                        }
                    }
                    .frame(width: w * 0.8)
                }
            }
            .frame(width: w, height: h)
        }
    }
    
    private func cellView(num: String) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(cellColor)
            .overlay(
                Text(num)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(isSelected ? .white : TAROColors.text.opacity(0.4))
            )
    }
}

#Preview {
    TemplateSelectionView(
        navigationPath: .constant(NavigationPath()),
        currentSession: .constant(BoothSession())
    )
}
