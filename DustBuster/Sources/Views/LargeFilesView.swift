import SwiftUI

struct LargeFilesView: View {
    @EnvironmentObject var viewModel: LargeFilesViewModel
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                PageTitle(title: "Büyük Dosyalar", subtitle: "Ev dizinindeki 250 MB ve üzeri dosyalar")
                fileList
                errorBanner
                footer
            }
            .pageLayout()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.scheduleScan()
                } label: {
                    Label("Yeniden Tara", systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.isScanning)
            }
        }
        .alert("Seçili dosyalar Çöp Kutusu'na taşınsın mı?", isPresented: $showDeleteAlert) {
            Button("Vazgeç", role: .cancel) { }
            Button("Çöp Kutusuna Taşı", role: .destructive) {
                viewModel.deleteSelected()
            }
        } message: {
            Text("Dosyalar kalıcı olarak silinmez; Çöp Kutusu'ndan geri alınabilir.")
        }
    }

    // MARK: - Liste

    private var fileList: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            CardHeader("Bulunan Dosyalar", subtitle: "Seçili olanlar Çöp Kutusu'na taşınır", systemImage: "externaldrive") {
                if viewModel.isScanning {
                    ProgressView().controlSize(.small)
                } else if !viewModel.items.isEmpty {
                    Tag(text: "\(viewModel.items.count) dosya")
                }
            }

            if viewModel.items.isEmpty {
                EmptyState(systemImage: viewModel.isScanning ? "magnifyingglass" : "externaldrive.badge.checkmark",
                           title: viewModel.isScanning ? "Tarama yapılıyor…" : "Büyük dosya bulunamadı",
                           message: viewModel.isScanning ? nil : "250 MB ve üzerinde dosya yok.")
            } else {
                List {
                    ForEach($viewModel.items) { $item in
                        FileRowView(item: $item)
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 260, maxHeight: 560)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.inner, style: .continuous))
            }
        }
        .cardSurface()
    }

    // MARK: - Alt çubuk

    private var footer: some View {
        HStack(spacing: DS.Spacing.lg) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.selectedCount) dosya seçili")
                    .font(.subheadline.weight(.medium))
                Text(viewModel.selectedSizeString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Spacer()

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Çöp Kutusuna Taşı", systemImage: "trash")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .controlSize(.large)
            .disabled(!viewModel.hasSelectedItems || viewModel.isDeleting)
        }
    }

    // MARK: - Hata

    private var errorBanner: some View {
        Group {
            if !viewModel.deleteErrors.isEmpty {
                NoticeBanner(text: "Çöp Kutusu'na taşınamayan dosyalar:\n" + viewModel.deleteErrors.joined(separator: "\n"), kind: .danger)
            }
        }
    }
}

// MARK: - Satır

private struct FileRowView: View {
    @Binding var item: LargeFileItem

    var body: some View {
        HStack(alignment: .center, spacing: DS.Spacing.md) {
            Toggle("", isOn: $item.isSelected)
                .labelsHidden()
                .toggleStyle(.checkbox)

            Image(systemName: "doc.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(item.path.replacingOccurrences(of: NSHomeDirectory(), with: "~"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            Text(item.displaySize)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 76, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
