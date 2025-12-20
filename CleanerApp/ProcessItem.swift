// Sources/Models/ProcessItem.swift
import Foundation

/// Görev yöneticisinde gösterilen süreç bilgisi.
struct ProcessItem: Identifiable, Hashable {
    let id = UUID()
    let pid: Int
    let name: String
    let bundleIdentifier: String?
    let isSystemProtected: Bool
}
