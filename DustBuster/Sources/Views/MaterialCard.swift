import SwiftUI

extension View {
    func materialCard() -> some View {
        self.cardSurface()
    }
}

/// Başlıklı içerik kartı.
struct MaterialCard<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    var tint: Color = .accentColor
    let content: Content

    init(title: String, subtitle: String? = nil, systemImage: String? = nil, tint: Color = .accentColor,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.lg) {
            CardHeader(title, subtitle: subtitle, systemImage: systemImage, tint: tint)
            content
        }
        .cardSurface()
    }
}
