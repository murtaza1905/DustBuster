import SwiftUI

private enum CleanerSortKey: String, CaseIterable, Identifiable {
    case name
    case size
    case path
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .name: return "İsim"
        case .size: return "Boyut"
        case .path: return "Konum"
        }
    }
}

private enum CleanerSortOrder: String, CaseIterable, Identifiable {
    case ascending
    case descending
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .ascending:  return "Küçük → Büyük"
        case .descending: return "Büyük → Küçük"
        }
    }
}

private enum CleanerReviewTab: String, CaseIterable, Identifiable {
    case items = "Öğeler"
    case history = "Geçmiş"

    var id: String { rawValue }
}

struct CleanerReviewView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var sortKey: CleanerSortKey = .size
    @State private var sortOrder: CleanerSortOrder = .descending
    @State private var showConfirmation: Bool = false
    @State private var selectedTab: CleanerReviewTab = .items
    @State private var showSystemServices: Bool = false
    
    private var plan: CleaningPlan? {
        viewModel.cleaningPlan
    }
    
    private var sortedItems: [CleaningCandidate] { sorted(plan?.regularCandidates ?? []) }
    private var sortedSystemItems: [CleaningCandidate] { sorted(plan?.systemServiceCandidates ?? []) }

    private var systemTotalSize: String {
        ByteCountFormatter.string(fromByteCount: sortedSystemItems.reduce(0) { $0 + $1.size }, countStyle: .file)
    }

    private var systemSelectedCount: Int { sortedSystemItems.filter { $0.isSelected }.count }

    private func sorted(_ base: [CleaningCandidate]) -> [CleaningCandidate] {
        let sorted: [CleaningCandidate]
        switch sortKey {
        case .name:
            sorted = base.sorted {
                $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
        case .size:
            sorted = base.sorted { $0.size < $1.size }
        case .path:
            sorted = base.sorted {
                $0.path.localizedCaseInsensitiveCompare($1.path) == .orderedAscending
            }
        }
        
        return (sortOrder == .ascending) ? sorted : sorted.reversed()
    }
    
    private var hasSelectedItems: Bool {
        plan?.hasSelection ?? false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            summaryBadges
            tabSelector
            Divider()
            mainContent
            Divider()
            footer
        }
        .frame(
            minWidth: 700,
            idealWidth: 850,
            maxWidth: 1000,
            minHeight: 500,
            idealHeight: 650,
            maxHeight: 800
        )
        .confirmationDialog(
            "Seçili öğeler Çöp Kutusu'na taşınacak.",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Çöp Kutusuna Taşı", role: .destructive) {
                viewModel.cleanSelectedItems()
            }
            .disabled(!hasSelectedItems)
            Button("Vazgeç", role: .cancel) { }
        }
        .alert(
            "İşlem Hatası",
            isPresented: Binding(
                get: { viewModel.restoreErrorMessage != nil },
                set: { _ in viewModel.restoreErrorMessage = nil }
            )
        ) {
            Button("Tamam", role: .cancel) { viewModel.restoreErrorMessage = nil }
        } message: {
            Text(viewModel.restoreErrorMessage ?? "Bilinmeyen hata")
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Temizlik Planı İncelemesi")
                .font(.title3)
                .bold()
            Text("Tarama sonucu bulunan dosyaları gözden geçir ve Çöp Kutusu'na taşı.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
    
    // MARK: - Summary badges

    private var summaryBadges: some View {
        VStack(spacing: 8) {
            // Üst satır: Boyut badge'leri ve sonuç
            HStack {
                badge(text: "Toplam \(viewModel.totalScanSize)", color: .blue)
                badge(text: "Seçili \(viewModel.selectedScanSize)", color: .purple)
                Spacer()
                if let result = viewModel.cleaningResult {
                    Text(result.summaryLine)
                        .font(.subheadline)
                        .foregroundColor(result.hasFailures ? .orange : .secondary)
                }
            }
            
            // Alt satır: Seçim ve sıralama kontrolleri
            HStack(spacing: 12) {
                Button {
                    viewModel.selectAllScannedItems()
                } label: {
                    Label("Tümünü Seç", systemImage: "checkmark.square")
                }
                .buttonStyle(.bordered)
                .disabled(plan == nil || plan?.regularCandidates.isEmpty == true)
                .help("Apple sistem servisleri hariç")
                
                Button {
                    viewModel.clearScannedSelection()
                } label: {
                    Label("Seçimi Temizle", systemImage: "xmark.square")
                }
                .buttonStyle(.bordered)
                .disabled(!hasSelectedItems)
                
                Spacer()
                
                Text("Sırala:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("", selection: $sortKey) {
                    ForEach(CleanerSortKey.allCases) { key in
                        Text(key.title).tag(key)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)
                
                Button {
                    toggleSortOrder()
                } label: {
                    Image(systemName: sortOrder == .ascending ? "arrow.up" : "arrow.down")
                }
                .buttonStyle(.bordered)
                .help(sortOrder == .ascending ? "Küçükten büyüğe" : "Büyükten küçüğe")
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
    
    // MARK: - Tabs

    private var tabSelector: some View {
        Picker("", selection: $selectedTab) {
            ForEach(CleanerReviewTab.allCases) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Content

    private var mainContent: some View {
        Group {
            if selectedTab == .items {
                list
            } else {
                historySection
            }
        }
    }
    
    // MARK: - Liste
    
    private var list: some View {
        List {
            if sortedItems.isEmpty && sortedSystemItems.isEmpty {
                Text("Temizlenecek dosya bulunamadı.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Section {
                    if sortedItems.isEmpty {
                        Text("Uygulama ve tarayıcı önbelleği bulunamadı.")
                            .foregroundColor(.secondary)
                    }
                    ForEach(sortedItems) { item in
                        row(for: item)
                    }
                }

                if !sortedSystemItems.isEmpty {
                    Section {
                        if showSystemServices {
                            ForEach(sortedSystemItems) { item in
                                row(for: item)
                            }
                        }
                    } header: {
                        systemServicesHeader
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    /// Apple sistem servisleri ayrı, varsayılan daraltılmış bölümde durur; macOS bunları yeniden ürettiği
    /// için "Tümünü Seç" kapsamına girmez.
    private var systemServicesHeader: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { showSystemServices.toggle() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: showSystemServices ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .frame(width: 12)
                    Text("Apple sistem servisleri")
                        .font(.subheadline.weight(.semibold))
                    Text("\(sortedSystemItems.count) öğe · \(systemTotalSize)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            Text("macOS yeniden üretir, varsayılan seçimsiz")
                .font(.caption)
                .foregroundColor(.orange)

            Spacer()

            if showSystemServices {
                Button(systemSelectedCount == sortedSystemItems.count ? "Seçimi bırak" : "Tümünü seç") {
                    viewModel.setSystemServicesSelected(systemSelectedCount != sortedSystemItems.count)
                }
                .buttonStyle(.link)
                .font(.caption)
            } else if systemSelectedCount > 0 {
                Text("\(systemSelectedCount) seçili")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
        .textCase(nil)
    }

    private func row(for item: CleaningCandidate) -> some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { item.isSelected },
                set: { _ in viewModel.toggleSelection(for: item.id) }
            ))
            .toggleStyle(CheckboxToggleStyle())

            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName)
                    .font(.body)
                Text(item.path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            Text(item.formattedSize)
                .font(.callout)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Çöp Kutusu Geçmişi (son 50)")
                    .font(.headline)
                Spacer()
                if viewModel.isRestoring {
                    ProgressView().scaleEffect(0.7)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if viewModel.trashHistory.isEmpty {
                Text("Henüz geçmiş yok.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                List {
                    ForEach(viewModel.trashHistory) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.displayName)
                                    .font(.subheadline)
                                Text("\(entry.formattedDate) • \(entry.formattedSize)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Geri Al") {
                                viewModel.restore(entry: entry)
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isRestoring)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        HStack {
            Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            }
            .keyboardShortcut(.cancelAction)
            
            Spacer()

            Button {
                viewModel.exportCleaningReport()
            } label: {
                Label("Rapor (.txt)", systemImage: "doc.text")
            }
            .buttonStyle(.bordered)
            .disabled(plan == nil || viewModel.isScanning)
            .help("Tarama sonucunu, kapsamı ve konum bazlı kararları metin dosyası olarak kaydet")

            Button {
                viewModel.undoLastTransaction()
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isUndoing {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    Text("Geri Al")
                }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.lastTrashTransaction == nil || viewModel.isUndoing)
            .help("Son taşıma işlemini geri al")

            Button(action: {
                showConfirmation = true
            }) {
                HStack(spacing: 6) {
                    if viewModel.isCleaning {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "trash")
                    }
                    Text("Çöp Kutusuna Taşı")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!hasSelectedItems || viewModel.isCleaning)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Helpers
    
    private func toggleSortOrder() {
        sortOrder = (sortOrder == .ascending) ? .descending : .ascending
    }
}
