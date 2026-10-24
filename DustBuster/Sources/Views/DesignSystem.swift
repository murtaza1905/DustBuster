import SwiftUI
import AppKit

/// Tasarım sistemi: boşluk/köşe tokenları ve sürüme göre uyarlanan yüzeyler.
/// macOS 26 API'leri (Liquid Glass) yalnızca Xcode 26 SDK'sında vardır; `#if compiler(>=6.2)` çağrıyı
/// eski derleyiciden gizler, `#available` ise çalışma zamanında eski macOS'ta standart karşılığa düşer.
/// Cam yalnızca kontrol katmanında (yüzen eylem çubuğu, araç çubuğu) kullanılır; içerik kartları her
/// sürümde düz, gruplanmış yüzeydir (Apple HIG: içerik için cam kullanılmaz).
enum DS {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let control: CGFloat = 10
        static let inner: CGFloat = 12
        static let card: CGFloat = 20
    }

    static let contentMaxWidth: CGFloat = 960

    static var hasLiquidGlass: Bool {
        #if compiler(>=6.2)
        if #available(macOS 26.0, *) { return true }
        #endif
        return false
    }
}

// MARK: - İçerik kartı (her sürümde aynı görünüm)

struct CardSurface: ViewModifier {
    var padding: CGFloat = DS.Spacing.lg
    var radius: CGFloat = DS.Radius.card

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return content
            .padding(padding)
            .background(.fill.quaternary, in: shape)
            .overlay(shape.strokeBorder(.separator.opacity(0.6), lineWidth: 1))
    }
}

/// Kart içindeki ikincil yüzey (iç köşe eş merkezli: 12 pt)
struct InsetSurface: ViewModifier {
    var padding: CGFloat = DS.Spacing.md

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: DS.Radius.inner, style: .continuous)
        return content
            .padding(padding)
            .background(.fill.tertiary.opacity(0.6), in: shape)
    }
}

// MARK: - Kontrol katmanı (cam)

/// Yüzen eylem çubuğu: macOS 26'da Liquid Glass, eski sürümlerde materyal + gölge.
struct FloatingBarSurface: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
        #if compiler(>=6.2)
        if #available(macOS 26.0, *) {
            content
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.vertical, DS.Spacing.md)
                .glassEffect(.regular, in: shape)
        } else {
            legacy(content, shape: shape)
        }
        #else
        legacy(content, shape: shape)
        #endif
    }

    private func legacy(_ content: Content, shape: RoundedRectangle) -> some View {
        content
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.md)
            .background(.regularMaterial, in: shape)
            .overlay(shape.strokeBorder(.separator.opacity(0.6), lineWidth: 1))
            .shadow(color: .black.opacity(0.18), radius: 16, y: 6)
    }
}

/// Durum kapsülü (ör. "Tam Disk Erişimi verildi"): macOS 26'da cam, eski sürümde ince materyal.
struct StatusCapsuleSurface: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if compiler(>=6.2)
        if #available(macOS 26.0, *) {
            content.padding(.horizontal, DS.Spacing.md).padding(.vertical, 6).glassEffect(.regular, in: Capsule())
        } else {
            legacy(content)
        }
        #else
        legacy(content)
        #endif
    }

    private func legacy(_ content: Content) -> some View {
        content
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.separator.opacity(0.6), lineWidth: 1))
    }
}

extension View {
    func cardSurface(padding: CGFloat = DS.Spacing.lg) -> some View {
        modifier(CardSurface(padding: padding))
    }

    func insetSurface(padding: CGFloat = DS.Spacing.md) -> some View {
        modifier(InsetSurface(padding: padding))
    }

    func floatingBar() -> some View {
        modifier(FloatingBarSurface())
    }

    func statusCapsule() -> some View {
        modifier(StatusCapsuleSurface())
    }

    /// Geriye dönük: eski kart çağrıları artık düz yüzeye düşer.
    func adaptiveGlassEffect<S: Shape>(_ material: Material = .ultraThinMaterial, in shape: S) -> some View {
        self.background(.fill.quaternary, in: shape)
    }

