import Foundation

struct FileIdentitySnapshot: Hashable {
    let resourceIdentifier: Data?
    let modificationDate: Date?
    let isSymbolicLink: Bool

    init?(url: URL) {
        guard let values = try? url.resourceValues(forKeys: [
            .contentModificationDateKey,
            .fileResourceIdentifierKey,
            .isSymbolicLinkKey
        ]) else {
            return nil
        }

        if let data = values.fileResourceIdentifier as? Data {
            self.resourceIdentifier = data
        } else if let identifier = values.fileResourceIdentifier {
            self.resourceIdentifier = try? NSKeyedArchiver.archivedData(
                withRootObject: identifier,
                requiringSecureCoding: false
            )
        } else {
            self.resourceIdentifier = nil
        }

        self.modificationDate = values.contentModificationDate
        self.isSymbolicLink = values.isSymbolicLink ?? false
    }

    func matches(_ other: FileIdentitySnapshot) -> Bool {
        if let lhs = resourceIdentifier, let rhs = other.resourceIdentifier {
            if lhs != rhs { return false }
        } else if resourceIdentifier != nil || other.resourceIdentifier != nil {
            return false
        }

        if let lhsDate = modificationDate, let rhsDate = other.modificationDate {
            if lhsDate != rhsDate { return false }
        } else if modificationDate != nil || other.modificationDate != nil {
            return false
        }

        return true
    }
}

struct CleaningCandidate: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let size: Int64
    let isDirectory: Bool
    var isSelected: Bool
    let displayName: String
    let identity: FileIdentitySnapshot
    /// Apple sistem servisi önbelleği: silmek güvenli ama macOS yeniden üretir; varsayılan seçimsiz
    var isSystemService: Bool = false

    var path: String {
        url.path
    }

    var formattedSize: String {
        size == 0 ? "boş" : ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

struct CleaningPlan: Hashable {
    var candidates: [CleaningCandidate]

    var totalSize: Int64 {
        candidates.reduce(0) { $0 + $1.size }
    }

    var selectedSize: Int64 {
        selectedCandidates.reduce(0) { $0 + $1.size }
    }

    var selectedCandidates: [CleaningCandidate] {
        candidates.filter { $0.isSelected }
    }

    var hasSelection: Bool {
        !selectedCandidates.isEmpty
    }

    mutating func toggleSelection(for candidateID: UUID) {
        guard let index = candidates.firstIndex(where: { $0.id == candidateID }) else { return }
        candidates[index].isSelected.toggle()
    }

    /// Apple sistem servisleri "tümünü seç" kapsamına girmez; kendi bölümünden ayrıca seçilir.
    mutating func selectAll() {
        for index in candidates.indices where !candidates[index].isSystemService {
            candidates[index].isSelected = true
        }
    }

    mutating func setSystemServicesSelected(_ selected: Bool) {
        for index in candidates.indices where candidates[index].isSystemService {
            candidates[index].isSelected = selected
        }
    }

    var systemServiceCandidates: [CleaningCandidate] { candidates.filter { $0.isSystemService } }
    var regularCandidates: [CleaningCandidate] { candidates.filter { !$0.isSystemService } }

    mutating func clearSelection() {
        for index in candidates.indices {
            candidates[index].isSelected = false
        }
    }
}

struct CleaningResult {
    struct MovedItem: Hashable {
        let candidate: CleaningCandidate
        let trashedURL: URL?
    }

    let moved: [MovedItem]
    let skipped: [CleaningCandidate]
    let failed: [CleaningCandidate]
    let totalMovedBytes: Int64
    let notes: [String]

    var hasFailures: Bool {
        !failed.isEmpty
    }

    var summaryLine: String {
        let movedText = ByteCountFormatter.string(fromByteCount: totalMovedBytes, countStyle: .file)
        return "Taşındı: \(moved.count), Atlandı: \(skipped.count), Hata: \(failed.count), Toplam: \(movedText)"
    }
}
