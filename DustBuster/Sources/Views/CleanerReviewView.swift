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
        HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.md) {
            Image(systemName: "sparkles")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("Temizlik Planı")
                    .font(.title2.weight(.semibold))
                Text("Bulunanları gözden geçir; seçtiklerin Çöp Kutusu'na taşınır.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.top, DS.Spacing.xl)
        .padding(.bottom, DS.Spacing.sm)
    }
    
    // MARK: - Summary badges

    private var summaryBadges: some View {
        VStack(spacing: 8) {
            // Üst satır: Boyut badge'leri ve sonuç
            HStack(spacing: DS.Spacing.sm) {
                Tag(text: "Toplam \(viewModel.totalScanSize)", tone: .neutral, systemImage: "externaldrive")
                Tag(text: "Seçili \(viewModel.selectedScanSize)", tone: .accent, systemImage: "checkmark.circle")
                Spacer()
                if let result = viewModel.cleaningResult {
                    Text(result.summaryLine)
                        .font(.caption)
                        .foregroundStyle(result.hasFailures ? Color.orange : Color.secondary)
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
                
                Text("Sırala")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
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
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.bottom, DS.Spacing.sm)
    }
    
    // MARK: - Tabs

    private var tabSelector: some View {
        Picker("", selection: $selectedTab) {
            ForEach(CleanerReviewTab.allCases) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.bottom, DS.Spacing.sm)
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
        .listStyle(.inset)
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
                    SectionTitle(title: "Apple sistem servisleri", count: sortedSystemItems.count,
                                 note: "\(systemTotalSize) · macOS yeniden üretir, varsayılan seçimsiz", tone: .warning)
                }
            }
            .buttonStyle(.plain)

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
        .textCase(nil)
    }

    private func row(for item: CleaningCandidate) -> some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { item.isSelected },
                set: { _ in viewModel.toggleSelection(for: item.id) }
            ))
            .toggleStyle(CheckboxToggleStyle())

            Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(item.isSystemService ? Color.secondary : Color.accentColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.displayName)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(item.path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            Text(item.formattedSize)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 76, alignment: .trailing)
        }
        .padding(.vertical, 6)
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SectionTitle(title: "Çöp Kutusu Geçmişi", count: viewModel.trashHistory.count, note: "son 50 işlem")
                Spacer()
                if viewModel.isRestoring {
                    ProgressView().controlSize(.small)
                }
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.top, DS.Spacing.sm)

            if viewModel.trashHistory.isEmpty {
                EmptyState(systemImage: "clock.arrow.circlepath", title: "Henüz geçmiş yok",
                           message: "Çöp Kutusu'na taşınan öğeler burada listelenir ve geri alınabilir.")
            } else {
                List {
                    ForEach(viewModel.trashHistory) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.displayName)
                                    .font(.subheadline.weight(.medium))
                                Text("\(entry.formattedDate) · \(entry.formattedSize)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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
                .listStyle(.inset)
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
            .tint(.red)
            .disabled(!hasSelectedItems || viewModel.isCleaning)
        }
        .controlSize(.large)
        .padding(.horizontal, DS.Spacing.xl)
        .padding(.vertical, DS.Spacing.lg)
        .background(.bar)
    }
    
    // MARK: - Helpers
    
    private func toggleSortOrder() {
        sortOrder = (sortOrder == .ascending) ? .descending : .ascending
    }
}
