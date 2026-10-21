// Sources/ViewModels/DashboardViewModel.swift
import Foundation
import Combine

/// Dashboard ekranı için ViewModel
@MainActor
class DashboardViewModel: ObservableObject {
    // MARK: - Managers
    let systemMonitor = SystemMonitor()
    let cleanerManager = CleanerManager()
    let permissionManager = PermissionManager.shared
    
    // MARK: - System Stats
    @Published var ramUsage: Double = 0.0
    @Published var diskUsage: Double = 0.0
    @Published var cpuUsage: Double = 0.0
    
    // MARK: - Cleaning State
    @Published var cleaningPlan: CleaningPlan?
    @Published var cleaningResult: CleaningResult?
    @Published var isScanning: Bool = false
    @Published var isCleaning: Bool = false
    @Published var isRestoring: Bool = false
    @Published var isUndoing: Bool = false
    @Published var lastCleanedSize: String = "0 KB"
    @Published var trashHistory: [TrashHistoryEntry] = []
    @Published var restoreErrorMessage: String?
    @Published var lastTrashTransaction: CleanerManager.TrashTransaction?
    
    // MARK: - Navigation
    @Published var showCleanerReview: Bool = false
    @Published var showPermissionAlert: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init() {
        // SystemMonitor → DashboardViewModel bağlama
        systemMonitor.$memoryUsage
            .sink { [weak self] value in
                guard let self = self else { return }
                // Mevcut view update turunun dışına itiyoruz
                DispatchQueue.main.async {
                    self.ramUsage = value
                }
            }
            .store(in: &cancellables)
        
        systemMonitor.$diskUsage
            .sink { [weak self] value in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.diskUsage = value
                }
            }
            .store(in: &cancellables)
        
        systemMonitor.$cpuUsage
            .sink { [weak self] value in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.cpuUsage = value
                }
            }
            .store(in: &cancellables)
        
        // İzin kontrolü
        permissionManager.checkFullDiskAccess()
        permissionManager.$hasFullDiskAccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasAccess in
                self?.showPermissionAlert = !hasAccess
            }
            .store(in: &cancellables)

        trashHistory = cleanerManager.loadHistory()
    }
    
    // MARK: - Cleaning
    
    func scanSystem() {
        guard !isScanning else { return }
        isScanning = true
        cleaningPlan = nil
        cleaningResult = nil
        lastCleanedSize = "0 KB"
        
        cleanerManager.scan { [weak self] plan in
            guard let self = self else { return }
            self.cleaningPlan = plan
            self.isScanning = false
            self.showCleanerReview = true
            self.lastTrashTransaction = nil
        }
    }
    
    /// Sadece seçili item'ları temizler
    func cleanSelectedItems() {
        guard let plan = cleaningPlan, plan.hasSelection, !isCleaning else { return }
        
        isCleaning = true
        
        cleanerManager.apply(plan: plan) { [weak self] result in
            guard let self = self else { return }
            
            self.lastCleanedSize = ByteCountFormatter.string(
                fromByteCount: result.totalMovedBytes,
                countStyle: .file
            )
            self.isCleaning = false
            self.cleaningResult = result
            self.trashHistory = self.cleanerManager.loadHistory()
            self.lastTrashTransaction = self.cleanerManager.makeTransaction(from: result)

            if var updatedPlan = self.cleaningPlan {
                let movedIDs = Set(result.moved.map { $0.candidate.id })
                updatedPlan.candidates.removeAll { movedIDs.contains($0.id) }
                self.cleaningPlan = updatedPlan
            }
        }
    }

    func undoLastTransaction() {
        guard let transaction = lastTrashTransaction, !isUndoing else { return }
        isUndoing = true

        cleanerManager.undo(transaction: transaction) { [weak self] result in
            guard let self = self else { return }
            self.isUndoing = false
            switch result {
            case .success:
                self.lastTrashTransaction = nil
                self.lastCleanedSize = "0 KB"
                self.trashHistory = self.cleanerManager.loadHistory()
                self.cleaningResult = nil
            case .failure(let error):
                self.restoreErrorMessage = error.localizedDescription
            }
        }
    }

    func restore(entry: TrashHistoryEntry) {
        guard !isRestoring else { return }
        isRestoring = true
        cleanerManager.restore(entry: entry) { [weak self] result in
            guard let self = self else { return }
            self.isRestoring = false
            switch result {
            case .success:
                self.trashHistory = self.cleanerManager.loadHistory()
            case .failure(let error):
                self.restoreErrorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Selection Management

    func toggleSelection(for itemID: UUID) {
        guard var plan = cleaningPlan else { return }
        plan.toggleSelection(for: itemID)
        cleaningPlan = plan
    }
    
    func selectAllScannedItems() {
        guard var plan = cleaningPlan else { return }
        plan.selectAll()
        cleaningPlan = plan
    }
    
    func clearScannedSelection() {
        guard var plan = cleaningPlan else { return }
        plan.clearSelection()
        cleaningPlan = plan
    }
    
    // MARK: - Rapor (.txt)

    /// Tarama sonucunu, kapsamı ve konum bazlı kararları .txt olarak dışa aktarır.
    func exportCleaningReport() {
        var lines = ReportExporter.headerLines(title: "Sistem Temizliği Raporu")
        lines.append("Tam Disk Erişimi: \(permissionManager.hasFullDiskAccess ? "var" : "yok")")
        lines.append("")

        lines.append("Taranan konumlar ve kurallar")
        lines.append(contentsOf: cleanerManager.scanScopeLines())
        lines.append("")

        let candidates = (cleaningPlan?.candidates ?? []).sorted { $0.size > $1.size }
        lines.append("Bulunan öğeler (\(candidates.count)) — Toplam \(totalScanSize), Seçili \(selectedScanSize) — [x] seçili, [ ] seçimsiz")
        for candidate in candidates {
            let mark = candidate.isSelected ? "[x]" : "[ ]"
            let kind = candidate.isDirectory ? "klasör" : "dosya"
            let flag = candidate.isSystemService ? " | Apple sistem servisi" : ""
            lines.append("\(mark) \(candidate.formattedSize) | \(kind) | \(candidate.displayName)\(flag) | \(ReportExporter.tildePath(candidate.path))")
        }
        lines.append("")

        if let result = cleaningResult {
            lines.append("Son temizlik sonucu")
            lines.append(result.summaryLine)
            for note in result.notes {
                lines.append("- " + note)
            }
            lines.append("")
        }

        lines.append("Konum bazlı karar listesi — LİSTE: plana girdi, ATLANDI: dışarıda kaldı (neden), AYRI: tarayıcı cache, BÖLÜNDÜ: satıcı klasörü alt girdileriyle")
        lines.append(contentsOf: cleanerManager.diagnosticListing(plan: cleaningPlan))

        let text = lines.joined(separator: "\n") + "\n"
        let fileName = ReportExporter.suggestedFileName(prefix: "DustBuster_Cleanup")

        ReportExporter.save(text: text, suggestedName: fileName) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let url):
                LogManager.shared.log("Temizlik raporu kaydedildi: \(url.lastPathComponent)", category: .audit, level: .info)
            case .failure(let error):
                self.restoreErrorMessage = "Rapor kaydedilemedi: \(error.localizedDescription)"
            }
        }
    }

    func openSettings() {
        permissionManager.requestFullDiskAccess()
    }
    
    var totalScanSize: String {
        let total = cleaningPlan?.totalSize ?? 0
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }
    
    var selectedScanSize: String {
        let total = cleaningPlan?.selectedSize ?? 0
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }
}
