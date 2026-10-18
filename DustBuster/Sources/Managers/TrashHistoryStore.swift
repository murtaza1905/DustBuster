import Foundation

struct TrashHistoryEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let originalURL: URL
    let trashedURL: URL
    let timestamp: Date
    let size: Int64?
    let displayName: String

    init(id: UUID = UUID(), originalURL: URL, trashedURL: URL, timestamp: Date = Date(), size: Int64?, displayName: String) {
        self.id = id
        self.originalURL = originalURL
        self.trashedURL = trashedURL
        self.timestamp = timestamp
        self.size = size
        self.displayName = displayName
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var formattedSize: String {
        guard let size else { return "-" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

final class TrashHistoryStore {
    static let shared = TrashHistoryStore()

    private let defaults = UserDefaults.standard
    private let key = "DustBuster.TrashHistory"
    private let maxEntries = 50
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "DustBuster.TrashHistoryStore")

    private init() {}

    func load() -> [TrashHistoryEntry] {
        guard let data = defaults.data(forKey: key),
              let entries = try? decoder.decode([TrashHistoryEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func save(_ entries: [TrashHistoryEntry]) {
        guard let data = try? encoder.encode(entries) else { return }
        defaults.set(data, forKey: key)
    }

    func append(_ newEntries: [TrashHistoryEntry]) -> [TrashHistoryEntry] {
        queue.sync {
            var current = load()
            current.insert(contentsOf: newEntries, at: 0)
            if current.count > maxEntries {
                current = Array(current.prefix(maxEntries))
            }
            save(current)
            return current
        }
    }

    @discardableResult
    func remove(_ id: UUID) -> [TrashHistoryEntry] {
        queue.sync {
            var current = load()
            current.removeAll { $0.id == id }
            save(current)
            return current
        }
    }

    @discardableResult
    func remove(trashedPaths: Set<String>) -> [TrashHistoryEntry] {
        queue.sync {
            var current = load()
            current.removeAll { trashedPaths.contains($0.trashedURL.standardizedFileURL.path) }
            save(current)
            return current
        }
    }
}
