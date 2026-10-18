// Sources/Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var permissionVM: AppPermissionViewModel
    
    // Uygulama sürümü (Info.plist'ten okur)
    private var appVersion: String {
        let version = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "1.0"
        
        let build = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "1"
        
        return "Sürüm \(version) (Build \(build))"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Güvenlik ve İzinler
                MaterialCard(title: "Güvenlik ve İzinler") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DustBuster, sadece önbellek, log ve büyük geçici dosyaları temizler. Şifreler, tarayıcı geçmişi, yer işaretleri ve kişisel belgelerine dokunmaz.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: permissionVM.hasFullDiskAccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(permissionVM.hasFullDiskAccess ? .green : .orange)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tam Disk Erişimi")
                                    .font(.subheadline)
                                    .bold()
                                
                                Text(permissionVM.hasFullDiskAccess ? "Durum: İzin verildi" : "Durum: İzin yok")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("Bazı klasörlere erişilemiyorsa Sistem Ayarları > Güvenlik ve Gizlilik > Tam Disk Erişimi bölümünden DustBuster’a izin verebilirsiniz.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer()
                            
                            Button("Ayarları Aç") {
                                PermissionManager.openFullDiskAccessSettings()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                // MARK: - Hakkında DustBuster
                MaterialCard(title: "Hakkında DustBuster") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DustBuster")
                                    .font(.title3)
                                    .bold()
                                
                                Text("macOS için güvenli sistem temizleyici.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Geliştirici: Murat Onurcu", systemImage: "person.fill")
                                .font(.subheadline)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "envelope")
                                Link(
                                    "muratonurcu@outlook.com",
                                    destination: URL(string: "mailto:muratonurcu@outlook.com")!
                                )
                                .font(.subheadline)
                            }
                            
                            Text(appVersion)
                                .font(.subheadline)
                                .padding(.top, 4)
                            
                            Text("Tüm işlemler sadece bu cihazda çalışır; hiçbir dosya veya sistem bilgisi uzak sunuculara gönderilmez.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Logları Dışa Aktar")
                                    .font(.subheadline)
                                    .bold()
                                
                                Text("Son 7 günün loglarını ve temel sistem bilgilerini cihazına kaydedebilirsin. Loglar sadece bu cihazda saklanır; otomatik gönderim yoktur.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Button("Logları Dışa Aktar") {
                                    LogManager.shared.exportLogs()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
