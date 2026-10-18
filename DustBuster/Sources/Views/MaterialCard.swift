import SwiftUI
import AppKit

struct MaterialCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .adaptiveGlassEffect(in: .rect(cornerRadius: 16))
    }
}

extension View {
    func materialCard() -> some View {
        self.modifier(MaterialCardModifier())
    }
}

// A reusable card view component
struct MaterialCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            content
        }
        .materialCard()
    }
}
