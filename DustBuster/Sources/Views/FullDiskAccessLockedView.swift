import SwiftUI

struct FullDiskAccessLockedView: View {
    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "lock.shield")
                .font(.system(size: 44))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.orange)

            VStack(spacing: DS.Spacing.sm) {
                Text("Tam Disk Erişimi gerekli")
                    .font(.title2.weight(.semibold))
                Text("DustBuster'ın önbellek, günlük ve uygulama klasörlerini okuyabilmesi için Sistem Ayarları › Gizlilik ve Güvenlik › Tam Disk Erişimi bölümünden izin vermeniz gerekir.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 440)
            }

            Button {
                PermissionManager.openFullDiskAccessSettings()
            } label: {
                Label("Sistem Ayarları'nı Aç", systemImage: "arrow.up.forward.app")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Text("İzni verdikten sonra DustBuster'ı kapatıp yeniden açın.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DS.Spacing.xxl)
    }
}
