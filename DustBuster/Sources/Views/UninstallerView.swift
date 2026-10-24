import SwiftUI
import UniformTypeIdentifiers
import AppKit
import DustBusterCore

struct UninstallerView: View {
    @StateObject private var viewModel = UninstallerViewModel()
    @State private var isTargeted: Bool = false
    @State private var showWeakItems: Bool = true
    @State private var showOptions: Bool = false

    private var hasApp: Bool { viewModel.appURL != nil }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.xl) {
                    PageTitle(title: "Uygulama Kaldır", subtitle: "Bir uygulamayı kalıntılarıyla birlikte kaldır")
                    dropArea
                    errorBanner
                    if hasApp {
                        appCard
                        itemsCard
                        resultSummary
                    }
                    undoHistorySection
                }
                .pageLayout()
                .padding(.bottom, hasApp ? 110 : 0)
            }

            if hasApp {
                bottomBar
                    .padding(.horizontal, DS.Spacing.xl)
                    .padding(.bottom, DS.Spacing.lg)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showOptions.toggle()
                } label: {
                    Label("Tarama seçenekleri", systemImage: "slider.horizontal.3")
                }
                .popover(isPresented: $showOptions, arrowEdge: .bottom) {
                    optionsPopover
                }
                .help("Sistem konumları ve geniş tarama")

                Button {
                    viewModel.reset()
                } label: {
                    Label("Sıfırla", systemImage: "arrow.counterclockwise")
                }
                .disabled(!hasApp && viewModel.items.isEmpty && viewModel.resultSummary == nil && viewModel.errorMessage == nil)
                .help("Seçimi ve sonuçları temizle")
            }
        }
    }

    // MARK: - Bırakma alanı

    private var dropArea: some View {
        let shape = RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
        return VStack(spacing: DS.Spacing.sm) {
            Image(systemName: hasApp ? "checkmark.circle" : "square.and.arrow.down.on.square")
                .font(.system(size: hasApp ? 28 : 40, weight: .regular))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isTargeted ? Color.accentColor : (hasApp ? Color.green : Color.secondary))
            Text(hasApp ? "Başka bir .app bırakarak yeni tarama başlat" : ".app dosyasını buraya bırak")
                .font(hasApp ? .subheadline : .title3.weight(.medium))
                .foregroundStyle(hasApp ? .secondary : .primary)
            if !hasApp {
                Text("Yalnızca uygulama paketleri kabul edilir; hiçbir şey otomatik silinmez.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: hasApp ? 84 : 180)
        .background(isTargeted ? Color.accentColor.opacity(0.08) : Color.clear, in: shape)
        .overlay(shape.strokeBorder(isTargeted ? Color.accentColor : Color.secondary.opacity(0.35),
                                    style: StrokeStyle(lineWidth: isTargeted ? 2 : 1.5, dash: [8, 6])))
        .animation(.easeInOut(duration: 0.15), value: isTargeted)
        .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
            viewModel.handleDrop(providers: providers)
        }
    }

    // MARK: - Seçenekler

    private var optionsPopover: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Tarama seçenekleri")
                .font(.headline)

            Toggle(isOn: $viewModel.includeSystemLocations) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sistem konumlarını da tara")
                    Text("/Library altındaki ortak dosyalar; silmek yönetici yetkisi isteyebilir.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onChange(of: viewModel.includeSystemLocations) { _, _ in
                if let url = viewModel.appURL { viewModel.loadApp(at: url) }
            }

            Toggle(isOn: $viewModel.includeAggressiveLocations) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Geniş tarama")
                    Text("WebKit, Developer, Frameworks gibi büyük alanlar; daha yavaş.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onChange(of: viewModel.includeAggressiveLocations) { _, _ in
                if let url = viewModel.appURL { viewModel.loadApp(at: url) }
            }
        }
        .toggleStyle(.switch)
        .controlSize(.small)
        .padding(DS.Spacing.lg)
        .frame(width: 360)
    }

    // MARK: - Hata

    private var errorBanner: some View {
        Group {
            if let message = viewModel.errorMessage, !message.isEmpty {
                NoticeBanner(text: message, kind: .warning)
            }
        }
    }

    // MARK: - Uygulama kartı

    private var appCard: some View {
        Group {
            if let appURL = viewModel.appURL {
                HStack(spacing: DS.Spacing.lg) {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: appURL.path))
                        .resizable()
                        .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text(viewModel.appName.isEmpty ? appURL.deletingPathExtension().lastPathComponent : viewModel.appName)
                            .font(.title3.weight(.semibold))
                        Text(viewModel.bundleIdentifier.isEmpty ? "Bundle ID yok" : viewModel.bundleIdentifier)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(appURL.path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    Spacer()

                    if viewModel.isScanning {
                        HStack(spacing: DS.Spacing.sm) {
                            ProgressView().controlSize(.small)
                            Text("Taranıyor…")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(viewModel.totalSize)
                                .font(.title3.weight(.semibold))
                                .monospacedDigit()
                            Text("\(viewModel.items.count) öğe bulundu")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .cardSurface()
            }
        }
    }

    // MARK: - Öğeler

    private var itemsCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            CardHeader("Bulunan Öğeler", subtitle: "Seçili olanlar Çöp Kutusu'na taşınır", systemImage: "list.bullet.rectangle") {
                if viewModel.isScanning {
                    ProgressView().controlSize(.small)
                }
            }

            if viewModel.items.isEmpty {
                EmptyState(systemImage: viewModel.isScanning ? "magnifyingglass" : "checkmark.seal",
                           title: viewModel.isScanning ? "Tarama yapılıyor…" : "Kalıntı bulunamadı",
                           message: viewModel.isScanning ? nil : "Uygulama paketi dışında silinecek bir şey yok.")
            } else {
                List {
                    Section {
                        ForEach(strongItems) { item in
                            row(for: item)
                        }
                    } header: {
                        SectionTitle(title: "Kaldırılacaklar", count: strongItems.count,
                                     note: "Kesin kaynaklarla bulundu, varsayılan seçili", tone: .success)
                    }

                    if !weakItems.isEmpty {
                        Section {
                            if showWeakItems {
                                ForEach(weakItems) { item in
                                    row(for: item)
                                }
                            }
                        } header: {
                            HStack(spacing: DS.Spacing.sm) {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) { showWeakItems.toggle() }
                                } label: {
                                    HStack(spacing: DS.Spacing.sm) {
                                        Image(systemName: showWeakItems ? "chevron.down" : "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .frame(width: 12)
                                        SectionTitle(title: "Kontrol et", count: weakItems.count,
                                                     note: "Paylaşılan grup, satıcı klasörü veya ad benzerliği; varsayılan seçimsiz", tone: .warning)
                                    }
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 280, maxHeight: 520)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.inner, style: .continuous))
            }
        }
        .cardSurface()
    }

    private var strongItems: [UninstallItem] { viewModel.items.filter { $0.isStrongMatch } }
    private var weakItems: [UninstallItem] { viewModel.items.filter { !$0.isStrongMatch } }

    private func selectionBinding(for item: UninstallItem) -> Binding<Bool> {
        Binding(
            get: { viewModel.items.first { $0.id == item.id }?.isSelected ?? item.isSelected },
            set: { newValue in
                guard let index = viewModel.items.firstIndex(where: { $0.id == item.id }) else { return }
                viewModel.items[index].isSelected = newValue
                if newValue { viewModel.requestSize(for: item.id) }
            }
        )
    }

    private func row(for item: UninstallItem) -> some View {
        HStack(alignment: .center, spacing: DS.Spacing.md) {
            Toggle("", isOn: selectionBinding(for: item))
                .labelsHidden()
                .toggleStyle(.checkbox)

            Image(systemName: iconName(for: item.kind))
                .symbolRenderingMode(.hierarchical)
                .font(.title3)
                .foregroundStyle(item.isStrongMatch ? Color.accentColor : Color.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: DS.Spacing.sm) {
                    Text(item.displayName)
                        .font(.body.weight(.medium))
                        .lineLimit(1)
                    Tag(text: item.kind.rawValue)
                    if let badge = item.sourceBadge {
                        Tag(text: badge, tone: .success)
                    }
                }
                Text(item.url.path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            Text(sizeText(for: item))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 76, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .help(item.note)
        .onAppear {
            viewModel.requestSize(for: item.id)
        }
    }

    // MARK: - Eylem çubuğu

    private var bottomBar: some View {
        HStack(spacing: DS.Spacing.lg) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: DS.Spacing.sm) {
                    Text("\(viewModel.selectedCount) öğe seçili")
                        .font(.subheadline.weight(.medium))
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(viewModel.selectedTotalSize)
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                    if viewModel.selectedCount != viewModel.items.count {
                        Text("/ \(viewModel.totalSize)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
                Text("Çöp Kutusu'na taşınır; Geçmiş'ten geri alınabilir.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.exportReport()
            } label: {
                Label("Rapor", systemImage: "doc.text")
            }
            .adaptiveGlassButtonStyle()
            .disabled(viewModel.isScanning)
            .help("Bulunan öğeleri, arama kriterlerini ve ham listeyi metin dosyası olarak kaydet")

            Button {
                viewModel.exportFixture()
            } label: {
                Label("Test vakası", systemImage: "checkmark.seal")
            }
            .adaptiveGlassButtonStyle()
            .disabled(viewModel.isScanning)
            .help("Bu taramayı test korpusuna eklenecek JSON vakası olarak kaydet")

            Button {
                viewModel.moveSelectedToTrash()
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isProcessing {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "trash")
                    }
                    Text("Çöp Kutusuna Taşı")
                }
            }
            .adaptiveGlassButtonStyle(prominent: true)
            .tint(.red)
            .disabled(viewModel.isProcessing || viewModel.selectedCount == 0)
        }
        .controlSize(.large)
        .floatingBar()
    }

    // MARK: - Sonuç

    private var resultSummary: some View {
        Group {
            if let summary = viewModel.resultSummary {
                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                    CardHeader("Sonuç", systemImage: "checkmark.circle", tint: .green)
                    HStack(spacing: DS.Spacing.md) {
                        Tag(text: "Taşındı \(summary.moved)", tone: .success, systemImage: "checkmark.circle.fill")
                        Tag(text: "Atlandı \(summary.skipped)", tone: .warning, systemImage: "minus.circle")
                        Tag(text: "Hata \(summary.failed)", tone: summary.failed > 0 ? .danger : .neutral, systemImage: "xmark.octagon.fill")
                    }
                    ForEach(summary.messages, id: \.self) { message in
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .truncationMode(.middle)
                    }
                }
                .cardSurface()
            }
        }
    }

    // MARK: - Geçmiş

    private var undoHistorySection: some View {
        Group {
            if !viewModel.uninstallHistory.isEmpty {
                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                    CardHeader("Son Kaldırılanlar", subtitle: "\(viewModel.uninstallHistory.count) uygulama",
                               systemImage: "clock.arrow.circlepath", tint: .secondary) {
                        Button("Geçmişi Temizle") {
                            viewModel.clearUndoHistory()
                        }
                        .buttonStyle(.borderless)
                        .font(.caption)
                    }

                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.uninstallHistory.enumerated()), id: \.element.id) { index, transaction in
                            HStack(spacing: DS.Spacing.md) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(transaction.appName.isEmpty ? "Bilinmeyen" : transaction.appName)
                                        .font(.subheadline.weight(.medium))
                                    HStack(spacing: 6) {
                                        Text("\(transaction.itemCount) öğe")
                                        Text("·")
                                        Text(transaction.formattedSize)
                                        Text("·")
                                        Text(transaction.date, style: .relative)
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    viewModel.undoUninstall(transaction)
                                } label: {
                                    HStack(spacing: 4) {
                                        if viewModel.isUndoing {
                                            ProgressView().controlSize(.small)
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
                            .padding(.vertical, DS.Spacing.sm)
                            if index < viewModel.uninstallHistory.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .insetSurface()
                }
                .cardSurface()
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
        case .systemLogs:
            return "doc.text.fill"
        case .systemCaches:
            return "archivebox.fill"
        case .homeDotfile:
            return "eye.slash.fill"
        case .sharedUsers:
            return "person.2.fill"
        case .other:
            return "questionmark.folder.fill"
        }
    }

    private func sizeText(for item: UninstallItem) -> String {
        guard let size = item.sizeBytes else { return "…" }
        return size == 0 ? "boş" : ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}
