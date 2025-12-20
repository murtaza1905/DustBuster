import Foundation
import AppKit

// MARK: - AppleScript Deletion Result

enum AppleScriptDeleteError: Error {
    case userCancelled
    case scriptError(code: Int, message: String)
    case unknownError(String)

    var localizedDescription: String {
        switch self {
        case .userCancelled:
            return "Kullanici islemi iptal etti"
        case .scriptError(let code, let message):
            return "AppleScript hatasi (kod \(code)): \(message)"
        case .unknownError(let message):
            return message
        }
    }

    var isUserCancelled: Bool {
        if case .userCancelled = self { return true }
        return false
    }
}

final class SafeDeleteService {
    struct Rules {
        let forbiddenPaths: [String]
        let isPathAllowed: (String) -> Bool
    }

    private let fileManager = FileManager.default
    private let logManager = LogManager.shared

    struct SimpleMoveResult {
        struct Moved {
            let original: URL
            let trashedURL: URL?
        }

        struct Skipped {
            let url: URL
            let reason: String
        }

        struct Failure {
            let url: URL
            let error: NSError
        }

        let moved: [Moved]
        let skipped: [Skipped]
        let failed: [Failure]
        let notes: [String]
    }

    func moveToTrash(plan: CleaningPlan, rules: Rules, completion: @escaping (CleaningResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var moved: [CleaningResult.MovedItem] = []
            var skipped: [CleaningCandidate] = []
            var failed: [CleaningCandidate] = []
            var movedBytes: Int64 = 0
            var notes: [String] = []

            for candidate in plan.selectedCandidates {
                let path = candidate.path

                guard rules.isPathAllowed(path) else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): izinli değil", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - izinli değil", to: &notes)
                    continue
                }

