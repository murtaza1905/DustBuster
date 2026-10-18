import SwiftUI

struct FullDiskAccessLockedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Tam Disk Erişimi gerekli")
                .font(.title)
                .bold()
            
            Text("DustBuster'ın sisteminizi analiz edebilmesi için macOS Ayarlar > Gizlilik ve Güvenlik > Tam Disk Erişimi bölümünden uygulamaya izin vermeniz gerekiyor.")
                .multilineTextAlignment(.center)
            
            Button("Ayarları Aç") {
                PermissionManager.openFullDiskAccessSettings()
            }
            
            Text("İzni verdikten sonra DustBuster'ı kapatıp yeniden açın.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
}
