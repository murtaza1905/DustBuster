
# FULL_PROJECT_XRAY.md

## 1. File Inventory & Logic Map

| File Name | Actual Role | Key Functions | Hidden Features / Notes |
| :--- | :--- | :--- | :--- |
| **AppPermissionViewModel.swift** | Manages and monitors the app's Full Disk Access permission state. | `refreshFullDiskAccessStatus()` | Uses Combine to reactively update views and listens for app activation to re-check permissions. |
| **CleanerAppApp.swift** | The main entry point of the application. | `CleanAppApp` (main App struct) | Injects the `AppPermissionViewModel` into the environment. Sets a hidden title bar style. |
| **CleanerManager.swift** | Core logic for scanning and deleting junk files. | `scan()`, `clean()`, `isSafeToDelete()` | Contains extensive safety checks, including a `forbiddenPaths` list and `sensitiveKeywords` to prevent accidental data loss. Dynamically detects Chromium-based browser caches. |
| **CleanerOptionsView.swift** | A sheet view to display scanned files and allow the user to select which ones to delete. | `sortedItems` (computed property), `toggleSortOrder()` | Manages sorting and selection of files to be cleaned. |
| **ContentView.swift** | The root view of the application. | `ContentView` | Sets up the main `NavigationSplitView`. |
| **DashboardView.swift** | The main dashboard of the application. | `DashboardView`, `UsageCard`, `UsageRingView` | Displays system stats (RAM, Disk, CPU) and provides an interface for initiating a system scan. |
| **DashboardViewModel.swift** | The ViewModel for the `DashboardView`. | `scanSystem()`, `cleanSelectedItems()` | Acts as a central coordinator for the `SystemMonitor`, `CleanerManager`, and `PermissionManager`. Marked with `@MainActor`. |
| **FileItem.swift** | Data model for a file or folder identified for cleaning. | `displayName` (computed property) | Contains a lot of logic to generate user-friendly names for cache files, which would be better placed in a separate service. |
| **FullDiskAccessLockedView.swift** | A view displayed when Full Disk Access is not granted. | `FullDiskAccessLockedView` | Provides a button to directly open the system settings for Full Disk Access. |
| **LargeFileItem.swift** | A simplified data model for a large file. | (none) | A straightforward data model. |
| **LargeFileManager.swift** | Scans for large files in user-specified directories. | `scan()` | Scans are performed on a background thread. |
| **LargeFilesView.swift** | The UI for the "Large Files" feature. | `LargeFilesView`, `FileRowView` | Displays a list of large files and allows the user to select them for deletion. |
| **LargeFilesViewModel.swift** | The ViewModel for the `LargeFilesView`. | `scheduleScan()`, `deleteSelected()` | Manages the state and logic for the large files feature. |
| **LogManager.swift** | A centralized, privacy-focused logging solution. | `log()`, `exportLogs()`, `sanitize()` | Uses `OSLog` and automatically redacts PII from log messages. |
| **MainDetailRouter.swift** | A router for the main detail view. | `MainDetailRouter` | Uses a `switch` statement to display the correct view based on the sidebar selection. Wraps views in a `PermissionGate`. |
| **MaterialCard.swift** | A reusable card view component. | `MaterialCard`, `MaterialCardModifier` | Provides a consistent "glassmorphism" style for cards. |
| **PermissionGate.swift** | A view that acts as a gatekeeper for content that requires Full Disk Access. | `PermissionGate` | A reusable and elegant way to handle permissions. |
| **PermissionManager.swift** | A singleton that manages Full Disk Access permission. | `checkFullDiskAccess()`, `requestFullDiskAccess()` | Uses a "smart check" by trying to access protected files. |
| **ProcessItem.swift** | Data model for a running process. | (none) | A straightforward data model. |
| **ProcessListView.swift** | A view that lists running third-party applications. | `ProcessListView` | Allows the user to quit or force-quit applications. |
| **ProcessManager.swift** | Manages running applications. | `refresh()`, `terminate()` | Filters out system processes and has a list of protected bundle IDs. |
| **SettingsView.swift** | The settings screen of the application. | `SettingsView` | Displays app info and provides a way to export logs. |
| **SidebarItem.swift** | An enum representing the items in the sidebar. | (none) | `Hashable` for use with SwiftUI navigation. |
| **SidebarView.swift** | The sidebar of the application. | `SidebarView` | A standard SwiftUI sidebar implementation. |
| **SystemMonitor.swift** | Monitors system resource usage (RAM, Disk, CPU). | `startMonitoring()`, `updateMetrics()` | Uses low-level C APIs to get system information. |
| **View+Glass.swift** | View extensions for applying a "glassmorphism" effect. | `adaptiveGlassEffect()`, `adaptiveGlassButtonStyle()` | Uses `@available` to provide modern effects on newer macOS versions while maintaining compatibility with older ones. |

## 2. Feature Verification (True/False)

