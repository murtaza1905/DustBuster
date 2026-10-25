import AppKit

/// Standart macOS "Hakkında" penceresini uygulamanın künyesiyle açar.
/// Sürüm, yapı numarası ve telif satırı Info.plist'ten AppKit tarafından okunur.
enum AboutPanel {

    static let author = "Murat Onurcu"
    static let email = "muratonurcu@outlook.com"
    static let repository = URL(string: "https://github.com/murtaza1905/DustBuster")!
    static let thirdPartyNotices = URL(string: "https://github.com/murtaza1905/DustBuster/blob/main/THIRD_PARTY_NOTICES.md")!

    @MainActor
    static func show() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(options: [.credits: credits()])
    }

    private static func credits() -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.paragraphSpacing = 3

        let base: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraph
        ]
        let secondary: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
            .foregroundColor: NSColor.secondaryLabelColor,
            .paragraphStyle: paragraph
        ]

        let text = NSMutableAttributedString()

        func line(_ string: String, attributes: [NSAttributedString.Key: Any], link: URL? = nil) {
            var attrs = attributes
            if let link { attrs[.link] = link }
            text.append(NSAttributedString(string: string + "\n", attributes: attrs))
        }

        line("macOS için gizlilik odaklı temizleyici ve uygulama kaldırıcı.", attributes: secondary)
        line("\nGeliştirici: " + author, attributes: base)
        line(email, attributes: base, link: URL(string: "mailto:\(email)"))
        line("Kaynak kod ve hata bildirimi: GitHub", attributes: base, link: repository)
        line("\nMIT Lisansı ile açık kaynak.", attributes: secondary)
        line("Kalıntı veritabanı Homebrew Cask tanımlarından türetilir (BSD-2-Clause).", attributes: secondary, link: thirdPartyNotices)
        return text
    }
}
