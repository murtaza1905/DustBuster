import Foundation

/// Tarayıcının dosya sistemine tek erişim noktası. Gerçek diskte `RealFileSystem`,
/// testlerde yol listesinden kurulan `VirtualFileSystem` kullanılır; tarama mantığı ikisini ayırt etmez.
public protocol ScanFileSystem {
    /// Dizindeki girdi adları (gizli dosyalar hariç). Dizin yoksa veya okunamıyorsa nil.
    func contents(ofDirectory path: String) -> [String]?
    func exists(_ path: String) -> Bool
    func isDirectory(_ path: String) -> Bool
    func isSymlink(_ path: String) -> Bool
}

public extension ScanFileSystem {
    func isRegularDirectory(_ path: String) -> Bool {
        isDirectory(path) && !isSymlink(path)
    }
}

/// FileManager üzerinden gerçek disk.
public struct RealFileSystem: ScanFileSystem {
    private let fm = FileManager.default

    public init() {}

    public func contents(ofDirectory path: String) -> [String]? {
        guard let names = try? fm.contentsOfDirectory(atPath: path) else { return nil }
        return names.filter { !$0.hasPrefix(".") }
    }

    public func exists(_ path: String) -> Bool {
        fm.fileExists(atPath: path)
    }

    public func isDirectory(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        return fm.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
    }

    public func isSymlink(_ path: String) -> Bool {
        guard let attrs = try? fm.attributesOfItem(atPath: path) else { return false }
        return (attrs[.type] as? FileAttributeType) == .typeSymbolicLink
    }
}

/// Yol listesinden kurulan sanal disk. Sonu "/" ile biten veya altında çocuğu olan girdiler dizin,
/// diğerleri dosya sayılır. Ara dizinler otomatik oluşturulur.
public final class VirtualFileSystem: ScanFileSystem {
    private var directories: Set<String> = ["/"]
    private var files: Set<String> = []
    private var symlinks: Set<String> = []
    private var children: [String: Set<String>] = [:]

    public init(paths: [String], symlinks: [String] = []) {
        for raw in paths { add(raw) }
        for raw in symlinks {
            let p = VirtualFileSystem.normalize(raw)
            add(raw)
            self.symlinks.insert(p)
        }
    }

    public static func normalize(_ raw: String) -> String {
        var p = raw
        if p.count > 1 && p.hasSuffix("/") { p.removeLast() }
        return p
    }

    private func add(_ raw: String) {
        let isDir = raw.hasSuffix("/")
        let path = VirtualFileSystem.normalize(raw)
        guard path.hasPrefix("/") else { return }

        var components = path.split(separator: "/").map(String.init)
        guard !components.isEmpty else { return }
        let last = components.removeLast()

        var current = ""
        for component in components {
            let parent = current.isEmpty ? "/" : current
            current += "/" + component
            directories.insert(current)
            files.remove(current)
            children[parent, default: []].insert(component)
        }
        let parent = current.isEmpty ? "/" : current
        children[parent, default: []].insert(last)
        if isDir {
            directories.insert(path)
        } else if !directories.contains(path) {
            files.insert(path)
        }
    }

    public func contents(ofDirectory path: String) -> [String]? {
        let p = VirtualFileSystem.normalize(path)
        guard directories.contains(p) else { return nil }
        return Array(children[p] ?? []).filter { !$0.hasPrefix(".") }.sorted()
    }

    public func exists(_ path: String) -> Bool {
        let p = VirtualFileSystem.normalize(path)
        return directories.contains(p) || files.contains(p)
    }

    public func isDirectory(_ path: String) -> Bool {
        directories.contains(VirtualFileSystem.normalize(path))
    }

    public func isSymlink(_ path: String) -> Bool {
        symlinks.contains(VirtualFileSystem.normalize(path))
    }

    /// Testler için: sanal diskteki tüm yollar.
    public var allPaths: [String] {
        Array(directories.union(files)).sorted()
    }
}
