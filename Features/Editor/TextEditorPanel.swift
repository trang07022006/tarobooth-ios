import SwiftUI

struct TextEditorPanel: View {
    @State private var textInput = ""
    @State private var showDate = true
    
    var body: some View {
        VStack(spacing: TAROSpacing.sm) {
            TextField("Type your message...", text: $textInput)
                .font(TAROTypography.body)
                .padding()
                .background(TAROColors.background)
                .cornerRadius(TARORadius.md)
                .padding(.horizontal, TAROSpacing.md)
            
            HStack {
                Toggle("Show Date", isOn: $showDate)
                    .font(TAROTypography.subtitle)
                    .tint(TAROColors.strongPink)
            }
            .padding(.horizontal, TAROSpacing.md)
        }
    }
}

#Preview {
    TextEditorPanel()
}
