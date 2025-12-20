import SwiftUI
import UniformTypeIdentifiers

struct UninstallerView: View {
    @StateObject private var viewModel = UninstallerViewModel()
    @State private var isTargeted: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    dropArea
                    errorBanner
                    appInfo
                    itemsSection
                    resultSummary
                    undoHistorySection
                }
                .padding()
                .padding(.bottom, 96) // allow space for the action bar
            }

            bottomBar
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Uygulama Kaldır")
                    .font(.title)
                    .bold()
                Spacer()
                Button("Sıfırla") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.appURL == nil && viewModel.items.isEmpty && viewModel.resultSummary == nil && viewModel.errorMessage == nil)
            }
            
            Text("Bir .app sürükleyip bırak, Library altındaki kalan dosyaları bulup Çöp Kutusu'na taşı.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Drop area

    private var dropArea: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(isTargeted ? Color.accentColor : Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [8]))
            .frame(height: 180)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.down.on.square")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                    Text(".app dosyasını buraya bırak")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("Sadece uygulama paketleri kabul edilir.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            )
            .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
                viewModel.handleDrop(providers: providers)
            }
    }

    // MARK: - Info note & System Scan Toggle

    private var infoNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Guvenlik: Sadece sectigin uygulama paketi ve ~/Library altindaki yollar listelenir.")
                .font(.caption)
                .foregroundColor(.secondary)

            Toggle(isOn: $viewModel.includeSystemLocations) {
                HStack(spacing: 4) {
                    Image(systemName: "gearshape.2")
                        .foregroundColor(.secondary)
                    Text("Sistem dosyalarini da tara")
                        .font(.caption)
                }
            }
            .toggleStyle(.checkbox)
            .onChange(of: viewModel.includeSystemLocations) { _, newValue in
                // Toggle degistiginde uygulama yukluyse yeniden tara
                if viewModel.appURL != nil {
                    if let url = viewModel.appURL {
                        viewModel.loadApp(at: url)
                    }
                }
            }

            Toggle(isOn: $viewModel.includeAggressiveLocations) {
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    Text("Geniş tarama (daha yavaş)")
                        .font(.caption)
                }
            }
            .toggleStyle(.checkbox)
            .onChange(of: viewModel.includeAggressiveLocations) { _, _ in
                if let url = viewModel.appURL {
                    viewModel.loadApp(at: url)
                }
            }

            if viewModel.includeAggressiveLocations {
                Text("Not: WebKit/Developer/Frameworks gibi büyük alanlar taranır, süre artar.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if viewModel.includeSystemLocations {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("/Library/ altindaki sistem dosyalari da taranacak (admin yetkisi gerektirebilir)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Error

    private var errorBanner: some View {
        Group {
            if let message = viewModel.errorMessage, !message.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(10)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - App info

    private var appInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Seçilen Uygulama")
                .font(.headline)

            if let appURL = viewModel.appURL {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.appName.isEmpty ? appURL.deletingPathExtension().lastPathComponent : viewModel.appName)
                        .font(.title3)
                        .bold()
                    Text("Bundle ID: \(viewModel.bundleIdentifier.isEmpty ? "-" : viewModel.bundleIdentifier)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(appURL.path)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding()
                .background(Color.gray.opacity(0.06))
                .cornerRadius(10)
            } else {
                Text("Henüz bir uygulama seçilmedi.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 6)
            }
        }
    }

    // MARK: - Items

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Öğeler")
                    .font(.headline)
                if viewModel.isScanning {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            if viewModel.items.isEmpty {
                Group {
                    if viewModel.isScanning {
                        Text("Tarama yapılıyor...")
                    } else if viewModel.appURL != nil {
                        Text("Liste boş. Uygulama paketi ve kalıntılar bulunamadı.")
                    } else {
                        Text(".app bırak ve öğeleri listele.")
                    }
                }
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
            } else {
                List {
                    ForEach($viewModel.items) { $item in
                        HStack(alignment: .center, spacing: 12) {
                            // İkon eklendi
                            Image(systemName: iconName(for: item.kind))
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Satır 1: İsim + Tür badge
                                HStack(spacing: 8) {
                                    Text(item.displayName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                    
                                    Text(item.kind.rawValue)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.secondary.opacity(0.15))
                                        .cornerRadius(4)
                                }
                                
                                // Satır 2: Path (kısaltılmış)
                                Text(item.url.path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }

                            Spacer()

                            // Boyut ve checkbox yan yana
                            HStack(spacing: 12) {
                                Text(sizeText(for: item))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 70, alignment: .trailing)
                                
                                Toggle("", isOn: $item.isSelected)
                                    .labelsHidden()
                                    .toggleStyle(.checkbox)
                            }
                        }
                        .padding(.vertical, 8)
                        .onAppear {
                            viewModel.requestSize(for: item.id)
                        }
                        .onChange(of: item.isSelected) { _, newValue in
                            if newValue {
                                viewModel.requestSize(for: item.id)
                            }
                        }
                    }
                }
                .frame(minHeight: 280, maxHeight: 500)
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
        }
    }

    // MARK: - Action

    private var bottomBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 16) {
                    // Seçili öğe sayısı ve boyutu
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Seçili: \(viewModel.selectedCount) öğe")
                            .font(.subheadline)
                    }
                    
                    // Seçili toplam boyut
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(viewModel.selectedTotalSize)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    // Toplam boyut (tüm öğeler)
                    if viewModel.selectedCount != viewModel.items.count {
                        Text("/ \(viewModel.totalSize)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Tarama kapsamı: uygulama paketi ve ~/Library altındaki güvenli yollar.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                viewModel.moveSelectedToTrash()
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isProcessing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "trash")
                    }
                    Text("Çöp Kutusuna Taşı")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isProcessing || viewModel.selectedCount == 0)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    // MARK: - Result

    private var resultSummary: some View {
        Group {
            if let summary = viewModel.resultSummary {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sonuç Özeti")
                        .font(.headline)
                    HStack(spacing: 12) {
                        Label("Taşındı: \(summary.moved)", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Label("Atlandı: \(summary.skipped)", systemImage: "minus.circle")
                            .foregroundColor(.orange)
                        Label("Hata: \(summary.failed)", systemImage: "xmark.octagon.fill")
                            .foregroundColor(.red)
                    }
                    ForEach(summary.messages, id: \.self) { message in
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .truncationMode(.middle)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.06))
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Undo History

    private var undoHistorySection: some View {
        Group {
            if !viewModel.uninstallHistory.isEmpty {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.green)
                        Text("Son Kaldırılanlar")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        if viewModel.uninstallHistory.count > 1 {
                            Text("\(viewModel.uninstallHistory.count) uygulama")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Button("Geçmişi Temizle") {
                            viewModel.clearUndoHistory()
                        }
                        .font(.caption)
                        .buttonStyle(.borderless)
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(viewModel.uninstallHistory) { transaction in
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(transaction.appName.isEmpty ? "Bilinmeyen" : transaction.appName)
                                            .font(.subheadline)
                                        HStack(spacing: 8) {
                                            Text("\(transaction.itemCount) öğe")
                                            Text("•")
                                            Text(transaction.formattedSize)
                                            Text("•")
                                            Text(transaction.date, style: .relative)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.undoUninstall(transaction)
                                    } label: {
                                        HStack(spacing: 4) {
                                            if viewModel.isUndoing {
                                                ProgressView()
                                                    .controlSize(.small)
                                            } else {
                                                Image(systemName: "arrow.uturn.backward")
                                            }
                                            Text("Geri Al")
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .disabled(viewModel.isUndoing)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    .frame(maxHeight: 120)
                }
                .background(Color.green.opacity(0.05))
                .cornerRadius(10)
            }
        }
    }

    // MARK: - Helpers

    private func iconName(for kind: UninstallItemKind) -> String {
        switch kind {
        case .appBundle:
            return "app.badge.fill"
        case .applicationSupport:
            return "folder.fill"
        case .caches:
            return "archivebox.fill"
        case .preferences:
            return "gearshape.fill"
        case .preferencesByHost:
            return "gearshape.2.fill"
        case .logs:
            return "doc.text.fill"
        case .savedState:
            return "clock.fill"
        case .containers:
            return "shippingbox.fill"
        case .groupContainers:
            return "shippingbox.and.arrow.backward.fill"
        case .launchAgents:
            return "bolt.fill"
        case .httpStorages:
            return "network"
        case .webKit:
            return "globe"
        case .cookies:
            return "cpu.fill"
        case .crashReports:
            return "exclamationmark.triangle.fill"
        case .applicationScripts:
            return "applescript.fill"
        case .internetPlugins:
            return "puzzlepiece.extension.fill"
        case .preferencePanes:
            return "slider.horizontal.3"
        case .quickLook:
            return "eye.fill"
        case .screenSavers:
            return "rectangle.on.rectangle"
        case .services:
            return "gear.badge.checkmark"
        case .spotlight:
            return "magnifyingglass.circle.fill"
        case .inputMethods:
            return "keyboard.fill"
        case .frameworks:
            return "cube.box.fill"
        case .colorPickers:
            return "paintpalette.fill"
        case .addressBookPlugins:
            return "person.crop.circle.fill"
        case .mailBundles:
            return "envelope.fill"
        case .developer:
            return "hammer.fill"
        case .recentDocuments:
            return "clock.arrow.circlepath"
        case .systemAppSupport:
            return "folder.badge.gearshape"
        case .systemLaunchAgents:
            return "bolt.badge.a"
        case .systemLaunchDaemons:
            return "bolt.badge.checkmark"
        case .privilegedHelpers:
            return "shield.lefthalf.filled"
        case .systemPreferences:
            return "system.settings"
        case .systemFrameworks:
            return "cube.box.badge.gearshape"
        case .other:
            return "questionmark.folder.fill"
        }
    }

    private func sizeText(for item: UninstallItem) -> String {
        guard let size = item.sizeBytes else { return "-" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}
