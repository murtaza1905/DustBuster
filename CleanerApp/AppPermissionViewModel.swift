import Foundation
import AppKit
import Combine

final class AppPermissionViewModel: ObservableObject {
    @Published var hasFullDiskAccess: Bool = false

    private let permissionManager = PermissionManager.shared
    private var activationObserver: NSObjectProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bind()
        setup()
    }
    
    deinit {
        if let observer = activationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func bind() {
        permissionManager.$hasFullDiskAccess
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasFullDiskAccess, on: self)
            .store(in: &cancellables)
    }
    
    private func setup() {
        refreshFullDiskAccessStatus()
        
        activationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshFullDiskAccessStatus()
            }
        }
    }
    
    func refreshFullDiskAccessStatus() {
        permissionManager.checkFullDiskAccess()
    }
}
