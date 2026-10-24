import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var permissionVM: AppPermissionViewModel
    @StateObject var viewModel = DashboardViewModel()
    @State private var showFullDiskAccessAlert = false

    private var canScan: Bool {
        permissionVM.hasFullDiskAccess && !viewModel.isScanning && !viewModel.isCleaning
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.xl) {
                PageTitle(title: "Panel", subtitle: "Sistem durumu ve temizlik")
                usageCards
                cleaningCard
            }
            .pageLayout()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: scan) {
                    Label("Sistemi Tara", systemImage: "magnifyingglass")
                }
                .disabled(!canScan)
                .help("Önbellek, günlük ve tarayıcı önbelleklerini tara")
            }
        }
        .sheet(isPresented: $viewModel.showCleanerReview) {
            CleanerReviewView(viewModel: viewModel)
        }
        .alert("Tam Disk Erişimi olmadan sistem temizliği yapılamaz.",
               isPresented: $showFullDiskAccessAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text("Sistem Ayarları › Gizlilik ve Güvenlik › Tam Disk Erişimi bölümünden DustBuster'a izin verin.")
        }
    }

    private func scan() {
        if permissionVM.hasFullDiskAccess {
            viewModel.scanSystem()
        } else {
            showFullDiskAccessAlert = true
        }
    }

    // MARK: - Kullanım kartları

    private var usageCards: some View {
        HStack(spacing: DS.Spacing.lg) {
            UsageCard(
                title: "Bellek",
                systemImage: "memorychip",
                percentage: viewModel.ramUsage,
                primaryColor: .green,
                usedText: "Kullanılan: \(viewModel.systemMonitor.memoryUsedString)",
                freeText: "Boş: \(viewModel.systemMonitor.memoryFreeString)",
                totalText: "Toplam: \(viewModel.systemMonitor.memoryTotalString)"
            )

            UsageCard(
                title: "Disk",
                systemImage: "internaldrive",
                percentage: viewModel.diskUsage,
                primaryColor: .yellow,
                usedText: "Kullanılan: \(viewModel.systemMonitor.diskUsedString)",
                freeText: "Boş: \(viewModel.systemMonitor.diskFreeString)",
                totalText: "Toplam: \(viewModel.systemMonitor.diskTotalString)"
            )

            UsageCard(
                title: "İşlemci",
                systemImage: "cpu",
                percentage: viewModel.cpuUsage,
                primaryColor: .orange,
                usedText: viewModel.systemMonitor.cpuBusyString,
                freeText: viewModel.systemMonitor.cpuIdleString,
                totalText: viewModel.systemMonitor.cpuTotalString
            )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Temizlik kartı

    private var cleaningCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.lg) {
            CardHeader("Sistem Temizliği",
                       subtitle: "Tarayıcı önbellekleri, uygulama önbellekleri ve kullanıcı günlükleri",
                       systemImage: "sparkles",
                       tint: .accentColor) {
                accessStatus
            }

            Divider()

            HStack(alignment: .center, spacing: DS.Spacing.lg) {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(permissionVM.hasFullDiskAccess
                         ? "Tarama hiçbir şeyi silmez; sonuçları gözden geçirip seçtiklerini Çöp Kutusu'na taşırsın."
                         : "Tam Disk Erişimi olmadan önbellek ve günlük klasörleri okunamaz.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if viewModel.lastTrashTransaction != nil {
                        Label("Son temizlik: \(viewModel.lastCleanedSize) Çöp Kutusu'na taşındı",
                              systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                }

                Spacer(minLength: DS.Spacing.lg)

                Button(action: scan) {
                    HStack(spacing: DS.Spacing.sm) {
                        if viewModel.isScanning {
                            ProgressView().controlSize(.small)
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                        Text(viewModel.isScanning ? "Taranıyor…" : "Sistemi Tara")
                    }
                    .frame(minWidth: 140)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!canScan)
            }
        }
        .cardSurface()
    }

    private var accessStatus: some View {
        HStack(spacing: 6) {
            Image(systemName: permissionVM.hasFullDiskAccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .symbolRenderingMode(.hierarchical)
            Text(permissionVM.hasFullDiskAccess ? "Tam Disk Erişimi verildi" : "Tam Disk Erişimi gerekli")
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(permissionVM.hasFullDiskAccess ? Color.green : Color.orange)
        .statusCapsule()
        .onTapGesture {
            if !permissionVM.hasFullDiskAccess { viewModel.openSettings() }
        }
    }
}

struct UsageCard: View {
    let title: String
    var systemImage: String? = nil
    let percentage: Double
    let primaryColor: Color
    let usedText: String
    let freeText: String
    let totalText: String

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack(spacing: DS.Spacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(primaryColor)
                }
                Text(title)
                    .font(.headline)
                Spacer()
            }

            HStack(alignment: .center, spacing: DS.Spacing.lg) {
                UsageRingView(percentage: percentage, primaryColor: primaryColor)
                UsageDetailsView(usedText: usedText, freeText: freeText, totalText: totalText)
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity)
        .cardSurface()
    }
}

struct UsageRingView: View {
    let percentage: Double
    let primaryColor: Color

    private let size: CGFloat = 84
    private let lineWidth: CGFloat = 10

    private var clamped: Double { min(max(percentage, 0.0), 1.0) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: lineWidth)

            Circle()
                .trim(from: 0.0, to: CGFloat(clamped))
                .stroke(primaryColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut(duration: 0.4), value: percentage)

            Text(String(format: "%.0f%%", clamped * 100.0))
                .font(.title3.weight(.semibold))
                .monospacedDigit()
        }
        .frame(width: size, height: size)
    }
}

struct UsageDetailsView: View {
    let usedText: String
    let freeText: String
    let totalText: String

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(usedText)
            Text(freeText)
            Text(totalText)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .monospacedDigit()
        .lineLimit(1)
    }
}
