import SwiftUI

struct PhotoArrangeView: View {
    @Binding var navigationPath: NavigationPath
    @State private var items = [1, 2, 3, 4]
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: TAROSpacing.lg) {
                Text("Arrange your photos")
                    .font(TAROTypography.heading2)
                    .foregroundColor(TAROColors.text)
                    .padding(.top, TAROSpacing.lg)
                
                // Mock drag/drop view (using buttons to swap for simplicity in UI mock)
                VStack(spacing: TAROSpacing.md) {
                    ForEach(0..<items.count, id: \.self) { index in
                        HStack {
                            Text("\(index + 1)")
                                .font(TAROTypography.heading2)
                                .foregroundColor(TAROColors.primaryPink)
                                .frame(width: 40)
                            
                            Rectangle()
                                .fill(TAROColors.gray.opacity(0.3))
                                .frame(height: 100)
                                .cornerRadius(TARORadius.md)
                                .overlay(
                                    Text("Photo \(items[index])")
                                        .foregroundColor(TAROColors.text.opacity(0.5))
                                )
                            
                            VStack(spacing: TAROSpacing.sm) {
                                Button(action: { moveUp(index: index) }) {
                                    Image(systemName: "chevron.up.circle.fill")
                                        .foregroundColor(index > 0 ? TAROColors.text : TAROColors.gray)
                                        .font(.title2)
                                }
                                .disabled(index == 0)
                                
                                Button(action: { moveDown(index: index) }) {
                                    Image(systemName: "chevron.down.circle.fill")
                                        .foregroundColor(index < items.count - 1 ? TAROColors.text : TAROColors.gray)
                                        .font(.title2)
                                }
                                .disabled(index == items.count - 1)
                            }
                        }
                        .padding(.horizontal, TAROSpacing.lg)
                    }
                }
                
                Spacer()
                
                TAROPrimaryButton(title: "Next") {
                    navigationPath.append(AppRoute.crop) // Or Review if crop isn't forced
                }
                .padding(.horizontal, TAROSpacing.lg)
                .padding(.bottom, TAROSpacing.xl)
            }
        }
        .navigationTitle("Arrange")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func moveUp(index: Int) {
        guard index > 0 else { return }
        items.swapAt(index, index - 1)
    }
    
    private func moveDown(index: Int) {
        guard index < items.count - 1 else { return }
        items.swapAt(index, index + 1)
    }
}

#Preview {
    PhotoArrangeView(navigationPath: .constant(NavigationPath()))
}