    /// Kontrol katmanındaki düğmeler: macOS 26'da cam, eski sürümde kenarlıklı.
    @ViewBuilder
    func adaptiveGlassButtonStyle(prominent: Bool = false) -> some View {
        #if compiler(>=6.2)
        if #available(macOS 26.0, *) {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            adaptiveBorderedButtonStyle(prominent: prominent)
        }
        #else
        adaptiveBorderedButtonStyle(prominent: prominent)
        #endif
    }

    @ViewBuilder
    private func adaptiveBorderedButtonStyle(prominent: Bool) -> some View {
        if prominent {
            self.buttonStyle(.borderedProminent)
        } else {
            self.buttonStyle(.bordered)
        }
    }

    /// İçerik sayfalarının ortak düzeni: üst hizalı, sınırlı genişlik, 24 pt dış boşluk.
    func pageLayout() -> some View {
        self
            .frame(maxWidth: DS.contentMaxWidth, alignment: .leading)
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.vertical, DS.Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .top)
    }
}

// MARK: - Küçük bileşenler

/// Tonlu kapsül etiket: tür, kaynak, durum rozetleri.
struct Tag: View {
    enum Tone { case neutral, accent, success, warning, danger }

    let text: String
    var tone: Tone = .neutral
    var systemImage: String? = nil

    private var color: Color {
        switch tone {
        case .neutral: return .secondary
        case .accent: return .accentColor
        case .success: return .green
        case .warning: return .orange
        case .danger: return .red
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage).font(.caption2.weight(.semibold))
            }
            Text(text)
                .font(.caption2.weight(.medium))
                .lineLimit(1)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(color.opacity(tone == .neutral ? 0.12 : 0.15), in: Capsule())
        .foregroundStyle(tone == .neutral ? Color.primary.opacity(0.75) : color)
    }
}

/// Kart başlığı: ikon + başlık + isteğe bağlı sağ içerik.
struct CardHeader<Trailing: View>: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    var tint: Color = .accentColor
    @ViewBuilder var trailing: () -> Trailing

    init(_ title: String, subtitle: String? = nil, systemImage: String? = nil, tint: Color = .accentColor,
         @ViewBuilder trailing: @escaping () -> Trailing) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(tint)
                    .font(.title3)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: DS.Spacing.sm)
            trailing()
        }
    }
}

extension CardHeader where Trailing == EmptyView {
    init(_ title: String, subtitle: String? = nil, systemImage: String? = nil, tint: Color = .accentColor) {
        self.init(title, subtitle: subtitle, systemImage: systemImage, tint: tint) { EmptyView() }
    }
}

/// Bölüm başlığı (listelerde): başlık + sayaç + kısa not.
struct SectionTitle: View {
    let title: String
    var count: Int? = nil
    var note: String? = nil
    var tone: Tag.Tone = .neutral

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            if let count {
                Tag(text: "\(count)", tone: tone)
            }
            if let note {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, DS.Spacing.xs)
        .textCase(nil)
    }
}

/// Bilgi/uyarı şeridi.
struct NoticeBanner: View {
    enum Kind { case info, warning, danger, success }
    let text: String
    var kind: Kind = .info

    private var color: Color {
        switch kind {
        case .info: return .accentColor
        case .warning: return .orange
        case .danger: return .red
        case .success: return .green
        }
    }

    private var icon: String {
        switch kind {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.octagon.fill"
        case .success: return "checkmark.circle.fill"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: DS.Spacing.sm) {
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(DS.Spacing.md)
        .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: DS.Radius.inner, style: .continuous))
    }
}

/// Sayfa başlığı (başlık çubuğu gizli olduğu için içerikte).
struct PageTitle: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.title.weight(.bold))
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Boş durum.
struct EmptyState: View {
    let systemImage: String
    let title: String
    var message: String? = nil

    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .regular))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.xxl)
    }
}