                guard self.isForbidden(path: path, forbiddenRoots: rules.forbiddenPaths) == false else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): yasaklı path", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - yasaklı konum", to: &notes)
                    continue
                }

                guard self.fileManager.fileExists(atPath: path) else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): artık mevcut değil", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - mevcut değil", to: &notes)
                    continue
                }

                guard let currentIdentity = FileIdentitySnapshot(url: candidate.url) else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): kimlik alınamadı", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - kimlik alınamadı", to: &notes)
                    continue
                }

                guard candidate.identity.isSymbolicLink == false, currentIdentity.isSymbolicLink == false else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): symlink tespit edildi", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - symlink", to: &notes)
                    continue
                }

                guard currentIdentity.matches(candidate.identity) else {
                    skipped.append(candidate)
                    self.logManager.log("Skip \(candidate.displayName): kimlik değişti", category: .audit, level: .warning)
                    self.appendNote("Atlandı: \(candidate.displayName) - dosya değişti", to: &notes)
                    continue
                }

                do {
                    var trashedURL: NSURL?
                    try self.fileManager.trashItem(at: candidate.url, resultingItemURL: &trashedURL)
                    moved.append(.init(candidate: candidate, trashedURL: trashedURL as URL?))
                    movedBytes += candidate.size
                    if let trashed = trashedURL {
                        self.appendNote("Taşındı: \(candidate.displayName) -> \(trashed.path ?? "Trash")", to: &notes)
                    } else {
                        self.appendNote("Taşındı: \(candidate.displayName)", to: &notes)
                    }
                } catch {
                    failed.append(candidate)
                    let nsError = error as NSError
                    self.logManager.log("Çöp Kutusu hatası \(candidate.displayName) kod \(nsError.code)", category: .error, level: .error)
                    self.appendNote("Hata: \(candidate.displayName) - kod \(nsError.code)", to: &notes)
                }
            }

            let result = CleaningResult(
                moved: moved,
                skipped: skipped,
                failed: failed,
                totalMovedBytes: movedBytes,
                notes: Array(notes.prefix(5))
            )

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    /// Trash-only helper for fixed URL lists. Keeps operations inside the user's home directory.
    func moveToTrash(urls: [URL], allowedOutsideHome: [URL] = [], completion: @escaping (SimpleMoveResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let homePath = self.fileManager.homeDirectoryForCurrentUser.path
            var moved: [SimpleMoveResult.Moved] = []
            var skipped: [SimpleMoveResult.Skipped] = []
            var failed: [SimpleMoveResult.Failure] = []
            var notes: [String] = []
            let allowedExtraPaths = allowedOutsideHome.map { $0.standardizedFileURL.path }
            let forbiddenRoots = ["/System", "/Library", "/usr", "/bin", "/sbin"]

            for url in urls {
                let path = url.standardizedFileURL.path

                if !path.hasPrefix(homePath) {
                    let isAllowedExtra = allowedExtraPaths.contains { path.hasPrefix($0) }
                    let isForbidden = forbiddenRoots.contains { path.hasPrefix($0) }
                    if !isAllowedExtra || isForbidden {
                        skipped.append(.init(url: url, reason: "İzinli değil"))
                        self.appendNote("Atlandı: \(url.lastPathComponent) - izinli değil", to: &notes)
                        continue
                    }
                } else if forbiddenRoots.contains(where: { path.hasPrefix($0) }) {
                    skipped.append(.init(url: url, reason: "İzinli değil"))
                    self.appendNote("Atlandı: \(url.lastPathComponent) - izinli değil", to: &notes)
                    continue
                }

                guard self.fileManager.fileExists(atPath: path) else {
                    skipped.append(.init(url: url, reason: "Mevcut değil"))
                    self.appendNote("Atlandı: \(url.lastPathComponent) - mevcut değil", to: &notes)
                    continue
                }

                if let isSymlink = try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink, isSymlink == true {
                    skipped.append(.init(url: url, reason: "Symlink"))
                    self.appendNote("Atlandı: \(url.lastPathComponent) - symlink", to: &notes)
                    continue
                }

                do {
                    var trashedURL: NSURL?
                    try self.fileManager.trashItem(at: url, resultingItemURL: &trashedURL)
                    moved.append(.init(original: url, trashedURL: trashedURL as URL?))
                    if let trashed = trashedURL {
                        self.logManager.log("Çöp Kutusu: \(url.lastPathComponent) -> \(trashed.path ?? "Trash")", category: .cleanup, level: .info)
                        self.appendNote("Taşındı: \(url.lastPathComponent)", to: &notes)
                    } else {
                        self.logManager.log("Çöp Kutusu: \(url.lastPathComponent)", category: .cleanup, level: .info)
                        self.appendNote("Taşındı: \(url.lastPathComponent)", to: &notes)
                    }
                } catch {
                    let nsError = error as NSError
                    failed.append(.init(url: url, error: nsError))
                    self.logManager.log("Çöp Kutusu hatası \(url.lastPathComponent) kod \(nsError.code)", category: .error, level: .error)
                    self.appendNote("Hata: \(url.lastPathComponent) - kod \(nsError.code)", to: &notes)
                }
            }

            let result = SimpleMoveResult(
                moved: moved,
                skipped: skipped,
                failed: failed,
                notes: Array(notes.prefix(5))
            )

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    private func isForbidden(path: String, forbiddenRoots: [String]) -> Bool {
        forbiddenRoots.contains { path.hasPrefix($0) }
    }

    private func appendNote(_ text: String, to list: inout [String]) {
        guard list.count < 5 else { return }
        list.append(text)
    }

    // MARK: - AppleScript Based Deletion

    /// Escapes a path for use in AppleScript single-quoted strings
    private func escapePathForAppleScript(_ path: String) -> String {
        // Single quotes in AppleScript: escape by ending quote, adding escaped quote, starting new quote
        // 'path' -> 'path'\''with'\''quotes'
        return path.replacingOccurrences(of: "'", with: "'\\''")
    }

    /// Generates a unique trash destination name if file already exists in trash
    private func uniqueTrashDestination(for url: URL) -> String {
        let trashURL = fileManager.urls(for: .trashDirectory, in: .userDomainMask).first
            ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")

        let fileName = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension

        var candidate = trashURL.appendingPathComponent(url.lastPathComponent)
        var counter = 2

        while fileManager.fileExists(atPath: candidate.path) {
            let newName = ext.isEmpty ? "\(fileName) \(counter)" : "\(fileName) \(counter).\(ext)"
            candidate = trashURL.appendingPathComponent(newName)
            counter += 1
        }

        return candidate.path
    }

    /// Tries to move a single file to trash using Finder AppleScript (no admin)
    func moveToTrashViaFinder(url: URL) -> Result<URL, AppleScriptDeleteError> {
        let escapedPath = escapePathForAppleScript(url.path)
        let script = """
        tell application "Finder"
            move POSIX file "\(escapedPath)" to trash
        end tell
        """

        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else {
            return .failure(.unknownError("AppleScript olusturulamadi"))
        }

        let _ = appleScript.executeAndReturnError(&error)

        if let error = error {
            let code = error[NSAppleScript.errorNumber] as? Int ?? -1
            let message = error[NSAppleScript.errorMessage] as? String ?? "Bilinmeyen hata"

            if code == -128 {
                return .failure(.userCancelled)
            }
            return .failure(.scriptError(code: code, message: message))
        }

        // Get trash URL
        let trashURL = fileManager.urls(for: .trashDirectory, in: .userDomainMask).first
            ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")
        let trashedURL = trashURL.appendingPathComponent(url.lastPathComponent)

        return .success(trashedURL)
    }

    /// Moves files to trash with admin privileges using AppleScript (single password prompt)
    /// All protected files are moved in a single operation
    func moveToTrashWithAdminPrivileges(urls: [URL], completion: @escaping (Result<[URL], AppleScriptDeleteError>) -> Void) {
        guard !urls.isEmpty else {
            completion(.success([]))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError("Service deallocated")))
                }
                return
            }

            // Build mv commands for all files
            var moveCommands: [String] = []
            var trashedURLs: [URL] = []

            for url in urls {
                let escapedSource = self.escapePathForAppleScript(url.path)
                let destPath = self.uniqueTrashDestination(for: url)
                let escapedDest = self.escapePathForAppleScript(destPath)

                moveCommands.append("mv '\(escapedSource)' '\(escapedDest)'")
                trashedURLs.append(URL(fileURLWithPath: destPath))
            }

            // Join all commands with && so they run sequentially
            let combinedCommand = moveCommands.joined(separator: " && ")

            let script = """
            do shell script "\(combinedCommand)" with administrator privileges
            """

            var error: NSDictionary?
            guard let appleScript = NSAppleScript(source: script) else {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError("AppleScript olusturulamadi")))
                }
                return
            }

            let _ = appleScript.executeAndReturnError(&error)

            DispatchQueue.main.async {
                if let error = error {
                    let code = error[NSAppleScript.errorNumber] as? Int ?? -1
                    let message = error[NSAppleScript.errorMessage] as? String ?? "Bilinmeyen hata"

                    if code == -128 {
                        completion(.failure(.userCancelled))
                    } else {
                        completion(.failure(.scriptError(code: code, message: message)))
                    }
                } else {
                    completion(.success(trashedURLs))
                }
            }
        }
    }

    // MARK: - Smart Delete (Normal -> AppleScript Fallback)

    struct SmartMoveResult {
        struct Moved {
            let original: URL
            let trashedURL: URL?
            let usedAdminPrivileges: Bool
        }

        struct Skipped {
            let url: URL
            let reason: String
        }

        struct Failure {
            let url: URL
            let error: NSError
        }

        let moved: [Moved]
        let skipped: [Skipped]
        let failed: [Failure]
        let notes: [String]
        let userCancelled: Bool
    }

    /// Smart deletion: tries normal FileManager first, collects failures, then uses AppleScript with admin privileges
    /// for protected files (single password prompt for all protected files)
    func smartMoveToTrash(urls: [URL], allowedOutsideHome: [URL] = [], completion: @escaping (SmartMoveResult) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let homePath = self.fileManager.homeDirectoryForCurrentUser.path
            var moved: [SmartMoveResult.Moved] = []
            var skipped: [SmartMoveResult.Skipped] = []
            var failed: [SmartMoveResult.Failure] = []
            var needsAdminPrivileges: [URL] = []
            var notes: [String] = []
            let allowedExtraPaths = allowedOutsideHome.map { $0.standardizedFileURL.path }
            let forbiddenRoots = ["/System", "/Library", "/usr", "/bin", "/sbin"]

            // PHASE 1: Try normal deletion for each file
            for url in urls {
                let path = url.standardizedFileURL.path

                // Security checks
                if !path.hasPrefix(homePath) {
                    let isAllowedExtra = allowedExtraPaths.contains { path.hasPrefix($0) }
                    let isForbidden = forbiddenRoots.contains { path.hasPrefix($0) }
                    if !isAllowedExtra || isForbidden {
                        skipped.append(.init(url: url, reason: "Izinli degil"))
                        self.appendNote("Atlandi: \(url.lastPathComponent) - izinli degil", to: &notes)
                        continue
                    }
                } else if forbiddenRoots.contains(where: { path.hasPrefix($0) }) {
                    skipped.append(.init(url: url, reason: "Izinli degil"))
                    self.appendNote("Atlandi: \(url.lastPathComponent) - izinli degil", to: &notes)
                    continue
                }

                guard self.fileManager.fileExists(atPath: path) else {
                    skipped.append(.init(url: url, reason: "Mevcut degil"))
                    self.appendNote("Atlandi: \(url.lastPathComponent) - mevcut degil", to: &notes)
                    continue
                }

                if let isSymlink = try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink, isSymlink == true {
                    skipped.append(.init(url: url, reason: "Symlink"))
                    self.appendNote("Atlandi: \(url.lastPathComponent) - symlink", to: &notes)
                    continue
                }

                // Try normal deletion
                do {
                    var trashedURL: NSURL?
                    try self.fileManager.trashItem(at: url, resultingItemURL: &trashedURL)
                    moved.append(.init(original: url, trashedURL: trashedURL as URL?, usedAdminPrivileges: false))
                    self.logManager.log("Cop Kutusu: \(url.lastPathComponent)", category: .cleanup, level: .info)
                    self.appendNote("Tasindi: \(url.lastPathComponent)", to: &notes)
                } catch {
                    let nsError = error as NSError
                    // Permission denied or similar - needs admin privileges
                    if nsError.code == NSFileWriteNoPermissionError ||
                       nsError.code == 513 ||  // Operation not permitted
                       nsError.code == 1 {     // General error that might need elevation
                        needsAdminPrivileges.append(url)
                        self.logManager.log("Admin yetkisi gerekli: \(url.lastPathComponent) (kod \(nsError.code))", category: .audit, level: .info)
                    } else {
                        failed.append(.init(url: url, error: nsError))
                        self.logManager.log("Cop Kutusu hatasi \(url.lastPathComponent) kod \(nsError.code)", category: .error, level: .error)
                        self.appendNote("Hata: \(url.lastPathComponent) - kod \(nsError.code)", to: &notes)
                    }
                }
            }

            // PHASE 2: If there are files needing admin privileges, request elevation once
            guard !needsAdminPrivileges.isEmpty else {
                let result = SmartMoveResult(
                    moved: moved,
                    skipped: skipped,
                    failed: failed,
                    notes: Array(notes.prefix(5)),
                    userCancelled: false
                )
                DispatchQueue.main.async {
                    completion(result)
                }
                return
            }

            // Use AppleScript with admin privileges for protected files
            self.moveToTrashWithAdminPrivileges(urls: needsAdminPrivileges) { adminResult in
                switch adminResult {
                case .success(let trashedURLs):
                    for (index, url) in needsAdminPrivileges.enumerated() {
                        let trashedURL = index < trashedURLs.count ? trashedURLs[index] : nil
                        moved.append(.init(original: url, trashedURL: trashedURL, usedAdminPrivileges: true))
                        self.logManager.log("Cop Kutusu (admin): \(url.lastPathComponent)", category: .cleanup, level: .info)
                        self.appendNote("Tasindi (admin): \(url.lastPathComponent)", to: &notes)
                    }
                    let result = SmartMoveResult(
                        moved: moved,
                        skipped: skipped,
                        failed: failed,
                        notes: Array(notes.prefix(5)),
                        userCancelled: false
                    )
                    completion(result)

                case .failure(let error):
                    if error.isUserCancelled {
                        // User cancelled - mark admin files as skipped
                        for url in needsAdminPrivileges {
                            skipped.append(.init(url: url, reason: "Kullanici iptal etti"))
                        }
                        self.appendNote("Kullanici admin yetkisini iptal etti", to: &notes)
                        let result = SmartMoveResult(
                            moved: moved,
                            skipped: skipped,
                            failed: failed,
                            notes: Array(notes.prefix(5)),
                            userCancelled: true
                        )
                        completion(result)
                    } else {
                        // AppleScript error - mark as failed
                        for url in needsAdminPrivileges {
                            let nsError = NSError(
                                domain: "SafeDeleteService",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]
                            )
                            failed.append(.init(url: url, error: nsError))
                        }
                        self.appendNote("Admin silme hatasi: \(error.localizedDescription)", to: &notes)
                        let result = SmartMoveResult(
                            moved: moved,
                            skipped: skipped,
                            failed: failed,
                            notes: Array(notes.prefix(5)),
                            userCancelled: false
                        )
                        completion(result)
                    }
                }
            }
        }
    }
}
