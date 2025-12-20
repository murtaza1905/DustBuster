// Sources/ViewModels/LargeFilesViewModel.swift
import Foundation
import Combine

final class LargeFilesViewModel: ObservableObject {
    @Published var items: [LargeFileItem] = []
    @Published var isScanning: Bool = false
    @Published var isDeleting: Bool = false
    @Published var deleteErrors: [String] = []

    private let manager = LargeFileManager()
    private let permissionManager = PermissionManager.shared

    /// Tek eşik: 250 MB
    let minSize: Int64 = 250 * 1024 * 1024

    // View'dan güvenli şekilde çağrılan tarama
    func scheduleScan() {
        scan()
    }

    private func scan() {
        permissionManager.checkFullDiskAccess()
        guard permissionManager.hasFullDiskAccess else {
            #if DEBUG
            print("Full Disk Access yok, LargeFiles scan iptal edildi")
            #endif
            return
        }
        
        guard !isScanning else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.isScanning = true
        }

        manager.scan(minSize: minSize) { [weak self] newItems in
            // LargeFileManager zaten main thread'de completion çağırıyor
            guard let self = self else { return }
            self.items = newItems
            self.isScanning = false
        }
    }

    // MARK: - Seçim bilgileri

    var hasSelectedItems: Bool {
        items.contains(where: { $0.isSelected })
    }

    var selectedCount: Int {
        items.filter { $0.isSelected }.count
    }

    var selectedSize: Int64 {
        items.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
    }

    var selectedSizeString: String {
        guard selectedSize > 0 else { return "0 B" }
        return ByteCountFormatter.string(fromByteCount: selectedSize,
                                         countStyle: .file)
    }

    // MARK: - Silme

    func deleteSelected() {
        permissionManager.checkFullDiskAccess()
        guard permissionManager.hasFullDiskAccess else {
            #if DEBUG
            print("Full Disk Access yok, LargeFiles delete iptal edildi")
            #endif
            return
        }
        
        guard !isDeleting else { return }

        let toDelete = items.filter { $0.isSelected }
        guard !toDelete.isEmpty else { return }

        isDeleting = true
        deleteErrors.removeAll()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fm = FileManager.default
            var deletedIDs = Set<UUID>()
            var errors: [String] = []

            for item in toDelete {
                do {
                    try fm.trashItem(at: item.url, resultingItemURL: nil)
                    deletedIDs.insert(item.id)
                } catch {
                    let message = "\(item.path): Çöp Kutusu'na taşınamadı - \(error.localizedDescription)"
                    errors.append(message)
                }
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.items.removeAll { deletedIDs.contains($0.id) }
                self.deleteErrors.append(contentsOf: errors)
                self.isDeleting = false
            }
        }
    }
}
