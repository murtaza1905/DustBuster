import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var permissionVM: AppPermissionViewModel

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        Form {
            Section {
                LabeledContent {
                    HStack(spacing: DS.Spacing.sm) {
                        Tag(text: permissionVM.hasFullDiskAccess ? "Verildi" : "Verilmedi",
                            tone: permissionVM.hasFullDiskAccess ? .success : .warning,
                            systemImage: permissionVM.hasFullDiskAccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        Button("Sistem Ayarları'nı Aç") {
                            PermissionManager.openFullDiskAccessSettings()
                        }
                    }
                } label: {
                    Text("Tam Disk Erişimi")
                    Text("Önbellek, günlük ve uygulama klasörlerini okumak için gerekir. Sistem Ayarları › Gizlilik ve Güvenlik › Tam Disk Erişimi")
                }
            } header: {
                Text("İzinler")
            } footer: {
                Text("DustBuster yalnızca önbellek, günlük ve uygulama kalıntılarını listeler; şifrelere, tarayıcı geçmişine, yer işaretlerine ve belgelere dokunmaz. Silinen her şey Çöp Kutusu'na taşınır.")
            }

            Section("Gizlilik") {
                LabeledContent("Ağ erişimi", value: "Yok")
                LabeledContent("Homebrew veritabanı", value: "Uygulamaya gömülü, çevrimdışı")
                LabeledContent("Günlükler", value: "Yalnızca bu cihazda")
                LabeledContent {
                    Button("Dışa Aktar…") {
                        LogManager.shared.exportLogs()
                    }
                } label: {
                    Text("Tanılama günlükleri")
                    Text("Son 7 günün kayıtları ve temel sistem bilgisi; kullanıcı adı ve yol bilgileri temizlenir.")
                }
            }

            Section("Hakkında") {
                LabeledContent("Sürüm", value: appVersion)
                LabeledContent("Geliştirici", value: "Murat Onurcu")
                LabeledContent("İletişim") {
                    Link("muratonurcu@outlook.com", destination: URL(string: "mailto:muratonurcu@outlook.com")!)
                }
                LabeledContent("Kaynak kod") {
                    Link("github.com/murtaza1905/DustBuster-macOS", destination: URL(string: "https://github.com/murtaza1905/DustBuster-macOS")!)
                }
                LabeledContent("Lisans", value: "MIT")
                LabeledContent {
                    Link("Homebrew Cask verisi (BSD-2-Clause)", destination: URL(string: "https://github.com/murtaza1905/DustBuster-macOS/blob/main/THIRD_PARTY_NOTICES.md")!)
                } label: {
                    Text("Üçüncü taraf bildirimleri")
                    Text("Kalıntı veritabanı Homebrew Cask tanımlarından türetilir.")
                }
            }
        }
        .formStyle(.grouped)
    }
}
