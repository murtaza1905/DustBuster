// Sources/Managers/LargeFileManager.swift
import Foundation

final class LargeFileManager {

    private let fileManager = FileManager.default
    private let searchRoots: [URL]
    private let permissionManager = PermissionManager.shared
    private let logManager = LogManager.shared

    init() {
        let home = fileManager.homeDirectoryForCurrentUser

        // Sadece güvenli, kullanıcı odaklı klasörler
        searchRoots = [
            home.appendingPathComponent("Desktop"),
            home.appendingPathComponent("Documents"),
            home.appendingPathComponent("Downloads"),
            home.appendingPathComponent("Movies"),
            home.appendingPathComponent("Music"),
            home.appendingPathComponent("Pictures")
        ]
    }

    /// 250 MB ve üzeri dosyaları bulur.
    func scan(minSize: Int64,
              completion: @escaping ([LargeFileItem]) -> Void) {

        permissionManager.checkFullDiskAccess()
        if permissionManager.hasFullDiskAccess == false {
            #if DEBUG
            print("Full Disk Access yok, LargeFileManager scan iptal edildi")
            #endif
            logManager.log("Büyük dosya taraması durduruldu: Full Disk Access yok", category: .audit, level: .warning)
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [LargeFileItem] = []
            self.logManager.log("Büyük dosya taraması başladı", category: .performance, level: .info)

            for root in self.searchRoots {
                guard let enumerator = self.fileManager.enumerator(
                    at: root,
                    includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
                    options: [.skipsHiddenFiles, .skipsPackageDescendants]
                ) else { continue }

                for case let url as URL in enumerator {
                    do {
                        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])

                        guard values.isRegularFile == true,
                              let fileSize = values.fileSize else {
                            continue
                        }

                        let size64 = Int64(fileSize)
                        if size64 >= minSize {
                            results.append(LargeFileItem(url: url,
                                                         size: size64,
                                                         isSelected: false))
                        }
                    } catch {
                        continue
                    }
                }
            }

            // Büyükten küçüğe sırala
            results.sort { $0.size > $1.size }
            let totalSize = results.reduce(Int64(0)) { $0 + $1.size }
            let sizeText = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
            self.logManager.log("Büyük dosya taraması tamamlandı: \(results.count) kayıt, \(sizeText)", category: .performance, level: .info)

            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
}
