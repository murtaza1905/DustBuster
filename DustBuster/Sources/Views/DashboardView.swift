// Sources/Views/DashboardView.swift
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var permissionVM: AppPermissionViewModel
    @StateObject var viewModel = DashboardViewModel()
    @State private var showFullDiskAccessAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("Sistem Durumu")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    if !viewModel.permissionManager.hasFullDiskAccess {
                        Button(action: viewModel.openSettings) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Disk Erişimi Gerekli")
                            }
                        }
                        .adaptiveGlassButtonStyle(prominent: false)
                        .tint(.orange)
                    }
                }
                
                // System Monitor Cards
                HStack(spacing: 16) {
                    UsageCard(
                        title: "RAM Kullanımı",
                        percentage: viewModel.ramUsage,
                        primaryColor: .green,
                        usedText: "Kullanılan: \(viewModel.systemMonitor.memoryUsedString)",
                        freeText: "Boş: \(viewModel.systemMonitor.memoryFreeString)",
                        totalText: "Toplam: \(viewModel.systemMonitor.memoryTotalString)"
                    )
                    
                    UsageCard(
                        title: "Disk Kullanımı",
                        percentage: viewModel.diskUsage,
                        primaryColor: .yellow,
                        usedText: "Kullanılan: \(viewModel.systemMonitor.diskUsedString)",
                        freeText: "Boş: \(viewModel.systemMonitor.diskFreeString)",
                        totalText: "Toplam: \(viewModel.systemMonitor.diskTotalString)"
                    )
                    
                    UsageCard(
                        title: "CPU Kullanımı",
                        percentage: viewModel.cpuUsage,
                        primaryColor: .orange,
                        usedText: viewModel.systemMonitor.cpuBusyString,
                        freeText: viewModel.systemMonitor.cpuIdleString,
                        totalText: viewModel.systemMonitor.cpuTotalString
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 190)
                
                // Cleaning Section
                MaterialCard(title: "Sistem Temizliği") {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header with titles and status
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sistem Temizliği")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Önbellek ve Gereksiz Dosyalar")
                                    .font(.title2)
                                    .bold()
                                Text("Tarayıcı önbellekleri (Safari, Chrome, Brave, Edge, Opera, Firefox), uygulama önbellekleri ve kullanıcı logları.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: permissionVM.hasFullDiskAccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                Text(permissionVM.hasFullDiskAccess ? "Tam Disk Erişimi Verildi" : "Tam Disk Erişimi Gerekli")
                                    .font(.subheadline)
                            }
                            .foregroundStyle(permissionVM.hasFullDiskAccess ? Color.green : Color.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .adaptiveGlassEffect(in: .capsule)
                        }
                        
                        Divider()
                        
                        if permissionVM.hasFullDiskAccess {
                            VStack(alignment: .center, spacing: 12) {
                                Text("Tam Disk Erişimi")
                                    .font(.subheadline)
                                    .bold()
                                
                                Text("Tam Disk Erişimi verildiğinde DustBuster, önbellek, log ve tarayıcı konteyner klasörlerine güvenli şekilde erişebilir. Bu yetkiyi dilediğiniz zaman Sistem Ayarları > Gizlilik ve Güvenlik > Tam Disk Erişimi bölümünden yönetebilirsiniz.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 560)
                                
                                Button(action: {
                                    if permissionVM.hasFullDiskAccess {
                                        viewModel.scanSystem()
                                    } else {
                                        showFullDiskAccessAlert = true
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        if viewModel.isScanning {
                                            ProgressView()
                                                .scaleEffect(0.5)
                                        } else {
                                            Image(systemName: "magnifyingglass")
                                        }
                                        Text("Sistemi Tara")
                                    }
                                    .font(.headline)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                }
                                .adaptiveGlassButtonStyle(prominent: true)
                                .tint(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .disabled(viewModel.isScanning || viewModel.isCleaning || !permissionVM.hasFullDiskAccess)
                                .opacity(permissionVM.hasFullDiskAccess ? 1.0 : 0.5)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            VStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .center, spacing: 8) {
                                    Text("Tam Disk Erişimi")
                                        .font(.subheadline)
                                        .bold()
                                    
                                    Text("Durum: İzin yok. Bazı loglar ve klasörler taranamayabilir. Bu yetkiyi Sistem Ayarları > Gizlilik ve Güvenlik > Tam Disk Erişimi bölümünden yönetebilir ve DustBuster’a dilediğiniz zaman verebilirsiniz.")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: 520)
                                }
                                .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    if permissionVM.hasFullDiskAccess {
                                        viewModel.scanSystem()
                                    } else {
                                        showFullDiskAccessAlert = true
                                    }
                                }) {
                                    HStack {
                                        if viewModel.isScanning {
                                            ProgressView()
                                                .scaleEffect(0.5)
                                        } else {
                                            Image(systemName: "magnifyingglass")
                                        }
                                        Text("Sistemi Tara")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                }
                                .adaptiveGlassButtonStyle(prominent: true)
                                .tint(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .disabled(viewModel.isScanning || viewModel.isCleaning || !permissionVM.hasFullDiskAccess)
                                .opacity(permissionVM.hasFullDiskAccess ? 1.0 : 0.5)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        if viewModel.lastTrashTransaction != nil {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Son Temizlik: \(viewModel.lastCleanedSize) Çöp Kutusu'na taşındı (boşaltılınca alan açılır).")
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 5)
                        }
                    }
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .sheet(isPresented: $viewModel.showCleanerReview) {
            CleanerReviewView(viewModel: viewModel)
        }
        .alert("Tam Disk Erişimi olmadan sistem temizliği yapılamaz.",
               isPresented: $showFullDiskAccessAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text("Ayarlar > Tam Disk Erişimi bölümünden DustBuster’a izin verin.")
        }
    }
}

struct UsageCard: View {
    let title: String
    let percentage: Double
    let primaryColor: Color
    let usedText: String
    let freeText: String
    let totalText: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            UsageRingView(percentage: percentage, primaryColor: primaryColor)
            
            UsageDetailsView(
                usedText: usedText,
                freeText: freeText,
                totalText: totalText
            )
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding()
        .adaptiveGlassEffect(in: .rect(cornerRadius: 16))
    }
}

struct UsageRingView: View {
    let percentage: Double
    let primaryColor: Color
    
    private let size: CGFloat = 96
    private let lineWidth: CGFloat = 12
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(Color.gray.opacity(0.2))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(max(percentage, 0.0), 1.0)))
                .stroke(
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .foregroundColor(primaryColor)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: percentage)
            
            Text(String(format: "%.0f%%", min(max(percentage, 0.0), 1.0) * 100.0))
                .font(.title2)
                .bold()
        }
        .frame(width: size, height: size)
    }
}

struct UsageDetailsView: View {
    let usedText: String
    let freeText: String
    let totalText: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(usedText)
            Text(freeText)
            Text(totalText)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
}
