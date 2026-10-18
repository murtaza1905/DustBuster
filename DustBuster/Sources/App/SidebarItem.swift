// Sources/App/SidebarItem.swift
import Foundation

enum SidebarItem: Hashable {
    case dashboard
    case processes      // Çalışan Uygulamalar
    case largeFiles     // Büyük Dosyalar
    case uninstaller    // Uygulama Kaldır
    case settings
}
