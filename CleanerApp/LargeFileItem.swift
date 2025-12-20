// Sources/Models/LargeFileItem.swift
import Foundation

struct LargeFileItem: Identifiable {
    let id = UUID()
    let url: URL
    let size: Int64
    var isSelected: Bool = false

    var name: String {
        url.lastPathComponent
    }

    var path: String {
        url.path
    }

    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}