- **App Uninstaller:** **False**. The code does not contain any logic to find and remove associated app files (containers, caches, etc.) for a full application uninstall. The `CleanerManager` is focused on cleaning temporary files, not uninstalling applications.

- **Glassmorphism/UI:** **True**. The project makes extensive use of a "glassmorphism" effect. The primary implementation is in `View+Glass.swift`:

  ```swift
  // In View+Glass.swift
  @ViewBuilder
  func adaptiveGlassEffect<S: Shape>(
      _ material: Material = .ultraThinMaterial,
      in shape: S
  ) -> some View {
      if #available(macOS 26.0, *) {
          self.glassEffect(.regular, in: shape)
      } else {
          self.background(material, in: shape)
      }
  }
  ```

  This effect is then applied throughout the app using the `.adaptiveGlassEffect()` modifier, for example in `MaterialCard.swift`:

  ```swift
  // In MaterialCard.swift
  struct MaterialCardModifier: ViewModifier {
      func body(content: Content) -> some View {
          content
              .padding()
              .adaptiveGlassEffect(in: .rect(cornerRadius: 16))
      }
  }
  ```

## 3. Code Health Check

- **Modern Concurrency:** The project uses a mix of modern and traditional concurrency patterns.
  - **`async/await`:** The `DashboardViewModel` is marked with `@MainActor`, which is a good use of modern concurrency.
  - **`DispatchQueue`:** The `CleanerManager`, `LargeFileManager`, and `SystemMonitor` all use `DispatchQueue.global()` to perform work on a background thread and then `DispatchQueue.main.async` to update the UI. This is a correct and safe pattern, but some of this code could be updated to use `async/await` with `Task`s.
  - **Combine:** The project makes excellent use of the Combine framework for reactive data flow, especially in the ViewModels.

- **Hardcoded Values:**
  - **Strings:** There are many hardcoded strings, especially in the UI (e.g., "Sistem Durumu", "Disk Erişimi Gerekli"). These should be extracted into a localization file to support multiple languages.
  - **Paths:** The `CleanerManager` has many hardcoded paths and keywords. While this is necessary for its function, it makes the code rigid and hard to maintain. A more flexible rule-based system could be considered for the long term.
  - **Colors:** Colors are generally well-managed (e.g., `.green`, `.orange`), but a centralized color palette or theme file would improve consistency.

- **Spaghetti Code:**
  - **`CleanerManager.swift`:** The `isSafeToDelete()` function is very complex and could be refactored for clarity.
  - **`FileItem.swift`:** The `displayName` computed property has too much logic for a simple data model.
  - **`DashboardViewModel.swift`:** This ViewModel has a lot of responsibilities and could be considered a "God Object".

## 4. Architect's Verdict

### Summary of the Current State

This project is a well-structured and thoughtfully designed macOS utility. The developer has shown a strong understanding of SwiftUI, the MVVM design pattern, and modern Swift features. The focus on safety and user privacy is commendable, especially in the `CleanerManager` and `LogManager`. The code is generally clean, modular, and easy to understand.

### Step-by-Step Recommendation for the Next Development Phase

1.  **Immediate Improvements (Low-Hanging Fruit):**
    *   **Localize UI Strings:** Move all user-facing strings into a `Localizable.strings` file to prepare for localization.
    *   **Refactor `FileItem.displayName`:** Create a new service, e.g., `FileDisplayNameProvider`, to handle the logic of generating display names for files. This will make the `FileItem` a pure data model.
    *   **Refactor `CleanerManager.isSafeToDelete()`:** Break down the complex `isSafeToDelete()` function into smaller, more manageable private functions, each with a single responsibility (e.g., `isPathInForbiddenList()`, `doesPathContainSensitiveKeywords()`).

2.  **Mid-Term Refactoring:**
    *   **Introduce a `CleanerOptionsViewModel`:** Create a dedicated ViewModel for the `CleanerOptionsView`. This will reduce the responsibilities of the `DashboardViewModel` and improve separation of concerns.
    *   **Adopt `async/await` more widely:** Refactor the `CleanerManager`, `LargeFileManager`, and `SystemMonitor` to use `async/await` instead of `DispatchQueue`. This will make the asynchronous code more readable and concise.
    *   **Create a Theme/Style Guide:** Centralize colors, fonts, and other UI constants into a theme file to ensure consistency and make future redesigns easier.

3.  **Long-Term Architectural Goals:**
    *   **Rule Engine for `CleanerManager`:** Replace the hardcoded paths and keywords in `CleanerManager` with a more flexible rule engine. This would allow new cleaning rules to be added easily, perhaps even from a remote configuration file.
    *   **Add Unit and UI Tests:** The project currently lacks tests. Adding a suite of unit tests for the managers and ViewModels, and UI tests for the main user flows, would significantly improve the robustness of the application.
    *   **Dependency Injection:** While the current singleton and manual instantiation approach works, introducing a formal dependency injection container would make the code more testable and maintainable in the long run.
